// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signIn => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginFailed =>
      'Login failed, try again after checking email and password';

  @override
  String get signUp => 'Sign up';

  @override
  String get username => 'Username';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get noAccount => 'Don\'t have an account? Sign up here';

  @override
  String get signupFailed => 'Unable to create account, please try again';

  @override
  String get topArtists => 'Top Artists';

  @override
  String get topTracks => 'Top Tracks';

  @override
  String get topGenres => 'Top Genres';

  @override
  String get sendFriendRequest => 'Send Friend Request';

  @override
  String get friends => 'Friends';

  @override
  String get friendRequests => 'Friend Requests';

  @override
  String get save => 'Save';

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get noFriendRequests => 'No friend requests';

  @override
  String get profilePictureUrl => 'Profile picture URL';

  @override
  String get errorLoadingUsers => 'Error loading nearby users: ';

  @override
  String get nearby => 'Nearby: ';

  @override
  String get locationDisabled => 'Location services are disabled.';

  @override
  String get allAlone => 'No users within 20 miles';

  @override
  String get signOut => 'Sign out';

  @override
  String get requestSent => 'Request Sent';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get connectSpotify => 'Connect Spotify';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';
}
