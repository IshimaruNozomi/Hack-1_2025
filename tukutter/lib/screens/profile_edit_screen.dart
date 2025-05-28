import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfileEditScreen({required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController iconUrlController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    bioController = TextEditingController(text: widget.profile.bio);
    iconUrlController = TextEditingController(text: widget.profile.iconUrl);
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    iconUrlController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final updated = UserProfile(
      userId: widget.profile.userId,
      name: nameController.text,
      bio: bioController.text,
      iconUrl: iconUrlController.text,
    );
    final success = await ApiService.updateUserProfile(updated);
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('プロフィール編集')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: '名前')),
            TextField(controller: bioController, decoration: InputDecoration(labelText: '自己紹介')),
            TextField(controller: iconUrlController, decoration: InputDecoration(labelText: 'アイコンURL')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProfile, child: Text('保存')),
          ],
        ),
      ),
    );
  }
}
