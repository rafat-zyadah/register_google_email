import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions/auth_exception.dart';

class GoogleAuthDatasource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthDatasource({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ??
                  (throw AuthException(
                      "Missing GOOGLE_SERVER_CLIENT_ID in .env")),
            );

  /// Initiates Google sign-in and returns the ID token.
  Future<String?> signInAndGetIdToken() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) {
        throw AuthException(
            "Google Sign-In failed: User canceled the sign-in.");
      }

      final authTokens = await user.authentication;
      if (authTokens.idToken == null) {
        throw AuthException("Google Sign-In failed: No ID token received.");
      }

      return authTokens.idToken;
    } on PlatformException catch (e) {
      throw AuthException("Google Sign-In error: ${e.message}");
    } on Exception catch (e) {
      throw AuthException("Error during Google sign-in: ${e.toString()}");
    }
  }

  /// Disconnects the user from Google sign-in.
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } on Exception catch (e) {
      throw AuthException("Error during sign-out: ${e.toString()}");
    }
  }
}
