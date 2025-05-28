import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

Future<String?> uploadImageToCloudinary(File imageFile) async {
  final cloudName = 'あなたのCloudinaryクラウド名';
  final uploadPreset = 'あなたのアップロードプリセット';

  final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
  final mimeSplit = mimeType.split('/');

  final request = http.MultipartRequest('POST', uri);
  request.fields['upload_preset'] = uploadPreset;
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    imageFile.path,
    contentType: MediaType(mimeSplit[0], mimeSplit[1]),
  ));

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final respJson = json.decode(respStr);
    return respJson['secure_url']; // アップロード後の画像URLを返す
  } else {
    print('Upload failed with status: ${response.statusCode}');
    return null;
  }
}
