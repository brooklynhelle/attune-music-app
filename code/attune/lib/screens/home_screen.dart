import 'package:attune/providers/position_provider.dart';
import 'package:attune/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/monster_painter.dart';

// The home screen where you go after you log in and link your spotify
// Displays a list of users within 20 miles of the current user, if location
// is known. Listens to AuthProvider so list refreshes when location updates
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // get instance of auth service to call the method that gets nearby users 
  final AuthService _authService = AuthService();

  // list of nearby users, filtered by location
  List<UserModel> _nearbyUsers = [];

  // whether or not list of nearby users data loaded successfully
  bool _loading = true;

  // reference to AuthProvider so we can dispose later 
  AuthProvider? _authProvider;

  // helps with not duplicating listeners in didChangeDependencies
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
  }

  // loads nearby users within 20 miles of current user, given location is shared
  // returns early if location is unavailable
  Future<void> _loadNearbyUsers() async {
    // you have to use context.read instead of context.watch since we're not in a builder
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    // return early if we don't have user's location -> can't do anything with it
    if (user?.latitude == null || user?.longitude == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final users = await _authService.getNearbyUsers(
        currentUid: user!.uid,
        lat: user.latitude!,
        long: user.longitude!,
      );
      // now query Firestore to get nearby users, pass in current user's uid and coords
      // if the load fails we need to handle it gracefully as Tal would say
      setState(() {
        _nearbyUsers = users;
        _loading =
            false; // this should trigger a rebuild once nearbyUsers are loaded successfully
      });
    } // otherwise tell user there was an error and set the state accordingly
    catch (e) {
      setState(
        () => _loading = false,
      ); // stops loading if there's an error
    }
  }


  // Adds a listener to AuthProvider so _loadNearbyUsers re-runs when the auth state changes
  // like after a location update
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_listenerAdded) {
      _authProvider = context.read<AuthProvider>();
      _authProvider!.addListener(_loadNearbyUsers);
      _listenerAdded = true;
    }

    _loadNearbyUsers();
  }

  // removes listener to avoid memory leaks and what not
  @override
  void dispose() {
    _authProvider?.removeListener(_loadNearbyUsers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    context.watch<PositionProvider>();

    // UI
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.nearby,
          style: const TextStyle(fontSize: 24),  
        ),
      ),
      body: _bodyHelper(user),
    );
  }

  // This helps the UI know what to display based on the information available.
  // coulda used a bunch of ternary operators in the widget tree but this is nicer
  Widget _bodyHelper(UserModel? user) {
    // if data is still loading, shows our little mascot to keep you company 
    if (_loading) {
      return Center(child: CircularProgressIndicator()); // classic
    } else if (user?.latitude == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: AppLocalizations.of(context)!.locationDisabled,
              child:CustomPaint(
                size: Size(300, 300),
                painter: MonsterPainter(),
              ),
            ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.locationDisabled,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        );
      } else if (_nearbyUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: AppLocalizations.of(context)!.allAlone,
                child:CustomPaint(
                  size: Size(200, 200),
                  painter: MonsterPainter(),
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                AppLocalizations.of(context)!.allAlone,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
);
    } else {
      return RefreshIndicator(
        onRefresh: _loadNearbyUsers,
        child: ListView.builder(
          itemCount: _nearbyUsers.length,
          itemBuilder: (context, index) {
            // list of homies
            final nearbyUser = _nearbyUsers[index];
            return Semantics(
              label: AppLocalizations.of(context)!.userTileSemantics(
                nearbyUser.name?? nearbyUser.username,
                nearbyUser.topArtists.isNotEmpty
                  ? nearbyUser.topArtists.first
                  : 'unknown',
              ),
              button: true,
              child: ListTile(
              leading: Semantics(
                label: AppLocalizations.of(context)!.profilePictureSemantics(
                  nearbyUser.name ?? nearbyUser.username,
                ),
                child: CircleAvatar(
                  backgroundImage: nearbyUser.pfp != null
                      ? NetworkImage(nearbyUser.pfp!)
                      : null,
                  child: nearbyUser.pfp == null ? const Icon(Icons.person) : null,
                ),
              ),
              title: Text(
                nearbyUser.name ?? nearbyUser.username,
                style: const TextStyle(fontSize: 20),
                ),
              subtitle: Text(
                nearbyUser.topArtists.isNotEmpty
                    ? nearbyUser.topArtists.first
                    : '',
                style: const TextStyle(fontSize: 18),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(user: nearbyUser),
                ),
              ),
              ),
            );
          },
        ),
      );
    }
  }
}
