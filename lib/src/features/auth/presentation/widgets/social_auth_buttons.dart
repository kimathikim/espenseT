import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  Future<void> _googleSignIn(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during Google sign-in: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _appleSignIn(BuildContext context) async {
    try {
      final rawNonce = Supabase.instance.client.auth.generateRawNonce();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: rawNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw 'Could not find ID Token from Apple Credential.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during Apple sign-in: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _googleSignIn(context),
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Sign in with Google'),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _appleSignIn(context),
            icon: const Icon(Icons.apple),
            label: const Text('Sign in with Apple'),
          ),
        ],
      ],
    );
  }
}
