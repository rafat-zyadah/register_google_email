
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDatasource {
  final GoogleSignIn _googleSignIn;

  GoogleAuthDatasource({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              serverClientId: '37262958614-nq2cjc1b6k4ev2tecj530fsv7l21pf0h.apps.googleusercontent.com', // قم بتعديل Client ID هنا
            );

  Future<String?> signInAndGetIdToken() async {
    final user = await _googleSignIn.signIn();
    if (user == null) return null;

    final auth = await user.authentication;
    return auth.idToken;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }
}
