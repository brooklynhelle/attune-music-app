import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/position_provider.dart';


// Account creation screen, triggers location permission request after a successful sign in/up
// then navigates back to home screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
    
  // object for email that tracks what user enters into text field
  final _emailController = TextEditingController();

  // object for username that tracks what user enters into text field
  final _usernameController = TextEditingController();

  // object for password that tracks what user enters into text field
  final _passwordController = TextEditingController();

  // nullable message that shows up if registering account failed
  String? _errorMessage;

  // dispose to avoid memory leaks and what not
  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // attempts account creation, requests location permission on success,
  // then navigates back to home. Shows error message otherwise
  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final user = await context.read<AuthProvider>().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text,
    );
    if (user != null) {
      // trigger location permission request 
      try {
        await context.read<PositionProvider>().determinePosition();
      } catch (e) {
        // so the app doesn't crash if user denies permissions
      }
      // navigate back to root for redirect
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
    // if the sign up failed & the widget is still on the screen, let user know and try again
    if (user == null && mounted) { // mounted == widget is still on screen (safety check)
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.signupFailed;
      });
    } 
  }

  @override 
  Widget build(BuildContext context) {
    // UI
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email
              ),
            ),
            const SizedBox(height: 24), // spacing
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password
              ),
            ),
            const SizedBox(height: 24), // spacing
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.username
              ),
            ),
            const SizedBox(height: 24), // spacing
            ElevatedButton(
              onPressed: _submit,
              child: Text(
                AppLocalizations.of(context)!.signUp,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (_errorMessage != null) 
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text(
                AppLocalizations.of(context)!.alreadyHaveAccount,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
    
  }
}
