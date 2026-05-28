import 'package:flutter/material.dart';


// The login screen where you log in
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    

  // dispose to avoid memory leaks and what not
  @override
  void dispose() {
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
      // UI
    return Scaffold(
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}