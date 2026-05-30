import 'package:attune/services/spotify_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// This is Firebase Auth Provider; handles sign up/in/out & keeps track of user
// Makes the current user, Spotify data, and auth state available to the widget tree. 
class AuthProvider extends ChangeNotifier {

  // instance of AuthService to do stuff with
  final AuthService _authService = AuthService();
  // instance of SpotifyAuth to get Spotify data with
  final SpotifyAuth _spotifyAuth = SpotifyAuth();

  // true while a network call is in progress
  bool _dataLoading = false;

  // keeps track of whether or not there's been an error
  bool _hasError = false;

  // the current user; nullable bc no user when app first loads
  UserModel? _currentUser;

  // tracks whether spotify is connected each time you run the app
  bool _isSpotifyConnectedThisTime = false;

  // kinda serves as an "is spotify connected' field
  bool get isSpotifyConnected => _isSpotifyConnectedThisTime;

  // in-memory Spotify data for the current user
  SpotifyUser? _spotifyUser;
  List<SpotifyArtist> _topArtists = [];
  List<SpotifyTrack> _topTracks = [];
  List<String> _topGenres = [];

  // getters since fields are private (dont need one for authService bc thats the
  // point of the provider)

  // returns the current user, if there is one
  UserModel? get currentUser => _currentUser;

  // returns whether or not the data is loaded
  bool get hasError => _hasError;

  // returns whether or not there was an error loading data
  bool get dataLoading => _dataLoading;

  // returns whether or not the current user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // returns user's Spotify profile
  SpotifyUser? get spotifyUser => _spotifyUser;

  // returns the user's top Spotify artists
  List<SpotifyArtist> get topArtists => _topArtists;

  // returns the user's top Spotify tracks
  List<SpotifyTrack> get topTracks => _topTracks;

  // returns the user's top Spotify genres
  List<String> get topGenres => _topGenres;

