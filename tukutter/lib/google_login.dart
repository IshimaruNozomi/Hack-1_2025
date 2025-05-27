import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isSigningIn = false;

  Future<User?> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // ユーザーがサインインをキャンセル
        setState(() {
          _isSigningIn = false;
        });
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      setState(() {
        _isSigningIn = false;
      });

      return user;
    } catch (e) {
      setState(() {
        _isSigningIn = false;
      });
      print('Error signing in with Google: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isSigningIn
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _signInWithGoogle,
            child: const Text('Googleでログイン'),
          );
  }
}