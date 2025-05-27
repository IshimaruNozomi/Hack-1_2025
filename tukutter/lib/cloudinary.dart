final url = Uri.parse("
https://api.cloudinary.com/v1_1/
dwxiferu2/image/upload");

final request = http.MultipartRequest('POST', url)
  ..fields['upload_preset'] = 'flutter_upload'
  ..files.add(await http.MultipartFile.fromPath('file', pickedImage.path));

final response = await request.send();

if (response.statusCode == 200) {
  final resBody = await response.stream.bytesToString();
  final json = jsonDecode(resBody);
  final imageUrl = json['secure_url']; // ← これをFirestoreに保存する
}