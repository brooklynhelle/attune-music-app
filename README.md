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
Location sharing (when prompted) must be granted for the nearby users feature to work


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
user_profile_screen.dart --> the current user's profile, shows profile picture and the option to update your pfp (only add-able via url), top artists and tracks, friends and friend requests, and the sign out button. 
spotify_connect_screen.dart --> shown after a successful sign in/up, prompts user to link their Spotify account

lib/widgets/
monster_painter.dart --> this is a little monster logo that we made using Paint, he shows up when your  location services aren't enabled to keep you company since you're all alone in your music taste 

lib/l10n/
contains internationalization strings for all text seen by users, our app supports English and Spanish. 

API keys
SPOTIFY_CLIENT_ID=74011935005a418aa5e108378878ce8a
SPOTIFY_REDIRECT_URI=attune://callback
this is also in the .env file which should be submitted with everything else/accessible on github


# Resources 

CONSULTED: 
firebase.google.com/docs/firestore/data-model
firebase.google.com/docs/firestore/manage-data/add-data
firebase.google.com/docs/firestore/query-data/get-data
firebase.google.com/docs/flutter/setup
https://firebase.google.com/docs/auth/flutter/start
REFLECTION: 
We had used firebase before in another class very briefly, which is how we knew we wanted to use it here - but we still had a lot of reading to do before we could implement anything lol. 

CONSULTED: 
https://dart.dev/libraries/async/using-streams
https://mailharshkhatri.medium.com/mastering-streams-in-dart-and-flutter-a-comprehensive-guide-06df7c5b400b
REFLECTION: 
after googling "how do i handle logins for the app im developing using flutter? It became apparent that I needed to learn about Streams in dart. This was really helpful for getting the authentication portion of the app set up, since I needed something that would allow the app to react automatically whenever the login state changed. 

CONSULTED: 
https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://pub.dev/documentation/provider/latest/provider/MultiProvider-class.html&ved=2ahUKEwjJ5qDe-MuUAxXsGTQIHXatGDYQFnoECA0QAQ&usg=AOvVaw0Aff6nmwJvaVajFCIwpNLX
REFLECTION: 
I needed to learn about multi providers since the top search result for "How do I handle multiple providers in flutter" told me I should use MultiProvider

CONSULTED: 
https://vibe-studio.ai/insights/integrating-oauth2-pkce-flows-in-flutter-apps
REFLECTION: 
Getting set up with the Spotify API

CONSULTED: 
https://support.macincloud.com/support/solutions/articles/8000123702-resolving-xcode-unsupported-option-g-for-target-arm64-apple-ios10-0-error-on-macincloud-server
REFLECTION: 
I kept not being able to run the build anywhere so I pasted the error into google and this website told me how to edit my Podfile to fix it, which worked 

CONSULTED: 
https://medium.com/@crystalize0106/how-to-use-provider-context-read-watch-and-select-1e41938fdf62
REFLECTION: 
When setting up the login page and user authentication, I decided to use context.watch and what not to help me navigate the outcomes possible from prompting a user to sign in/out/up

CONSULTED: 
https://docs.flutter.dev/ui/internationalization
REFLECTION: 
I learned about how to internationalize my code, as well as what that even means, from the flutter docs beofre implementing the necessary changes

CONSULTED: 
https://www.google.com/url?sa=t&source=web&rct=j&url=https%3A%2F%2Fdocs.flutter.dev%2Fui&ved=0CAYQ1fkOahcKEwiQiIfD3NqUAxUAAAAAHQAAAAAQEw&opi=89978449
https://docs.flutter.dev/cookbook/navigation/navigation-basics
REFLECTION: 
I consulted these when learning about how to get the UI to switch screens based on the auth state

CONSULTED: 
https://medium.com/@abdurrehman-520/unlock-the-power-of-geofencing-in-flutter-with-haversine-formula-21b8203b1a5
https://github.com/yeradis/haversine.dart
https://pub.dev/documentation/flutter_map_math/latest/
https://dart.dev/libraries/dart-math
REFLECTION:
These are all the resources we used to imlpement the list that shows users nearby to the current user. To generate the list of neaby users, we fetched all users, and then used the Haversine formula to filter by distance to generate the list of closest nearby users. We thought about using a map and then using the FlutterMapMath functions to get the distance between two users, but we liked the more math-y, fewer dependencies way. I initially had no idea how to implement the math part for this part of the app, but luckily a lot of other people have done this before and written articles about it lol. Already having queried the geolocation API for food finder made this a lot easier and more convenient than I expected getting the data to be. Haversine is perfect for this because you can give it lat and long coords, which is what the Geolocator API provides for a user, and it can return miles, which is what we used it for. 

