import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> sendPostToFastAPI({
  required String userId,
  required String content,
  required String imageUrl,
}) async {
  final url = Uri.parse('http://127.0.0.1:8000/create_post'); // 本番はAPIのIPやドメインに変更

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": userId,
      "content": content,
      "image_url": imageUrl,
    }),
  );

  if (response.statusCode == 200) {
    print("投稿成功: ${response.body}");
    return true;
  } else {
    print("投稿失敗: ${response.statusCode} - ${response.body}");
    return false;
  }
}
