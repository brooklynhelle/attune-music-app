import 'package:attune/services/spotify_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// This is Firebase Auth Provider; handles sign up/in/out & keeps track of user
class AuthProvider extends ChangeNotifier {
  // instance of AuthService to do stuff with
  final AuthService _authService = AuthService();

  // instance of SpotifyAuth to get Spotify data with
  final SpotifyAuth _spotifyAuth = SpotifyAuth();

  // are we waiting on a network call to finish?
  bool _dataLoading = false;

  // keeps track of whether or not there's been an error
  bool _hasError = false;

  // the current user; nullable bc no user when app first loads
  UserModel? _currentUser;

  // Spotify data
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
  // --> should the program show the home vs login screen
  bool get isAuthenticated => _currentUser != null;

  // returns whether or not spotify is connected
  bool get isSpotifyConnected => _spotifyAuth.isConnected;

  // returns user's Spotify profile
  SpotifyUser? get spotifyUser => _spotifyUser;

  // returns the user's top Spotify artists
  List<SpotifyArtist> get topArtists => _topArtists;

  // returns the user's top Spotify tracks
  List<SpotifyTrack> get topTracks => _topTracks;

  // returns the user's top Spotify genres
  List<String> get topGenres => _topGenres;

  // provider for authentication
  // This updates _currentUser according to auth state changes (someone signs up/in/out)
  // when someone signs in, Firebase emits a User which we use to fetch their UserModel, _currentUser gets set
  // when someone signs out, Firebase emits null so then _currentUser gets set to null
  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      // if no user exists yet/login fails, current user is null
      if (user == null) {
        _currentUser = null;
      }
      // otherwise, set current user
      else {
        _currentUser = await _authService.fetchUser(user.uid);
      }
      // tells the widgets consuming this provider to rebuild bc auth state changed
      notifyListeners();
    });
  }

  // signs user out using the authentication service
  Future<void> signOut() async {
    _spotifyAuth.logout();
    _spotifyUser = null;
    _topArtists = [];
    _topTracks = [];
    _topGenres = [];
    await _authService.signOut();
  }

  // signs user in using the authentication service
  // with password and username given, of course
  // returns a bool so we know if login was successful
  Future<bool> signIn({required String email, required String password}) async {
    try {
      // if login succeeds, no issues yay
      print('Attempting sign in with: $email');
      await _authService.signIn(email: email, password: password);
      print('Sign in successful');

      // signing in wouldnt work until I manually updated the currentUser this way instead of
      // relying on firebase to actually work
      final firebaseUser = await _authService.getCurrentUser();
      print('Current user: $firebaseUser');
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

        print('UserModel fetched: $_currentUser');
        notifyListeners();
      }
      return true;
    } catch (e) {
      // if the login was unsuccessful, notify listeners and return false
      // so error message can display & user can try again
      print('Sign in error: $e');
      _hasError = true;
      notifyListeners();
      return false;
    }
  }

  // hardcoded test user bc we can't get firebase to work with user auth
  void setTestUser() {
    _currentUser = UserModel(
      uid: 'test-uid',
      email: 'test@test.com',
      username: 'testuser',
      latitude: 47.6553, // UW Seattle coordinates
      longitude: -122.3035,
    );
    notifyListeners();
  }

  // updates user's location, like after permissions are enabled
  Future<void> updateLocation(double lat, double long) async {
    if (_currentUser == null) return;
    await _authService.updateLocation(_currentUser!.uid, lat, long);
    _currentUser!.latitude = lat;
    _currentUser!.longitude = long;
    notifyListeners();
    // any widget watching AuthProvider and displaying location-based info
    // needs to know so they can rebuild
  }

  // signs user in using the authentication service
  // with password and username given, of course
  // nullable bc user might not exist yet/be signed in/up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
    String university = '',
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
    catch (e, stackTrace) {
      _hasError = true;
      print('Signup error: $e');
      print('Stack trace: $stackTrace');
      notifyListeners();
      return null;
    }
  }

  // launches Spotify OAuth login, then gets top artists/tracks/genres
  // this gets called after the user has signed up
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
    } catch (e) {
      _hasError = true;
    } finally {
      _dataLoading = false;
      notifyListeners();
    }
  }

  // refreshes top artists/tracks/genres from Spotify
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

  // updates the user's profile picture URL and refreshes the current user
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

  // accepts a friend request from another user
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

  // // search for users by username
  // Future<List<UserModel>> searchUsers(String query) async {
  //   return await _authService.searchUsers(query);
  // }

  // // search for artists
  // Future<List<UserModel>> searchUsersByArtist(String artist) async {
  //   return await _authService.searchUsersByArtist(artist);
  // }
}
