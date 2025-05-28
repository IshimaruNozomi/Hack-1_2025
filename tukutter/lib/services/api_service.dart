import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000'; // FastAPIのURL（適宜変更）

  // 投稿データをFastAPIへ送信（POST /create_post）
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
      print("投稿一覧の取得に失敗しました: ${response.statusCode}");
      throw Exception("Failed to load posts");
    }
  }
}
