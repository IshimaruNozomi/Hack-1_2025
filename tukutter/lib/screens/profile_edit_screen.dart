import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfileEditScreen({required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio);
    _uploadedImageUrl = widget.profile.iconUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });

      final url = await ApiService.uploadProfileImage(widget.profile.userId, _selectedImage!);
      if (url != null) {
        setState(() {
          _uploadedImageUrl = url;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    await ApiService.updateUserProfile(
      userId: widget.profile.userId,
      name: _nameController.text,
      bio: _bioController.text,
      iconUrl: _uploadedImageUrl ?? '',
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('プロフィール編集')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _uploadedImageUrl != null
                      ? NetworkImage(_uploadedImageUrl!)
                      : null,
                  child: _uploadedImageUrl == null ? Icon(Icons.camera_alt, size: 30) : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '名前'),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: '自己紹介'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
