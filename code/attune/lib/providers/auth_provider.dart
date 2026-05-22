import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';


// This is Firebase Auth Provider; handles sign up/in/out & keeps track of user 
class AuthProvider extends ChangeNotifier {

  // instance of AuthService to do stuff with
  final AuthService _authService = AuthService();

  // are we waiting on a network call to finish?
  bool _dataLoading = false; 

  // keeps track of whether or not there's been an error
  bool _hasError = false;

  // the current user; nullable bc no user when app first loads
  UserModel? _currentUser;


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
    await _authService.signOut();
  }

  // signs user in using the authentication service 
  // with password and username given, of course
  Future<void> signIn({required String email, required String password}) async {
    await _authService.signIn(email: email, password: password);
  }

  // signs user in using the authentication service 
  // with password and username given, of course
  // nullable bc user might not exist yet/be signed in/up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
    required String university,
  }) async {
    return await _authService.signUp(
      email: email,
      password: password,
      username: username,
      university: university, // we might wanna do geolocation instead of this
    );
  }
}