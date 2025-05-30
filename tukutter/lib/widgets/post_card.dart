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
