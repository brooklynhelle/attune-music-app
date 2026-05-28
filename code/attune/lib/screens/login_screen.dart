import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';


// The login screen where you sign in, bare bones rn 
// Should navigate to home screen when complete
// Also has button that should navigate to sign up page; "no account? Sign up"
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

  // nullable message that shows up if login failed
  String? _errorMessage;

  // dispose to avoid memory leaks and what not
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await context.read<AuthProvider>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    // if the login failed & the wigdet is still on the screen, let user know and try again
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
            const SizedBox(height: 12),
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
              child: Text(AppLocalizations.of(context)!.signIn),
            ),
            if (_errorMessage != null) 
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text(AppLocalizations.of(context)!.noAccount),
            ),
            // test user bypass signin
            TextButton(
              onPressed: () => context.read<AuthProvider>().setTestUser(),
              child: const Text('Skip login (dev only)'),
            ),
          ],
        ),
      ),
    );
    
  }
}

  
