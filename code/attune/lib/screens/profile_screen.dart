import 'package:attune/l10n/app_localizations.dart';
import 'package:attune/models/user_model.dart';
import 'package:attune/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// The current user's profile screen.
// Shows profile picture, name, friends, friend requests, top artists, top tracks, and sign out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // controlls the profile picture URL input field
  final _pfpController = TextEditingController();

  // the user's bio
  String? _bioInput;

  // the user's name
  String? _nameInput;

  @override
  void dispose() {
    _pfpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // pfp, defaults to person icon if no value is given by user
            CircleAvatar(
              radius: 60,
              backgroundImage: auth.currentUser?.pfp != null
                  ? NetworkImage(auth.currentUser!.pfp!)
                  : null,
              child: auth.currentUser?.pfp == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pfpController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 
                AppLocalizations.of(context)!.profilePictureUrl,
                hintStyle: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ElevatedButton(
                onPressed: () => context.read<AuthProvider>().updatePfp(
                  _pfpController.text.trim(),
                ),
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: const TextStyle(fontSize: 18),
                  ),
              ),
            ),
            // box for name, defaults to username 
            const SizedBox(height: 20),
            Text(
              auth.currentUser?.name ?? auth.currentUser?.username ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // box for bio, optional profile addition, only shown if set by user
            const SizedBox(height: 25),
            if (auth.currentUser?.bio != null)
              Text(
                auth.currentUser!.bio!,
                style: const TextStyle(fontSize: 18),
              ),

            // used if user updates name
            TextField(
              onChanged: (value) => _nameInput = value,
              decoration: const InputDecoration(hintText: 'Change Name'),
            ),
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().updateName(_nameInput ?? ''),
              child: const Text('Save'),
            ),

            // used if user updates bio
            TextField(
              onChanged: (value) => _bioInput = value,
              decoration: const InputDecoration(hintText: 'Bio'),
            ),
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().updateBio(_bioInput ?? ''),
              child: const Text('Save'),
            ),

            // friends button
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ElevatedButton(
                onPressed: () {
                  final friends =
                      context.read<AuthProvider>().currentUser?.friends ?? [];
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => FutureBuilder<List<UserModel>>(
                      future: context.read<AuthProvider>().userModelOfUser(
                        friends,
                      ),
                      builder: (context, result) {
                        final users = result.data ?? [];
                        return users.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noFriendsYet,
                                  style: const TextStyle(fontSize: 18),  
                                ),
                              )
                            : ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (_, index) => ListTile(
                                  title: Text(
                                    users[index].username,
                                    style: const TextStyle(fontSize: 18),  
                                    ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.person_remove),
                                    onPressed: () => context
                                        .read<AuthProvider>()
                                        .removeFriend(users[index].uid),
                                  ),
                                ),
                              );
                      },
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.friends,
                  style: const TextStyle(fontSize: 18),  
                  ),
              ),
            ),
            // friend request button
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ElevatedButton(
                onPressed: () {
                  final requests =
                      context
                          .read<AuthProvider>()
                          .currentUser
                          ?.friendRequests ??
                      [];
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => FutureBuilder<List<UserModel>>(
                      future: context.read<AuthProvider>().userModelOfUser(
                        requests,
                      ),
                      builder: (context, result) {
                        final users = result.data ?? [];
                        return users.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.noFriendRequests,
                                  style: const TextStyle(fontSize: 18),  
                                ),
                              )
                            : ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (context, index) => ListTile(
                                  title: Text(
                                    users[index].username,
                                    style: const TextStyle(fontSize: 18),  
                                    ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () => context
                                            .read<AuthProvider>()
                                            .acceptFriendRequest(
                                              users[index].uid,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => context
                                            .read<AuthProvider>()
                                            .declineFriendRequest(
                                              users[index].uid,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                      },
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.friendRequests,
                  style: const TextStyle(fontSize: 18),
                  ),
              ),
            ),

            // displaying top artists
            const SizedBox(height: 25),
            Text(
              AppLocalizations.of(context)!.topArtists,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              itemCount: auth.topArtists.length,
              itemBuilder: (context, index) {
                final artist = auth.topArtists[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: artist.imageUrl != null
                        ? NetworkImage(artist.imageUrl!)
                        : null,
                    child: artist.imageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    artist.name,
                    style: const TextStyle(fontSize: 18),
                    ),
                );
              },
            ),

            // displaying top tracks
            const SizedBox(height: 25),
            Text(
              AppLocalizations.of(context)!.topTracks,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              itemCount: auth.topTracks.length,
              itemBuilder: (context, index) {
                final track = auth.topTracks[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: track.albumImageUrl != null
                        ? NetworkImage(track.albumImageUrl!)
                        : null,
                    child: track.albumImageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    track.name,
                    style: const TextStyle(fontSize: 20),
                    ),
                  subtitle: Text(
                    track.artistName,
                    style: const TextStyle(fontSize: 18),
                    ),
                );
              },
            ),

            // sign out button
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context)!.signOut,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
