import 'package:attune/l10n/app_localizations.dart';
import 'package:attune/models/user_model.dart';
import 'package:attune/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _friendRequestSent = false;

  @override
  void initState() {
    super.initState();
    // check if we already sent a request
    final currentUid = context.read<AuthProvider>().currentUser?.uid;
    if (currentUid != null && widget.user.friendRequests.contains(currentUid)) {
      _friendRequestSent = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFriend = context.watch<AuthProvider>().currentUser?.friends.contains(widget.user.uid) ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.username)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // pfp
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.user.pfp != null ? NetworkImage(widget.user.pfp!) : null,
              child: widget.user.pfp == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(height: 20),

            // name
            Text(
              widget.user.name ?? widget.user.username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // bio
            if (widget.user.bio != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(widget.user.bio!, style: const TextStyle(fontSize: 15)),
              ),

            const SizedBox(height: 15),

            // button to send friend request
            ElevatedButton(
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
                  ListTile(title: Text(widget.user.topArtists[index])),
            ),
          ],
        ),
      ),
    );
  }
}
