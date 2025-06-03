import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'timeline_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  // FastAPI のエンドポイント
  final String backendUrl = "http://localhost:8000/login"; // ← Androidエミュレータでは10.0.2.2に変更

  Future<Map<String, dynamic>?> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Firebase から ID トークンを取得
        final String? idToken = await user.getIdToken();
        if (idToken == null) throw Exception("IDトークン取得失敗");

        // FastAPI にトークン送信
        final response = await http.post(
          Uri.parse(backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id_token': idToken}),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          return data;
        } else {
          print("FastAPI ログイン失敗: ${response.body}");
          return null;
        }
      }
    } catch (e) {
      print("Googleログインエラー: $e");
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ログイン")),
      body: Center(
        child: ElevatedButton(
          child: Text("Googleでログイン"),
          onPressed: () async {
            final userData = await _signInWithGoogle(context);
            if (userData != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TimelineScreen(
                    uid: userData["uid"],
                    email: userData["email"],
                    name: userData["name"],
                  ),
                ),
              );
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
