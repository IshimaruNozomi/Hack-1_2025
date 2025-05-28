import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/post.dart';
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
  late Future<List<Post>> _userPostsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _profileFuture = ApiService.getUserProfile(widget.userId);
    _userPostsFuture = ApiService.fetchPostsByUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('プロフィール')),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (profileSnapshot.hasError) {
            return Center(child: Text('プロフィールの読み込みに失敗しました'));
          } else if (!profileSnapshot.hasData) {
            return Center(child: Text('プロフィールが存在しません'));
          }

          final profile = profileSnapshot.data!;
          return Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                backgroundImage: NetworkImage(profile.iconUrl),
                radius: 50,
              ),
              SizedBox(height: 10),
              Text(profile.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(profile.bio),
              SizedBox(height: 10),
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
                      _loadData();
                    });
                  }
                },
                child: Text("編集"),
              ),
              SizedBox(height: 20),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("投稿一覧", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: FutureBuilder<List<Post>>(
                  future: _userPostsFuture,
                  builder: (context, postSnapshot) {
                    if (postSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (postSnapshot.hasError) {
                      return Center(child: Text('投稿の読み込みに失敗しました'));
                    } else if (!postSnapshot.hasData || postSnapshot.data!.isEmpty) {
                      return Center(child: Text('投稿がありません'));
                    }

                    final posts = postSnapshot.data!;
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: post.imageUrl.isNotEmpty
                                ? Image.network(post.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                : null,
                            title: Text(post.content),
                            subtitle: Text("投稿日: ${post.createdAt}"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
