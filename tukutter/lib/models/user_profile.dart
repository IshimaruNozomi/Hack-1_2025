class UserProfile {
  final String userId;
  final String name;
  final String bio;
  final String iconUrl;

  UserProfile({
    required this.userId,
    required this.name,
    required this.bio,
    required this.iconUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      name: json['name'],
      bio: json['bio'] ?? '',
      iconUrl: json['icon_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'bio': bio,
    'icon_url': iconUrl,
  };
}
