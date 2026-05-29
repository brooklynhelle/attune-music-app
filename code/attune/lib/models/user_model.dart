// holds everything to do with User that Firebase's user doesn't contain:
// topGenres, spotifyID, displayName, location

// fields are public bc we need them like everywhere. maybe they shouldn't be?
class UserModel {
  // the user's uid (unique ID that firebase gives every user)
  final String uid;

  // the user's name
  final String? name;

  // the user's bio
  final String? bio;

  // the user's username
  final String username;

  // the user's profile picture
  final String? pfp;

  // the user's email
  final String email;

  // the user's top genres (comes from spotify)
  final List<String> topGenres;

  // the user's top artists (comes from spotify)
  final List<String> topArtists;

  // the user's spotify ID, null until user connects their spotify
  final String? spotifyId;

  // user's latitude - geolocation element, not final bc user moves around
  double? latitude;

  // user's longitude - geolocation element, not final bc user moves around
  double? longitude;

  // the user's friends
  List<String> friends;

  // the user's friend requests
  List<String> friendRequests;

  // constructs a user with the given info (do i have to list out all the fields?)
  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.name,
    this.bio,
    this.pfp,
    this.topGenres = const [],
    this.topArtists = const [],
    this.spotifyId,
    this.latitude,
    this.longitude,
    this.friends = const [],
    this.friendRequests = const [],
  });

  // write data to Firestore; must be sent out as a "map"
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'name': name,
      'bio': bio,
      'pfp': pfp,
      // 'uid': uid, // this will become the DOC ID, shouldnt be here
      'topGenres': topGenres,
      'topArtists': topArtists,
      'spotifyId': spotifyId,
      'latitude': latitude,
      'longitude': longitude,
      'friends': friends,
      'friendRequests': friendRequests,
    };
  }

  // Factory constructor for reading data from Firestore; comes in as we sent it out
  // if the user's topGenres list is undefined bc they haven't linked their Spotify,
  // topGenres is initialized as an empty list
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'],
      username: map['username'],
      name: map['name'],
      bio: map['bio'],
      pfp: map['pfp'],
      topGenres: List<String>.from(map['topGenres'] ?? []),
      topArtists: List<String>.from(map['topArtists'] ?? []),
      spotifyId: map['spotifyId'],
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      friends: List<String>.from(map['friends'] ?? []),
      friendRequests: List<String>.from(map['friendRequests'] ?? []),
    );
  }
}
