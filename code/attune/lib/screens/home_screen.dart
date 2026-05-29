import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../l10n/app_localizations.dart';


// The home screen where you go after you log in and link your spotify
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // get instance of auth service to call the method that gets nearby users (from auth_service.dart)
  final AuthService _authService = AuthService();
  // list of nearby users, filtered by location
  List<UserModel> _nearbyUsers = [];
  // whether or not list of nearby users data loaded successfully, for user experience (fancy!)
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

  // loads nearby users within 20 miles of current user, given location is shared
  // I THINK all the possible failures/errors are handled... check my work please dear partner...
  Future<void> _loadNearbyUsers() async {
    // apparently you have to use context.read instead of context.watch since we're not in a builder
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;   

    // make sure we have user's location so we can load nearby users
    if (user?.latitude == null || user?.longitude == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      // if user hasn't enabled location, stop loading and return early bc not fetching anything
      // dont freaking forget that everything is nullable
      final users = await _authService.getNearbyUsers(
        currentUid: user!.uid, 
        lat: user.latitude!, 
        long: user.longitude!,
      );
      // now call firestore to get nearby users, pass in current user's uid and coords
      // if the load fails we need to handle it gracefully! as Tal would say
      setState(() {
        _nearbyUsers = users;
        _loading = false; // this should trigger a rebuild once nearbyUsers are loaded successfully
      });
    } // otherwise tell user there was an error and set the state accordingly 
    catch (e) {
      print('${AppLocalizations.of(context)!.errorLoadingUsers}$e');
      setState(() => _loading = false); // if we add a loading spinner this stops it
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // whenever the auth provider calls notifyListeners(), like after location updates, 
    // re load nearby users so the list refreshes based on user's new location
    context.read<AuthProvider>().addListener(_loadNearbyUsers);

    _loadNearbyUsers();
  }

  // dispose to avoid memory leaks and what not
  @override
  void dispose() {
    // 
    context.read<AuthProvider>().removeListener(_loadNearbyUsers);
    super.dispose();
  }


  @override 
  Widget build(BuildContext context) {
    // here we ARE in a builder so we use .watch instead of .read
    // idk why it took me so long to realize the difference
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;   

    // UI
    return Scaffold(
      appBar: AppBar(title: Text('${AppLocalizations.of(context)!.nearby}')),
      body: _bodyHelper(user),
    );
  }



  // This helps the UI know what to display based on the information available.
  // coulda used a bunch of ternary operators in the widget tree but this is nicer
  Widget _bodyHelper(UserModel? user) {
    // if data is still loading, show a loading icon or something for user experience
    if (_loading) {
      return Center(child: CircularProgressIndicator()); // classic
    } else if (user?.latitude == null) {
      return Center(child: Text('${AppLocalizations.of(context)!.locationDisabled}'));
    } else if (_nearbyUsers.isEmpty) {
      return Center(child: Text('${AppLocalizations.of(context)!.allAlone}'));      
    } else {
      return RefreshIndicator(
        onRefresh: _loadNearbyUsers,
        child: ListView.builder(
          itemCount: _nearbyUsers.length,
          itemBuilder: (context, index) {
            // list of homies
            return Placeholder();
          },
        ),
      );
    }
  }


}