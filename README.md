# Starting Repo Structure
You should create a new flutter project (`flutter create -e <project name>`) *inside* the `code` directory.
Put your docs (except README) in the `docs` directory.

Once you start adding things to the `code` and `docs` directories, delete the files named `delete_this_file.txt` from each of those directories, repectively. They are temporary placeholders, because git does not allow the addition of empty directories to a repo.

# Documentation

PURPOSE OF APP

The purpose of our app is to foster community among people nearby eachother, like on college campuses, with similar music taste.  


ABOUT THIS APP

Attune addresses the difficulty of finding people with shared music taste in real life. After linking your Spotify account, Attune reads your top artists, tracks, and genres, then uses your location to surface nearby users with overlapping taste. You can view other users' profiles and send friend requests.


HOW TO BUILD & RUN THE APP

To build & run the app, cd code/attune, then run flutter pub get, and then either run flutter run -d macos OR flutter run with the target being your phone (either wirelessly connected or connected via a cable to your machine). Once the build builds and the app launches, how to sign in should be obvious. Unfortunately, the amount of issues we ran into when trying to configure the app for other platforms would take more time to figure out than we had available to us when working on this project. 


REQUIREMENTS

A spotify account that you can log into (doesn't necessarily have to be yours)
An iPhone OR mac computer
Location sharing (when prompted) must be granted for the nearby users feature to work. If user is not prompted, they should turn their location services for attune on in settings.
Since this app is still in the development stage, Spotify's API requires each user's Spotify email to be added to the development page.
It can only hold up to 5 users, but students can add their email for a quick demo and then remove it so others can do the same.


PROJECT LAYOUT/STRUCTURE

lib/models/
user_model.dart --> the user object, contains relevant user data including: uid (firestore's unique ID for each user), username, email, Spotify ID, top artists & top tracks, location (lat and long coords), and friends. Also, contains toMap() and fromMap() calls to/from Firestore for storing and accessing user data. 

lib/providers/
auth_provider.dart --> manages authentication state, such as sign in/out/up, Spotify OAuth flow, friend requests, profile picture updates, and location updates. It also makes the current user, spotify data, and the auth state accessible from the widget tree via the ChangeNotifier. 
position_provider.dart --> manages the GPS location using the geolocator package. Requests permissions, fetches coordinates initially and then every 60 seconds, and calls the auth provider method for updating user location when the position updates. 

lib/services/
auth_service.dart --> handles all Firebase Auth and Firestore operations: sign in/up/out, fetching and updating user docs, friend request logic, and the nearby users query (uses the haversine formula to calculate distance between 2 users).
spotify_auth.dart --> Handles the spotify login flow, and the calls to the Spotify API that fetch the user's top artists and tracks

lib/screens/
login_screen.dart --> email/password sign in screen. Displays error if sign in fails, redirects to Spotify account link screen if login was successful
signup_screen.dart --> account creation screen. Displays error if sign in fails, redirects to Spotify account link screen if login was successful, then triggers location permission request 
home_screen.dart --> displays nearby users within 20 miles, listens to both Auth and Position provider 
main_screen.dart --> bottom nav bar that allows you to switch between home and profile screens
profile_screen.dart --> the current user's profile, shows profile picture and the option to update your pfp (only add-able via url), top artists and tracks, friends and friend requests, and the sign out button. 
user_profile_screen.dart --> used to view another user's profile, shows profile picture, name, bio, and top artists. Can request to be friends on this page.
spotify_connect_screen.dart --> shown after a successful sign in/up, prompts user to link their Spotify account

lib/widgets/
monster_painter.dart --> this is a little monster logo that we made using Paint, he shows up when your  location services aren't enabled to keep you company since you're all alone in your music taste 

lib/l10n/
contains internationalization strings for all text seen by users, our app supports English and Spanish. 

API keys
This project requires a .env file with SPOTIFY_CLIENT_ID and SPOTIFY_REDIRECT_URI. 
Do not commit your .env file — it's excluded via .gitignore.

