import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000'; // FastAPIのURL（適宜変更）

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
}
