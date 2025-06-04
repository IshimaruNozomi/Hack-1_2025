class Post {
  final int postId;       // ← 明示的に postId とする
  final String userId;
  final String content;
  final String imageUrl;
  final String createdAt;

  Post({
    required this.postId,
    required this.userId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['id'],              // ← JSON キーが 'id' の場合はそのまま使う
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': postId,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt,
    };
  }
}
