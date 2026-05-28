# Starting Repo Structure
You should create a new flutter project (`flutter create -e <project name>`) *inside* the `code` directory.
Put your docs (except README) in the `docs` directory.

Once you start adding things to the `code` and `docs` directories, delete the files named `delete_this_file.txt` from each of those directories, repectively. They are temporary placeholders, because git does not allow the addition of empty directories to a repo.

# Documentation

I had to change the platform configuration to only be iOS, I previously had all of them selected. 
It was causing issues with running the app so I changed it. If we wanna change it back just run flutterfire configure in terminal and choose this project, then override old changes

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
