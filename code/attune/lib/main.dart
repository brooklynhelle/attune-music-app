import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; 

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// internationalizing shouldnt be that hard...

void main() async {
  // ensures flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        home: Consumer<AuthProvider>(
          // builder's params: context, auth (actual AuthProvider instance so state can be read), 
          // and _ is the child widget but we're not using it yet so the people on stackOverflow just put _
          
          // i just learned this so there are definitely some bug
          builder: (context, auth, _) {
            return auth.isAuthenticated
            ? const HomeScreen()
            : const LoginScreen();
          },
        ),
      ),
    );
  }
}