  // Interacts with Firebase auth state on construction
  // Automatically updates the current user whenever someone signs in or out, 
  // notifies listeners so the UI builds according to auth state
  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      // if no user exists yet/login fails, current user is null
      if (user == null) {
        _currentUser = null;
        
        // set current user
      } else {
        _currentUser ??= await _authService.fetchUser(user.uid);
      }  
      // tells the widgets consuming this provider to rebuild bc auth state changed
      notifyListeners();
    });
  }

  // signs user out, clears data from that user
  Future<void> signOut() async {
    _spotifyUser = null;
    _topArtists = [];
    _topTracks = [];
    _topGenres = [];
    _isSpotifyConnectedThisTime = false;
    await _authService.signOut();
  }

  // signs user in using email and password, returns true on success, false otherwise
  Future<bool> signIn({required String email, required String password}) async {
    try {
      // if login succeeds, no issues yay
      await _authService.signIn(email: email, password: password);

      // sometimes firebase fails so manually signing user in here can help 
      // minimize data load failures
      final firebaseUser = await _authService.getCurrentUser();
      if (firebaseUser != null) {
        _currentUser = await _authService.fetchUser(firebaseUser.uid);

        if (_currentUser == null) {
          _currentUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: firebaseUser.email?.split('@')[0] ?? 'user',
          );
          await _authService.createUser(_currentUser!);
        }

        notifyListeners();
      }
      return true;
    } catch (_) {
      // if the login was unsuccessful, notify listeners and return false
      // so error message can display & user can try again
      _hasError = true;
      notifyListeners();
      return false;
    }
  }

  // updates user's current location in memory & in Firestore whenever GPS coords change
  Future<void> updateLocation(double lat, double long) async {
    if (_currentUser == null) return;
    await _authService.updateLocation(_currentUser!.uid, lat, long);
    _currentUser!.latitude = lat;
    _currentUser!.longitude = long;
    notifyListeners();
  }

  // Creates new account with the given info, returns a new UserModel on success, null on failure
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        username: username,
      );
      // set current user if signup was successful
      _currentUser = user;
      notifyListeners();
      return user;
    } // otherwise, error
    catch (e) {
      _hasError = true;
      notifyListeners();
      return null;
    }
  }

  // launches Spotify OAuth login, then gets user's top music data.
  // Saves spotify data to Firestore and marks Spotify as connected
  Future<void> connectSpotify() async {
    try {
      _dataLoading = true;
      _hasError = false;
      notifyListeners();

      // OAuth login → returns Spotify profile
      _spotifyUser = await _spotifyAuth.login();

      // gets top music data
      final results = await Future.wait([
        _spotifyAuth.fetchTopArtists(),
        _spotifyAuth.fetchTopTracks(),
        _spotifyAuth.fetchTopGenres(),
      ]);

      _topArtists = results[0] as List<SpotifyArtist>;
      _topTracks = results[1] as List<SpotifyTrack>;
      _topGenres = results[2] as List<String>;

      // save Spotify Id and genres back to Firestore user doc
      if (_currentUser != null) {
        await _authService.updateSpotifyData(
          uid: _currentUser!.uid,
          spotifyId: _spotifyUser!.id,
          topGenres: _topGenres,
          topArtists: _topArtists.map((a) => a.name).toList(),
        );
        _currentUser = await _authService.fetchUser(_currentUser!.uid);
      }
      _isSpotifyConnectedThisTime = true;
    } catch (e) {
      _hasError = true;
    } finally {
      _dataLoading = false;
      notifyListeners();
    }
  }

  // Re-fetches top artists/tracks from Spotify, if valid connection exists
  // available for future/anticipated use 
  Future<void> refreshSpotifyData() async {
    if (!_spotifyAuth.isConnected) return;
    try {
      _dataLoading = true;
      notifyListeners();

      final results = await Future.wait([
        _spotifyAuth.fetchTopArtists(),
        _spotifyAuth.fetchTopTracks(),
        _spotifyAuth.fetchTopGenres(),
      ]);

      _topArtists = results[0] as List<SpotifyArtist>;
      _topTracks = results[1] as List<SpotifyTrack>;
      _topGenres = results[2] as List<String>;
    } catch (e) {
      _hasError = true;
    } finally {
      _dataLoading = false;
      notifyListeners();
    }
  }

  // updates the user's profile picture
  Future<void> updatePfp(String pfp) async {
    if (_currentUser == null) return;
    await _authService.updatePfp(uid: _currentUser!.uid, pfp: pfp);
    _currentUser = await _authService.fetchUser(_currentUser!.uid);
    notifyListeners();
  }

  // sends a friend request to another user 
  Future<void> sendFriendRequest(String targetUid) async {
    if (_currentUser == null) {
      return;
    }
    await _authService.sendFriendRequest(
      currentUid: _currentUser!.uid,
      targetUid: targetUid,
    );
  }

  // accepts an incoming friend request from another user
  Future<void> acceptFriendRequest(String requesterUid) async {
    if (_currentUser == null) {
      return;
    }
    await _authService.acceptFriendRequest(
      currentUid: _currentUser!.uid,
      requesterUid: requesterUid,
    );
    _currentUser = await _authService.fetchUser(_currentUser!.uid);
    notifyListeners();
  }

  // declines a friend request from another user
  Future<void> declineFriendRequest(String requesterUid) async {
    if (_currentUser == null) {
      return;
    }
    await _authService.declineFriendRequest(
      currentUid: _currentUser!.uid,
      requesterUid: requesterUid,
    );
    _currentUser = await _authService.fetchUser(_currentUser!.uid);
    notifyListeners();
  }

  // remove friend
  Future<void> removeFriend(String friendUid) async {
    if (_currentUser == null) return;
    await _authService.removeFriend(
      currentUid: _currentUser!.uid,
      friendUid: friendUid,
    );
    _currentUser = await _authService.fetchUser(_currentUser!.uid);
    notifyListeners();
  }

  // fetches the UserModel for each uid and returns them as a list
  // used to display friend lists and requests by name
  Future<List<UserModel>> userModelOfUser(List<String> uids) async {
    final results = await Future.wait(
      uids.map((uid) => _authService.fetchUser(uid)),
    );
    return results.whereType<UserModel>().toList();
  }

}
