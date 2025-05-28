import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_upload.dart'; // uploadImageToCloudinary を使う
import '../services/api_service.dart'; // 上で作成したAPI呼び出しヘルパー

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final picker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final url = await uploadImageToCloudinary(file);
      setState(() {
        _selectedImage = file;
        _uploadedImageUrl = url;
      });
      print('Cloudinary URL: $_uploadedImageUrl');
    }
  }

    final _contentController = TextEditingController();
    final _userId = "user_001"; // 本来はログイン情報から取得すべき

    Future<void> _submitPost() async {
    if (_uploadedImageUrl == null || _contentController.text.isEmpty) {
        print("画像と内容は必須です");
        return;
    }

    final success = await ApiService.sendPost(
        userId: _userId,
        content: _contentController.text,
        imageUrl: _uploadedImageUrl!,
    );

    if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("投稿完了！")));
        setState(() {
        _uploadedImageUrl = null;
        _contentController.clear();
        });
    }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("新規投稿")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickAndUploadImage,
            child: Text("画像を選んでアップロード"),
          ),
          if (_uploadedImageUrl != null) Image.network(_uploadedImageUrl!),
          // ↓ここでFastAPIにpostする処理も追加していく
        ],
      ),
    );
  }
}
