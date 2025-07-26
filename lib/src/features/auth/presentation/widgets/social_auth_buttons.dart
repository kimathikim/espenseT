import 'package:expensetracker/src/features/dashboard/presentation/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SupaSocialsAuth(
      socialProviders: const [
        OAuthProvider.google,
        OAuthProvider.apple,
      ],
      colored: true,
      redirectUrl: kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      onSuccess: (session) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }
}
