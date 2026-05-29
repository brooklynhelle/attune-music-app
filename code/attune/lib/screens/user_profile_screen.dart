import 'package:attune/l10n/app_localizations.dart';
import 'package:attune/models/user_model.dart';
import 'package:attune/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatelessWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.username)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // pfp
            CircleAvatar(
              radius: 50,
              backgroundImage: user.pfp != null ? NetworkImage(user.pfp!) : null,
              child: user.pfp == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(height: 20),

            // name
            Text(
              user.name ?? user.username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // bio
            if (user.bio != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(user.bio!, style: const TextStyle(fontSize: 15)),
              ),

            const SizedBox(height: 15),

            // button to send friend request
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().sendFriendRequest(user.uid),
              child: Text(AppLocalizations.of(context)!.sendFriendRequest),
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
              itemCount: user.topArtists.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(user.topArtists[index]),
              ),
            ),
          ]
        )
      )
    );
  }
}
