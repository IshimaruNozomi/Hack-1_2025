import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'profile_edit_screen.dart';
import 'user_search_screen.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;
  late Future<List<Post>> _userPostsFuture;
  late Future<List<User>> _followingFuture;
  bool isOwnProfile = false;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String currentUserId = await ApiService.getCurrentUserId();
    setState(() {
      isOwnProfile = widget.userId == currentUserId;
      // _profileFuture, _userPostsFuture, _followingFutureが適切な型でFutureを受け取るようにAPIのレスポンス型を変更する必要があることがわかります。
      _profileFuture = ApiService.getUserProfile(widget.userId);
      _userPostsFuture = ApiService.fetchPostsByUser(widget.userId);
      _followingFuture = ApiService.getFollowing(widget.userId);
    });
    if (!isOwnProfile) {
      final List<User> followingUsers = await ApiService.getFollowing(currentUserId);
      setState(() {
        isFollowing = followingUsers.any((User u) => u.id == widget.userId);
      });
    }
  }

  void _toggleFollow() async {
    final String currentUserId = await ApiService.getCurrentUserId();
    if (isFollowing) {
      await ApiService.unfollowUser(currentUserId, widget.userId);
    } else {
      await ApiService.followUser(currentUserId, widget.userId);
    }
    setState(() {
      isFollowing = !isFollowing;
      _followingFuture = ApiService.getFollowing(currentUserId);
    });
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
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  backgroundImage: profile.iconUrl.isNotEmpty
                      ? NetworkImage(profile.iconUrl)
                      : null,
                  radius: 50,
                  child: profile.iconUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
                ),
                SizedBox(height: 10),
                Text(
                  profile.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(profile.bio),
                SizedBox(height: 10),

                if (isOwnProfile) ...[
                  ElevatedButton(
                    onPressed: () async {
                      final bool result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileEditScreen(profile: profile),
                        ),
                      );
                      if (result) {
                        _loadData();
                      }
                    },
                    child: Text("編集"),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserSearchScreen()),
                      );
                    },
                    child: Text("ユーザーを検索"),
                  ),
                ] else
                  ElevatedButton(
                    onPressed: _toggleFollow,
                    child: Text(isFollowing ? "フォロー解除" : "フォロー"),
                  ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("フォロー中", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                FutureBuilder<List<User>>(
                  future: _followingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("フォロー中のユーザーの取得に失敗しました"));
                    }

                    final List<User> users = snapshot.data!;
                    if (users.isEmpty) {
                      return Center(child: Text("フォロー中のユーザーはいません"));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final User user = users[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: (user.iconUrl != null && user.iconUrl!.isNotEmpty)
                                    ? NetworkImage(user.iconUrl!)
                                    : null,
                                radius: 30,
                                child: (user.iconUrl == null || user.iconUrl!.isEmpty)
                                    ? Icon(Icons.person)
                                    : null,
                              ),
                              SizedBox(height: 5),
                              Text(user.name ?? ''),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}