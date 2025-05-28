class Post {
  final int id;
  final String userId;
  final String content;
  final String imageUrl;
  final String createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }
}
