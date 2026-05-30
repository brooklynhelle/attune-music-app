import 'dart:io';
import 'package:attune/screens/main_screen.dart';
import 'package:attune/screens/spotify_connect_screen.dart';
import 'package:flutter/material.dart';
import 'package:uni_links_desktop/uni_links_desktop.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/position_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// initializes Firebase, loads variables, and registers the
// deep link protocol for macOS before launching the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // so Spotify can redirect back to the app on macOS
  if (Platform.isMacOS) {
    registerProtocol('attune');
  }

  // initialize firebase bc nothing can happen before this happens
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, 
  );

  runApp(const MainApp());
}

// root of app - sets up providers, sets up routes 
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // for managing multiple providers 
    return MultiProvider(
      providers: [
        // authentication provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // geolocation provider — manages GPS location, proxy provider used so 
        // PositionProvider can call AuthProvider to update location when GPS coords change
        ChangeNotifierProxyProvider<AuthProvider, PositionProvider>(
          create: (_) => PositionProvider(),
          update: (_, auth, position) {
            position!.setAuthProvider(auth);
              return position;
          },
        ),
      ],

      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
        },
        home: Consumer<AuthProvider>(
          // Consumer rebuilds the home widget whenever auth state changes
          // reroutes user to the correct screen based on state of auth & spotify connection
          builder: (context, auth, _) {
            if (auth.isAuthenticated && auth.isSpotifyConnected) {
              return const MainScreen();
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
