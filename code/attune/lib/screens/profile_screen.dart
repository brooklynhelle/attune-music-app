import 'package:attune/l10n/app_localizations.dart';
import 'package:attune/models/user_model.dart';
import 'package:attune/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _pfpController = TextEditingController();

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
            CircleAvatar(
              radius: 50,
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
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.profilePictureUrl,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ElevatedButton(
                onPressed: () => context.read<AuthProvider>().updatePfp(
                  _pfpController.text.trim(),
                ),
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ),
            // box for name
            const SizedBox(height: 20),
            Text(
              auth.currentUser?.name ?? auth.currentUser?.username ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // box for bio
            const SizedBox(height: 25),
            if (auth.currentUser?.bio != null)
              Text(
                auth.currentUser!.bio!,
                style: const TextStyle(fontSize: 15),
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
                                ),
                              )
                            : ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (_, index) => ListTile(
                                  title: Text(users[index].username),
                                ),
                              );
                      },
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.friends),
              ),
            ),
            // friend request button
            ElevatedButton(
              onPressed: () {
                final requests =
                    context.read<AuthProvider>().currentUser?.friendRequests ??
                    [];
                showModalBottomSheet(
                  context: context,
                  builder: (_) => FutureBuilder<List<UserModel>>(
                    future: context.read<AuthProvider>().userModelOfUser(
                      requests,
                    ),
                    builder: (context, result) {
                      final users = result.data ?? [];
                      return users.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noFriendRequests,
                              ),
                            )
                          : ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) => Row(
                                children: [
                                  Expanded(child: Text(users[index].username)),
                                  IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: () => context
                                        .read<AuthProvider>()
                                        .acceptFriendRequest(users[index].uid),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => context
                                        .read<AuthProvider>()
                                        .declineFriendRequest(users[index].uid),
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.friendRequests),
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
                  title: Text(artist.name),
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
                  title: Text(track.name),
                  subtitle: Text(track.artistName),
                );
              },
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
