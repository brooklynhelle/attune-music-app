import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';


// Sign in screen, navigates back to main on success to prompt user for spotify link & location
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

  // nullable message that shows up if login failed - resets after each 
  // sign-in attempt
  String? _errorMessage;

  // dispose to avoid memory leaks and what not
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // attempts sign in / other redirects or shows an error message
  Future<void> _submit() async {
    setState(() => _errorMessage = null); // clear any previous error
    final success = await context.read<AuthProvider>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    // navigate back to root so Consumer in main.dart can redirect
    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    // if the login failed & the widget is still on the screen, let user know and try again
    if (!success && mounted) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.loginFailed;
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
            const SizedBox(height: 18),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(
                AppLocalizations.of(context)!.signIn,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (_errorMessage != null) 
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: 
              Text(
                AppLocalizations.of(context)!.noAccount,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
    
  }
}
