import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
 
import 'providers/auth_provider.dart';
import 'providers/spotify_provider.dart';
import 'providers/album_provider.dart';
import 'providers/leaderboard_provider.dart';
 
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp()

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/spotify_provider.dart';
import 'providers/album_provider.dart';
import 'providers/leaderboard_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SoundMatchApp());
}

class SoundMatchApp extends StatelessWidget {
  const SoundMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider has no dependencies — register first
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // SpotifyProvider needs AuthProvider — use ProxyProvider
        ChangeNotifierProxyProvider<AuthProvider, SpotifyProvider>(
          create: (ctx) => SpotifyProvider(ctx.read<AuthProvider>()),
          update: (ctx, auth, previous) => previous ?? SpotifyProvider(auth),
        ),

        // AlbumProvider and LeaderboardProvider are independent
        ChangeNotifierProvider(create: (_) => AlbumProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: MaterialApp(
        title: 'SoundMatch',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C47FF)),
          useMaterial3: true,
        ),
        // Auth guard: show home if logged in, login screen otherwise
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
 */