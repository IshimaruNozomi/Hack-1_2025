import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_upload.dart'; // Cloudinaryアップロード用
import '../services/api_service.dart'; // FastAPI送信用

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final picker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;

  // 投稿本文の入力コントローラ
  final _contentController = TextEditingController();

  // 仮のユーザーID（将来的にはログイン情報から取得）
  final _userId = "user_001";

  /// 画像をギャラリーから選択し、Cloudinaryにアップロードする
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

  /// FastAPI に投稿データを送信する
  Future<void> _submitPost() async {
    if (_uploadedImageUrl == null || _contentController.text.isEmpty) {
      print("画像と内容は必須です");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("画像と投稿内容の両方を入力してください")),
      );
      return;
    }

    final success = await ApiService.sendPost(
      userId: _userId,
      content: _contentController.text,
      imageUrl: _uploadedImageUrl!,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("投稿完了！")),
      );
      setState(() {
        _uploadedImageUrl = null;
        _selectedImage = null;
        _contentController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("投稿に失敗しました")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("新規投稿")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 画像アップロードボタン
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: Text("画像を選んでアップロード"),
            ),
            const SizedBox(height: 10),

            // アップロードされた画像を表示
            if (_uploadedImageUrl != null)
              Image.network(
                _uploadedImageUrl!,
                height: 200,
              ),

            const SizedBox(height: 10),

            // 投稿本文の入力欄
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "投稿内容を入力してください",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 投稿ボタン
            ElevatedButton(
              onPressed: _submitPost,
              child: Text("投稿する"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
