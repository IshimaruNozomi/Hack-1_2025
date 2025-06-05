class User {
  final String id;
  final String name;
  final String iconUrl;
  final String username;

  User({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      iconUrl: json['icon_url'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'username': username,
    };
  }
}
