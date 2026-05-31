
# Course Topics Applied and Inclusive Design

Course Topics Applied

1) Accessing Phone Sensors (GPS) 
    We used the geolocator package from earlier in the quarter to access a user's device coordinates. The PositionProvider requests location permissions, fetches user coords, and updates them every minute. It also passes updates to AuthProvider, which syncs the user's location to Firestore. Thinking about how to handle location data per user, as well as how to store it while also updating the main screen's UI based on the position state, helped us better understand provider-consumer relationships, as well as reliable data storage. 

2) Querying Web Services via APIs
    We used the Spotify Web API as well as the Geolocator API to fetch user data. This was our first time working with the Spotify API to such an extent, and navigating the OAuth flow was definitely one of the more challenging parts of this project. Handling tokens, as well as API response parsing, was a big learning experience. 

3) Drawing with Canvas
    We made a custom mascot (little purple monster listening to music) using Flutter's CustomPainter and Canvas. This was actually super fun and I had a good time learning about paths in Flutter. We had hoped to use the mascot in more places, but ran out of time due to debugging. He appears when the nearby users list is empty, whether because of disabled permissions or just nobody being around, to keep the user company. 

4) Data Persistence
    We used Firebase Firestore to store user data, including login credentials, Spotify data, location coordinates, friends, and friend requests. Our UserModel reads and writes to and from Firestore, which was a steep learning curve for us. Dealing with Firebase was something we did not expect to spend so much time debugging, as we experienced a lot of issues at just about every stage of development with data persistence and using asynchronous methods. 

5) Internationalization
    We implemented internationalization using Flutter's l10n system, including English and Spanish translations for all user-facing strings in the app. This required setting up ARB files and ensuring every user-facing hardcoded string was replaced with a localized reference, which we learned about from Flutter docs. This experience feels like it'll come in handy in the future, and I'm glad it was a requirement for this project since I had never thought about how translations on things like apps works before. 

6) Accessibility and Robustness
    We tested the app using Mac VoiceOver and the macOS Accessibility Inspector, which revealed widgets that were invisible or poorly labeled for screen readers. We fixed this using semantic wrappers, and we also audited color contrast, text size, and tap target sizes to meet accessibility standards. After these changes, the app was fully accessible and navigable via VoiceOver.


Inclusive Design Principles

Our design reflects several principles from the Inclusive Design lecture. We implemented high color contrast throughout the app, and avoided relying on color alone to convey information. We made tap targets large, and designed our screens with simple displays and few options for ease of use. We also did our best to make smaller state changes obvious, for example, a successful friend request is communicated both visually and via screen reader labels. The decision to make profiles anonymous by default is also intentionally inclusive: we designed for users who may have safety concerns, rather than assuming all users share the same comfort level with visibility and data privacy.

# Challenges, Changes, and Future Work

What Changed from Original Concept/Future Possibilities & 2 Future Areas of Work

1) Taste-based matching was something we considered in the beginning, but did not end up implementing due to challenges with Firebase, lack of time, and the potential complexity of this idea. Hopefully, in the future we will add some kind of similarity algorithm that scores and ranks nearby users based on overlap in top artists, tracks, and genres, so the most musically compatible people are listed on "nearby users" first.
2) Of course, broader usability is a huge component that we wanted to be able to implement but could not find a workaround for by the deadline. In the future, we hope to apply for Spotify's extended quota mode to remove the manual allowlisting requirement. We also want to eventually resolve the issues our app had with Android and other platform configurations, so the app is accessible beyond Apple devices. 

# Resources Used


Penelope

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
SWIPE TO REFRESH!!! yeahhh

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
SpanishDictionary.com
REFLECTION:
Used this to internationalize


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

