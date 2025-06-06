// lib/services/api_service.dart
import 'package:tukutter/models/post.dart';

class ApiService {
  // 投稿一覧を取ってくる（仮）
  static Future<List<Post>> fetchPosts() async {
    await Future.delayed(const Duration(seconds: 1)); // 擬似的な遅延
    return [
      Post(postId: 1, userId: '1', content:'投稿1', imageUrl: '', createdAt: '2025-06-06'), 
      Post(postId: 2, userId: '2', content: '投稿2', imageUrl: '', createdAt: '2025-06-06'), 
      Post(postId: 3, userId: '3', content: '投稿3', imageUrl: '', createdAt: '2025-06-06')
      ]; // 仮の投稿データ
  }

  // 投稿削除（仮）
  static Future<void> deletePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 擬似処理
    print('Deleted post $postId');
  }

  // 以下、他のAPIメソッドも必要なら同様に仮実装できます

  static Future<String> getCurrentUserId() async {
    return 'dummyUserId';
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return {'name': 'テストユーザー', 'userId': userId};
  }

  static Future<List<String>> fetchPostsByUser(String userId) async {
    return ['ユーザー${userId}の投稿1', 'ユーザー${userId}の投稿2'];
  }

  static Future<List<String>> getFollowing(String userId) async {
    return ['followedUser1', 'followedUser2'];
  }

  static Future<void> followUser(String currentUserId, String targetUserId) async {
    print('$currentUserId followed $targetUserId');
  }

  static Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    print('$currentUserId unfollowed $targetUserId');
  }

  static Future<List<String>> searchUsers(String query) async {
    return ['ユーザー検索結果1', 'ユーザー検索結果2'];
  }

  static Future<String> uploadProfileImage(String userId, dynamic imageFile) async {
    return 'https://example.com/profile_image.png';
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    print('プロフィール更新: $profileData');
    return true;
  }
}



// import 'package:flutter/material.dart';
// import '../models/user_profile.dart';
// import '../models/post.dart';
// import '../services/api_service.dart';
// import '../screens/profile_edit_screen.dart';
// import '../screens/user_search_screen.dart';
// import '../models/user.dart';

// class ProfileScreen extends StatefulWidget {
//   final String userId;

//   const ProfileScreen({required this.userId});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   late Future<UserProfile> _profileFuture;
//   late Future<List<Post>> _userPostsFuture;
//   late Future<List<User>> _followingFuture;
//   bool isOwnProfile = false;
//   bool isFollowing = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() async {
//     final currentUserId = await ApiService.getCurrentUserId();
//     setState(() {
//       isOwnProfile = widget.userId == currentUserId;
//       _profileFuture = ApiService.getUserProfile(widget.userId);
//       _userPostsFuture = ApiService.fetchPostsByUser(widget.userId);
//       _followingFuture = ApiService.getFollowing(widget.userId);
//     });
//     if (!isOwnProfile) {
//       final following = await ApiService.getFollowing(currentUserId);
//       setState(() {
//         isFollowing = following.contains(widget.userId);
//       });
//     }
//   }

//   void _toggleFollow() async {
//     final currentUserId = await ApiService.getCurrentUserId();
//     if (isFollowing) {
//       await ApiService.unfollowUser(widget.userId);
//     } else {
//       await ApiService.followUser(widget.userId);
//     }
//     setState(() {
//       isFollowing = !isFollowing;
//       _followingFuture = ApiService.getFollowing(currentUserId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('プロフィール')),
//       body: FutureBuilder<UserProfile>(
//         future: _profileFuture,
//         builder: (context, profileSnapshot) {
//           if (profileSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (profileSnapshot.hasError) {
//             return Center(child: Text('プロフィールの読み込みに失敗しました'));
//           } else if (!profileSnapshot.hasData) {
//             return Center(child: Text('プロフィールが存在しません'));
//           }

//           final profile = profileSnapshot.data!;
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(height: 20),
//                 CircleAvatar(
//                   backgroundImage: NetworkImage(profile.iconUrl),
//                   radius: 50,
//                 ),
//                 SizedBox(height: 10),
//                 Text(profile.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 5),
//                 Text(profile.bio),
//                 SizedBox(height: 10),

//                 if (isOwnProfile) ...[
//                   ElevatedButton(
//                     onPressed: () async {
//                       final result = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ProfileEditScreen(profile: profile),
//                         ),
//                       );
//                       if (result == true) {
//                         _loadData();
//                       }
//                     },
//                     child: Text("編集"),
//                   ),
//                   SizedBox(height: 8),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const UserSearchScreen()),
//                       );
//                     },
//                     child: Text("ユーザーを検索"),
//                   ),
//                 ] else
//                   ElevatedButton(
//                     onPressed: _toggleFollow,
//                     child: Text(isFollowing ? "フォロー解除" : "フォロー"),
//                   ),

//                 SizedBox(height: 20),
//                 Divider(),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text("フォロー中", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 SizedBox(
//                   height: 100,
//                   child: FutureBuilder<List<User>>(
//                     future: _followingFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Center(child: Text("フォロー中のユーザーの取得に失敗しました"));
//                       }

//                       final users = snapshot.data ?? [];
//                       return ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: users.length,
//                         itemBuilder: (context, index) {
//                           final user = users[index];
//                           return Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundImage: NetworkImage(user.iconUrl ?? ''),
//                                   radius: 30,
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(user.name ?? '', style: TextStyle(fontSize: 12)),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 Divider(),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text("投稿", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 FutureBuilder<List<Post>>(
//                   future: _userPostsFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(child: Text("投稿の取得に失敗しました"));
//                     }

//                     final posts = snapshot.data ?? [];
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: posts.length,
//                       itemBuilder: (context, index) {
//                         final post = posts[index];
//                         return Card(
//                           child: ListTile(
//                             title: Text(post.content),
//                             subtitle: post.imageUrl != null
//                                 ? Image.network(post.imageUrl!)
//                                 : null,
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
