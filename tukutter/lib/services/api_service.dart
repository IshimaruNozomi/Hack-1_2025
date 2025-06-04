import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';
import '../models/user_profile.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  // =============================
  // 投稿関連
  // =============================

  // 投稿を作成（POST /create_post）
  static Future<bool> sendPost({
    required String userId,
    required String content,
    required String imageUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/create_post');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'content': content,
        'image_url': imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      print("投稿成功: ${response.body}");
      return true;
    } else {
      print("投稿失敗: ${response.statusCode}");
      return false;
    }
  }

  // 投稿一覧を取得（GET /posts）
  static Future<List<Post>> fetchPosts() async {
    final url = Uri.parse('$_baseUrl/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Post.fromJson(json)).toList();
    } else {
      print("投稿一覧の取得に失敗: ${response.statusCode}");
      throw Exception("Failed to load posts");
    }
  }

  // 投稿を削除（DELETE /posts/{post_id}）
  static Future<void> deletePost(String postId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/posts/$postId'),
    );

    if (response.statusCode != 200) {
      print('投稿削除失敗: ${response.statusCode}');
      throw Exception('投稿の削除に失敗しました');
    }
  }

  // 指定ユーザーの投稿一覧（GET /users/{user_id}/posts）
  static Future<List<Post>> fetchPostsByUser(String userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Post.fromJson(json)).toList();
    } else {
      print("ユーザー投稿一覧の取得に失敗: ${response.statusCode}");
      throw Exception("Failed to load user posts");
    }
  }

  // =============================
  // プロフィール関連
  // =============================

  // プロフィール取得（GET /profile/{user_id}）
  static Future<UserProfile> getUserProfile(String userId) async {
    final url = Uri.parse('$_baseUrl/profile/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      print('プロフィール取得失敗: ${response.statusCode}');
      throw Exception('Failed to load profile');
    }
  }

  // プロフィール更新（PUT /update_profile/{user_id}）
  static Future<bool> updateUserProfile(UserProfile profile) async {
    final url = Uri.parse('$_baseUrl/update_profile/${profile.userId}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      print('プロフィール更新成功');
      return true;
    } else {
      print('プロフィール更新失敗: ${response.statusCode}');
      return false;
    }
  }

  // プロフィール画像をアップロード（POST /upload_profile_image/{user_id}）
  static Future<String?> uploadProfileImage(String userId, File imageFile) async {
    final url = Uri.parse('$_baseUrl/upload_profile_image/$userId');
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['url'];
    } else {
      print('画像アップロード失敗: ${response.statusCode}');
      return null;
    }
  }

  // ユーザー検索（GET /search_users?query=xxx）
  static Future<List<UserProfile>> searchUsers(String query) async {
    final url = Uri.parse('$_baseUrl/search_users?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UserProfile.fromJson(json)).toList();
    } else {
      print('ユーザー検索失敗: ${response.statusCode}');
      throw Exception('ユーザー検索に失敗しました');
    }
  }
}
