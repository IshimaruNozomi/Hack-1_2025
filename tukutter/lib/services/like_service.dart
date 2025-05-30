import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendLike(int postId, String userId) async {
  final response = await http.post(
    Uri.parse('http://192.168.11.10:8000/like'), // ここは人のPCのIPアドレスに置き換える
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'post_id': postId, 'user_id': userId}),
  );

  if (response.statusCode == 200) {
    print("いいね成功");
  } else if (response.statusCode == 409) {
    print("すでにいいねしています");
  } else {
    print("エラー: ${response.statusCode}");
  }
}

Future<int> getLikeCount(int postId) async {
  final response = await http.get(Uri.parse('http://<あなたのPCのIP>:8000/likes/$postId'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['like_count'];
  } else {
    throw Exception('いいね数の取得に失敗');
  }
}
