import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

// Shown after sign in/up when Spotify hasn't been connected yet.
// Prompts user to link their Spotify account before entering the app.
class SpotifyConnectScreen extends StatelessWidget {
  const SpotifyConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // app name
              const Text(
                'attune',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: 16),

              // lil catch phrase
              const Text(
                'find your people through music',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1DB954),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Color(0xFF1DB954),
                  size: 36,
                ),
              ),

              const SizedBox(height: 40),

              // description
              const Text(
                'Connect your Spotify to see your top artists, tracks, and find nearby listeners who share your taste.',
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 18,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // connect button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: auth.dataLoading
                      ? null
                      : () => context.read<AuthProvider>().connectSpotify(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF1DB954).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    elevation: 0,
                  ),
                  child: auth.dataLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.connectSpotify,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // error message if needed
              if (auth.hasError)
                Text(
                  AppLocalizations.of(context)!.somethingWentWrong,
                  style: TextStyle(
                    color: Color(0xFFFF4444),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),

              const Spacer(flex: 1),

              // to sign out
              TextButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: Text(
                  AppLocalizations.of(context)!.signOut,
                  style: TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}