CONSULTED: 
https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
REFLECTION:
SWIPE TO REFRESH!!! hell yeah

CONSULTED: 
"ChangeNotifierProxyProvider vs ChangeNotifierProvider" in google - the AI overview directed me to:
https://stackoverflow.com/questions/75805196/how-does-changenotifierproxyprovider-work-in-flutter
https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProvider-class.html
https://stackoverflow.com/questions/59883666/flutter-provider-changenotifierprovider-question
REFLECTION:
This was helpful when updating my UI based on whether or not the user enabled location sharing, 
since so much of the app relies on this being enabled but we also needed to handle the cases where the user denied permissions

CONSULTED: 
https://api.flutter.dev/flutter/widgets/State/didChangeDependencies.html
REFLECTION:
Google told me this would help with having stuff happen in my build class before and after dependency changes, so I used it 

CONSULTED: 
REFLECTION:

CONSULTED: 
REFLECTION:

CONSULTED: 
REFLECTION:

CONSULTED: 
REFLECTION:

CONSULTED: 
REFLECTION:

CONSULTED: 
REFLECTION:

CONSULTED: 
REFLECTION:




# attune

Brooklyn

Resources used:

Most of the code regarding the Spotify API is reused from a
project I worked on earlier this year. I made sure it was okay
to do this with an Ed post.

To help make the user's profile picture:
https://api.flutter.dev/flutter/material/CircleAvatar-class.html
https://api.flutter.dev/flutter/material/TextField-class.html

Used this to make the name and bio boxes for the profile page:
https://api.flutter.dev/flutter/widgets/SizedBox-class.html

Used these to display top artists and tracks:
https://api.flutter.dev/flutter/widgets/ListView-class.html
https://api.flutter.dev/flutter/material/ListTile-class.html
https://api.flutter.dev/flutter/widgets/ScrollView/shrinkWrap.html
https://api.flutter.dev/flutter/widgets/NeverScrollableScrollPhysics-class.html

For the nav bar:
https://api.flutter.dev/flutter/widgets/BottomNavigationBarItem-class.html

To let the user view and scroll through their friends:
https://api.flutter.dev/flutter/material/showModalBottomSheet.html

Used FieldValue, a FireStore helper to update the arrays with the uid for friend requests:
https://pub.dev/documentation/cloud_firestore/latest/cloud_firestore/FieldValue-class.html

Used leading with a ListTile to make the nearby user's pfp appear 
to the left of the rest of the content:
https://api.flutter.dev/flutter/material/AppBar/leading.html
Also used trailing to do the opposite and make content appear to the right
of the rest of the content:
https://api.flutter.dev/flutter/material/ListTile/trailing.html

To transition from the homescreen to the view other user's profile screen, I found this:
https://docs.flutter.dev/cookbook/navigation/navigation-basics
and from there it recommended using MaterialPageRoute, so I clicked on it and it took me here:
https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html?_gl=1*og0ww9*_ga*MjMwNjk3MTY2LjE3Nzc0Mzk4Njg.*_ga_04YGWK0175*czE3ODAwODU4OTYkbzIxJGcxJHQxNzgwMDg2NDQxJGo0NiRsMCRoMA..

To get the username for friendrequests, I used FutureBuilder. It allows me
to wait for Firestore results to come back so I can use them instead of the users uid:
https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html

I used mounted and popUntil and isFirst to navigate to the main screen after sign up/log in:
https://api.flutter.dev/flutter/widgets/State/mounted.html
mounted checks to see if the widget is still on the screen once submit finishes
https://api.flutter.dev/flutter/widgets/Navigator/popUntil.html
popUntil pops screens from navigation stack until isFirst is true
https://api.flutter.dev/flutter/widgets/Route/isFirst.html
returns true when the route is the screen on the bottom of the navigation stack