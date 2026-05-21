// holds everything to do with User that Firebase's user doesn't contain:
// university, topGenres, spotifyID, displayName

// fields are public bc we need them like everywhere. maybe they shouldn't be?
class UserModel {

  // the user's uid (unique ID that firebase gives every user)
  final String uid;

  // the user's university
  final String university;

  // the user's username
  final String username;

  // the user's email
  final String email;

  // the user's top genres (comes from spotify)
  final List<String> topGenres; 

  // the user's spotify ID, null until user connects their spotify
  final String? spotifyId;

  // constructs a user with the given info (do i have to list out all the fields?)
  const UserModel({
    required this.uid,
    required this.university, // we might wanna do geolocation instead of this
    required this.username,
    required this.email,
    this.topGenres = const [],
    this.spotifyId,
  });

  // write data to Firestore; must be sent out as a "map"
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'university': university,
      // 'uid': uid, // this will become the DOC ID, shouldnt be here
      'topGenres': topGenres, 
      'spotifyId': spotifyId,
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
      university: map['university'],
      topGenres: List<String>.from(map['topGenres'] ?? []), 
      spotifyId: map['spotifyId'],
    );
  }



} 