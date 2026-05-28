import 'package:attune/screens/spotify_connect_screen.dart';
import 'package:flutter/material.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; 
import 'screens/signup_screen.dart'; 

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'providers/position_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

// internationalizing shouldnt be that hard...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // get firebase goin - await bc nothing can happen before this happens
  await Firebase.initializeApp( // connects app to Firebase project
    options: DefaultFirebaseOptions.currentPlatform, // configs for platform (iOS for us)
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // root of app
  @override
  Widget build(BuildContext context) {
    // useful for managing multiple providers (we're gonna have a lot highkey)
    return MultiProvider( 
      providers: [
        // authentication provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // geolocation provider
        ChangeNotifierProvider(create: (_) => PositionProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
        },
        home: Consumer<AuthProvider>(
          // builder's params: context, auth (actual AuthProvider instance so state can be read), 
          // and _ is the child widget but we're not using it yet so the people on stackOverflow just put _
          
          // i just learned this so there are definitely some bug
          builder: (context, auth, _) {
            if (auth.isAuthenticated && auth.isSpotifyConnected) {
              return const HomeScreen();
            } else if (auth.isAuthenticated && !auth.isSpotifyConnected) {
              return const SpotifyConnectScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}