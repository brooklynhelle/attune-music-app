
DATA DESIGN & FLOW


DATA DESIGN

The main data structure in our project is the UserModel class, which holds all the information about users of the app that isn't stored in Firebase. When a user is written to Firestore, a unique user ID (uid) is generated for them and used as the Firestore document ID. UserModel holds tha user's uid, as well as their username, email, name, profile picture, spotify id, list of top artists & top songs, latitude, longitude, friends, and friend requests. 

Each UserModel uses methods toMap() and fromMap() to read and writing to/from Firestore, since each user's document with each of those fields lives in Firestore and is accessible via uid. 

The actual spotify data objects, like SpotifyArtist, are re-called through the API each time a user signs in or up.


DATA FLOW

We used Flutter's Provider/Consumer framework to manage state changes in our app. There are two providers in the app that can be found in main.dart, and that use MultiProvider: AuthProvider, which holds the current UserModel & the user's Spotify data, and PositionProvider, which gets GPS coords of the user (when location permissions are granted).
 
In AuthProvider's constructor, it uses Firebase's authStateChange stream to update any changes in the auth state, like someone signing in or out, automatically updates currentUser and notifies listeners so the AuthProvider widgets know to rebuild. The Consumer<AuthProvider> in main controls which screen the user is shown from the point of opening the app to being completely signed in, since the state of auth determins whether or not a user needs to sign in/up and what to do when they sign out.

PositionProvider manages the GPS. It is connected to AuthProvider via ChangeNotifierProxyProvider in main, which we used instead of ChangeNotifierProvider because it lets one provider depend on another one, and  we needed this provider to update whenever AuthProvider updated. PositionProvider needs a reference to AuthProvider so it can call updateLocation() directly when the GPS returns new coords for the user every minute via a timer (thank you Food Finder!). 
When a location updates, the flow goes: PositionProvider gets GPS coords from API -> AuthProvider.updateLocation() is called, Firestore is written to so new location data is saved to user info -> notifyListeners() -> HomeScreen, which listens to both providers, re-runs _loadNearbyUsers(), which fetches nearby users from Firestore and reuilds the Nearby list on the main app screen. 
Our widgets use context.watch<AuthProvider> inside build methods for rebuilds, and context.read<AuthProvider> for button presses and stuff so they can call methods without necessarily triggering a rebuild. 