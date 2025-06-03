import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommentList extends StatefulWidget {
  final int postId;

  const CommentList({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  List<dynamic> comments = [];
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final response = await http.get(
      Uri.parse('http://<your-ip>:8000/comments/${widget.postId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        comments = json.decode(response.body);
      });
    } else {
      print('Failed to load comments');
    }
  }

  Future<void> postComment(String content) async {
    if (content.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    final response = await http.post(
      Uri.parse('http://<your-ip>:8000/comments/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'post_id': widget.postId,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      _controller.clear();
      await fetchComments(); // 投稿後にリストを再取得
    } else {
      print('Failed to post comment');
    }

    setState(() {
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...comments.map((comment) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text("🗨 ${comment['content']}"),
          );
        }).toList(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'コメントを入力...',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isPosting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => postComment(_controller.text),
                    child: const Text('送信'),
                  ),
          ],
        ),
      ],
    );
  }
}
