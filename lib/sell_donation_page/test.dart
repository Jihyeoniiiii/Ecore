import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  Uint8List? _imageData; // 서버에서 받은 이미지 데이터
  String? _imageFileName; // 서버에서 받은 이미지 파일명

  Future<void> uploadImage(File imageFile) async {
    final url = Uri.parse('http://192.168.0.5:8088/upload');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // StreamedResponse에서 이미지 데이터를 가져옵니다.
        final bytes = await http.Response.fromStream(response);
        setState(() {
          _imageData = bytes.bodyBytes; // Uint8List 형태로 저장
          _imageFileName = imageFile.path.split('/').last; // 파일명을 저장
        });
      } else {
        print('이미지 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('업로드 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 업로드 및 표시'),
      ),
      body: Center(
        child: _imageData == null
            ? Text('이미지를 업로드하세요.')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(_imageData!), // Uint8List로 이미지를 표시
            SizedBox(height: 10),
            Text('파일명: $_imageFileName'), // 파일명을 출력
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 갤러리에서 이미지 선택 후 업로드
          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            await uploadImage(File(pickedFile.path));
          }
        },
        child: Icon(Icons.upload),
      ),
    );
  }
}
