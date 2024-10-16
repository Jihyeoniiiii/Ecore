import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class SettingPage extends StatefulWidget {
  final String userId;

  const SettingPage({Key? key, required this.userId}) : super(key: key);

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  File? _profileImage;
  String? _currentProfileImageUrl; // 현재 프로필 이미지 URL
  final _storeNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentImages();
  }

  Future<void> _loadCurrentImages() async {
    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(
        widget.userId).get();
    if (userDoc.exists) {
      final imageUrl = userDoc.get('profile_img');
      print('Image URL from Firestore: $imageUrl'); // Debugging line

      setState(() {
        _currentProfileImageUrl = imageUrl;
      });
    } else {
      print('Document does not exist'); // Debugging line
    }
  }


  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // 고유한 파일 이름 생성
      final fileName = 'user_image/${DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()}.jpg';
      final ref = _storage.ref().child(fileName);

      // Firebase Storage에 파일 업로드
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});

      // 업로드된 파일의 다운로드 URL 가져오기
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    try {
      // 로딩 중 다이얼로그 표시
      _showLoadingDialog();

      // 프로필 이미지와 배너 이미지를 Firebase Storage에 업로드
      String? profileImageUrl;

      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      }

      // Firestore에 업데이트할 데이터
      Map<String, dynamic> updateData = {
        'username': _storeNameController.text,
      };

      if (profileImageUrl != null) {
        updateData['profile_img'] = profileImageUrl;
      }

      // Firestore에서 Markets 컬렉션의 해당 마켓 문서를 업데이트
      await _firestore.collection('Users').doc(widget.userId).update(
          updateData);

      // 로딩 중 다이얼로그 닫기
      Navigator.of(context).pop();

      // 성공 메시지 표시
      _showSuccessDialog();
    } catch (e) {
      // 로딩 중 다이얼로그 닫기
      Navigator.of(context).pop();

      print('Error updating profile: $e');
      // 에러 처리 로직 추가
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("로딩 중..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("완료"),
          content: Text("프로필 수정이 완료되었습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(true); // 이전 화면으로 돌아가며 결과 전달
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('유저 정보 편집'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_currentProfileImageUrl != null &&
                          _currentProfileImageUrl!.isNotEmpty)
                          ? NetworkImage(_currentProfileImageUrl!)
                          : AssetImage(
                          'assets/images/defualt_profile.jpg') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.camera_alt, color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text('유저이름', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  hintText: '유저이름을 입력하세요',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.symmetric(vertical: 10),
                  textStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.normal),
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('적용하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
