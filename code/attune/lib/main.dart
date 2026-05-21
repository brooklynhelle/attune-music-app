import 'package:flutter/material.dart';
import 'models/user_model.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// internationalizing shouldnt be that hard...

void main() async {
  // ensures flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // get firebase goin
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // root of app
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