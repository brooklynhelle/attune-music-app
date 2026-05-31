import 'package:attune/l10n/app_localizations.dart';
import 'package:attune/models/user_model.dart';
import 'package:attune/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// Profile screen for another user, accessed by tapping them in the nearby users list.
// Shows their profile picture, name, bio, and top artists.
// Allows sending a friend request if not already friends.
class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  // true if a friend request has already been sent to this user
  bool _friendRequestSent = false;

  @override
  void initState() {
    super.initState();
    // check on load; whether or not we had already sent a request before
    final currentUid = context.read<AuthProvider>().currentUser?.uid;
    if (currentUid != null && widget.user.friendRequests.contains(currentUid)) {
      _friendRequestSent = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch so the button updates if friend status updates
    final isFriend = context.watch<AuthProvider>().currentUser?.
      friends.contains(widget.user.uid) ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.username)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: AppLocalizations.of(context)!.profilePictureSemantics(
                widget.user.name ?? widget.user.username,
              ),
              // pfp
              child: CircleAvatar(
                radius: 50,
                backgroundImage: widget.user.pfp != null ? NetworkImage(widget.user.pfp!) : null,
                child: widget.user.pfp == null ? const Icon(Icons.person) : null,
              ),
            ),
            const SizedBox(height: 20),

            // name, defaults to username
            Text(
              widget.user.name ?? widget.user.username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // bio, optional, only shown if set by user
            if (widget.user.bio != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(widget.user.bio!, style: const TextStyle(fontSize: 15)),
              ),

            const SizedBox(height: 15),

            // button to send friend request
            Semantics(
              button: true,
              child: ElevatedButton(
                onPressed: isFriend || _friendRequestSent ? null : () {
                  context.read<AuthProvider>().sendFriendRequest(widget.user.uid);
                  setState(() => _friendRequestSent = true);
                },
                child: Text(isFriend
                  ? AppLocalizations.of(context)!.friends
                  : _friendRequestSent
                    ? AppLocalizations.of(context)!.requestSent
                    : AppLocalizations.of(context)!.sendFriendRequest),
              ),
            ),
            
            const SizedBox(height: 20),

            // display user's top artists
            Text(
              AppLocalizations.of(context)!.topArtists,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.user.topArtists.length,
              itemBuilder: (_, index) =>
                  ListTile(title: Text(widget.user.topArtists[index], textAlign: 
                    TextAlign.center,)),
            ),
          ],
        ),
      ),
    );
  }
}
