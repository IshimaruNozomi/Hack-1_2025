import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('プロフィール')),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            return Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profile.iconUrl),
                  radius: 50,
                ),
                Text(profile.name, style: TextStyle(fontSize: 20)),
                Text(profile.bio),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileEditScreen(profile: profile),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _profileFuture = ApiService.getUserProfile(widget.userId);
                      });
                    }
                  },
                  child: Text("編集"),
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('読み込み失敗'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
