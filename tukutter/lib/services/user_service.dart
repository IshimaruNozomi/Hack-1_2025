import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'http://localhost:8000'; // 本番環境URLに変更してください
const Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer YOUR_TOKEN_HERE'
};

Future<void> followUser(int userId) async { /* 省略 */ }
Future<void> unfollowUser(int userId) async { /* 省略 */ }
Future<List<Map<String, dynamic>>> getFollowing(int userId) async { /* 省略 */ }
Future<List<Map<String, dynamic>>> searchUsers(String query) async { /* 省略 */ }
