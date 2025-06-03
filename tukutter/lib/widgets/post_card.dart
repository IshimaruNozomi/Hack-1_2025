import 'package:flutter/material.dart';
import 'comment_list.dart'; 

IconButton(
  icon: Icon(Icons.favorite_border),
  onPressed: () {
    sendLike(post.id, currentUserId);
  },
),

FutureBuilder<int>(
  future: getLikeCount(post.id),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Text('読み込み中...');
    } else if (snapshot.hasError) {
      return Text('エラー');
    } else {
      return Text('${snapshot.data} いいね');
    }
  },
)

class PostCard extends StatelessWidget {
  final int postId;
  final String content;

  const PostCard({Key? key, required this.postId, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            CommentList(postId: postId), // ← コメント表示
          ],
        ),
      ),
    );
  }
}
