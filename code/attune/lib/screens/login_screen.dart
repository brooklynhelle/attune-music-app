import 'package:flutter/material.dart';


// The login screen where you log in
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    
  // object for email that tracks what user enters into text field
  final _emailController = TextEditingController();

  // object for password that tracks what user enters into text field
  final _passwordController = TextEditingController();

  // dispose to avoid memory leaks and what not
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    // UI
    return Placeholder();
  }
}

  
