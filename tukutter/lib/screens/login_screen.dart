import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'timeline_screen.dart'; // タイムライン画面（別途定義）
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  Future<User?> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Googleログインエラー: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ログイン")),
      body: Center(
        child: ElevatedButton(
          child: Text("Googleでログイン"),
          onPressed: () async {
            final user = await _signInWithGoogle(context);
            if (user != null) {
              // FastAPIにプロフィール情報を送る
              final response = await http.post(
                Uri.parse('http://<YOUR_API_HOST>:8000/create_profile'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'user_id': user.uid,
                  'name': user.displayName ?? '',
                  'bio': '',
                  'icon_url': user.photoURL ?? ''
                }),
              );

              if (response.statusCode == 200) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => TimelineScreen(userId: user.uid)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("サーバーへのプロフィール送信に失敗しました")),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ログインに失敗しました")),
              );
            }
          },
        ),
      ),
    );
  }
}
