import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

// Handles Spotify OAuth 2.0 with PKCE and data fetching.
// Nothing should call this directly except AuthProvider.
class SpotifyAuth {
  static const String _authEndpoint = 'https://accounts.spotify.com/authorize';
  static const String _tokenEndpoint = 'https://accounts.spotify.com/api/token';
  static const String _apiBase = 'https://api.spotify.com/v1';

  // These scopes let us read the user's profile and top music
  static const List<String> _scopes = [
    'user-top-read',
    'user-read-private',
    'user-read-email',
  ];

  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  // stored so we can use it during token exchange
  String? _codeVerifier; 

  StreamSubscription? _linkSubscription;

  // Returns true if we have a valid (non-expired) access token
  bool get isConnected =>
      _accessToken != null &&
      _tokenExpiry != null &&
      DateTime.now().isBefore(_tokenExpiry!);

  // ─── PKCE Helpers ────────────────────────────────────────────────────────────

  // Generates a random 64-char code verifier for PKCE
  String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(64, (_) => chars[random.nextInt(chars.length)]).join();
  }

  // Hashes the verifier into a code challenge using SHA-256
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // ─── OAuth Flow ──────────────────────────────────────────────────────────────

  // Kicks off Spotify login. Returns a SpotifyUser on success, throws on failure.
  Future<SpotifyUser> login() async {
    final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
    final redirectUri = dotenv.env['SPOTIFY_REDIRECT_URI'];

    if (clientId == null || redirectUri == null) {
      throw Exception(
          'Missing SPOTIFY_CLIENT_ID or SPOTIFY_REDIRECT_URI in .env');
    }

    // Generate and store PKCE verifier/challenge
    _codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(_codeVerifier!);

    // Build the Spotify auth URL
    final uri = Uri.parse(_authEndpoint).replace(queryParameters: {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': _scopes.join(' '),
      'code_challenge_method': 'S256',
      'code_challenge': codeChallenge,
    });

    // Launch Spotify login in browser
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Spotify login page');
    }

    // Wait for the redirect callback with the auth code
    final code = await _waitForCallback();

    // Exchange the code for tokens
    await _exchangeCodeForTokens(code, redirectUri, clientId);

    // Fetch and return the Spotify user profile
    return await fetchUserProfile();
  }

  // Listens for the deep link callback and extracts the auth code
  Future<String> _waitForCallback() async {
    final completer = Completer<String>();

    _linkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code']!;
        if (!completer.isCompleted) completer.complete(code);
      } else if (uri != null && uri.queryParameters.containsKey('error')) {
        if (!completer.isCompleted) {
          completer.completeError(
              Exception('Spotify login cancelled or denied'));
        }
      }
    }, onError: (err) {
      if (!completer.isCompleted) completer.completeError(err);
    });

    // Timeout after 5 minutes in case the user never completes login
    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => throw Exception('Spotify login timed out'),
    );
  }

  // Exchanges the auth code for access + refresh tokens
  Future<void> _exchangeCodeForTokens(
      String code, String redirectUri, String clientId) async {
    final response = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'code_verifier': _codeVerifier!,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Token exchange failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    _accessToken = data['access_token'];
    _refreshToken = data['refresh_token'];
    _tokenExpiry =
        DateTime.now().add(Duration(seconds: data['expires_in'] as int));

    _linkSubscription?.cancel();
  }

  // Refreshes the access token using the stored refresh token
  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) throw Exception('No refresh token available');

    final clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;

    final response = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': _refreshToken!,
        'client_id': clientId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Token refresh failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    _accessToken = data['access_token'];
    _tokenExpiry =
        DateTime.now().add(Duration(seconds: data['expires_in'] as int));
    if (data['refresh_token'] != null) {
      _refreshToken = data['refresh_token'];
    }
  }

  // ─── API Calls ───────────────────────────────────────────────────────────────

  // Makes an authenticated GET request, refreshing token if needed
  Future<Map<String, dynamic>> _get(String endpoint) async {
    if (!isConnected) await _refreshAccessToken();

    final response = await http.get(
      Uri.parse('$_apiBase$endpoint'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 401) {
      // Token might have just expired — try refreshing once more
      await _refreshAccessToken();
      final retry = await http.get(
        Uri.parse('$_apiBase$endpoint'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (retry.statusCode != 200) {
        throw Exception('Spotify API error: ${retry.body}');
      }
      return jsonDecode(retry.body);
    }

    if (response.statusCode != 200) {
      throw Exception('Spotify API error: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // Fetches the logged-in user's Spotify profile
  Future<SpotifyUser> fetchUserProfile() async {
    final data = await _get('/me');
    return SpotifyUser.fromJson(data);
  }

  // Fetches the user's top artists (default: 10, medium term ~6 months)
  Future<List<SpotifyArtist>> fetchTopArtists({
    int limit = 10,
    String timeRange = 'medium_term', // short_term, medium_term, long_term
  }) async {
    final data = await _get(
        '/me/top/artists?limit=$limit&time_range=$timeRange');
    return (data['items'] as List)
        .map((item) => SpotifyArtist.fromJson(item))
        .toList();
  }

  // Fetches the user's top tracks (default: 10, medium term ~6 months)
  Future<List<SpotifyTrack>> fetchTopTracks({
    int limit = 10,
    String timeRange = 'medium_term',
  }) async {
    final data =
        await _get('/me/top/tracks?limit=$limit&time_range=$timeRange');
    return (data['items'] as List)
        .map((item) => SpotifyTrack.fromJson(item))
        .toList();
  }

  // Extracts unique genre strings from the user's top artists
  Future<List<String>> fetchTopGenres({int limit = 20}) async {
    final artists = await fetchTopArtists(limit: limit);
    final genres = <String>{};
    for (final artist in artists) {
      genres.addAll(artist.genres);
    }
    return genres.toList();
  }

  // Clears all stored tokens (call on logout)
  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    _codeVerifier = null;
    _linkSubscription?.cancel();
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class SpotifyUser {
  final String id;
  final String displayName;
  final String email;
  final String? imageUrl;

  SpotifyUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.imageUrl,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    return SpotifyUser(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      imageUrl: images != null && images.isNotEmpty
          ? images[0]['url'] as String?
          : null,
    );
  }
}

class SpotifyArtist {
  final String id;
  final String name;
  final List<String> genres;
  final String? imageUrl;
  final int popularity;

  SpotifyArtist({
    required this.id,
    required this.name,
    required this.genres,
    this.imageUrl,
    required this.popularity,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    return SpotifyArtist(
      id: json['id'] as String,
      name: json['name'] as String,
      genres: List<String>.from(json['genres'] ?? []),
      imageUrl: images != null && images.isNotEmpty
          ? images[0]['url'] as String?
          : null,
      popularity: json['popularity'] as int? ?? 0,
    );
  }
}

class SpotifyTrack {
  final String id;
  final String name;
  final String artistName;
  final String? albumImageUrl;
  final int popularity;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artistName,
    this.albumImageUrl,
    required this.popularity,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    final artists = json['artists'] as List?;
    final album = json['album'] as Map<String, dynamic>?;
    final images = album?['images'] as List?;

    return SpotifyTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      artistName: artists != null && artists.isNotEmpty
          ? artists[0]['name'] as String
          : 'Unknown',
      albumImageUrl: images != null && images.isNotEmpty
          ? images[0]['url'] as String?
          : null,
      popularity: json['popularity'] as int? ?? 0,
    );
  }
}