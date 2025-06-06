import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // flutterfire configure で生成されるファイル
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/timeline_screen.dart';
import 'package:tukutter/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Login Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? userEmail;

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // ログインキャンセル

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    setState(() {
      userEmail = FirebaseAuth.instance.currentUser?.email;
    });
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    setState(() {
      userEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google ログイン')),
      body: Center(
        child: userEmail == null
            ? ElevatedButton(
                onPressed: signInWithGoogle,
                child: const Text('Googleでログイン'),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ログイン成功: $userEmail'),
                  TextButton( // タイムライン画面に遷移するボタン
                    onPressed:(){
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(
                          builder:(_) => TimelineScreen(
                            uid: FirebaseAuth.instance.currentUser!.uid, 
                            email: FirebaseAuth.instance.currentUser!.email ?? '',
                            name: FirebaseAuth.instance.currentUser!.displayName ?? '',
                          ),
                        ),
                      );
                    },
                    child: const Text('タイムラインへ'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signOut,
                    child: const Text('ログアウト'),
                  ),
                ],
              ),
      ),
    );
  }
}
