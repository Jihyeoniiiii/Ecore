import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class DonaProductForm extends StatefulWidget {
  @override
  State<DonaProductForm> createState() => _DonaProductFormState();
}

class _DonaProductFormState extends State<DonaProductForm> {
  final _formKey = GlobalKey<FormState>();
  List<XFile>? _images = []; // 여러 이미지를 저장할 리스트
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 현재 로그인된 사용자 정보 가져오기
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _pointController = TextEditingController(); // 포인트 입력 필드
  String? _categoryValue;
  String? _selectedCondition = 'S';
  String _serverUrl = 'http://your-flask-server-ip:5000/upload';

  Future<void> getImages() async {
    if (_images!.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 10개의 이미지까지 선택할 수 있습니다.')),
      );
      return; // 이미 10개 이상의 이미지가 선택된 경우 추가 선택 불가
    }

    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        // 최대 10개를 초과하지 않도록 리스트에 추가
        _images = (_images! + pickedFiles).take(10).toList();
      });
    }
  }

  Future<void> captureImage() async {
    if (_images!.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 10개의 이미지까지 선택할 수 있습니다.')),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images = (_images! + [pickedFile]).take(10).toList();
      });
    }
  }

  Future<List<String>> uploadImages(List<XFile> imageFiles) async {
    List<String> downloadUrls = [];
    for (XFile imageFile in imageFiles) {
      try {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('images/$fileName');
        final uploadTask = ref.putFile(File(imageFile.path));

        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Failed to upload image: $e');
        throw e;
      }
    }
    return downloadUrls;
  }

  Future<Map<String, dynamic>?> uploadImageToFlask(XFile imageFile) async {
    try {
      var uri = Uri.parse(_serverUrl);

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        return jsonDecode(responseData.body); // 서버에서 받은 JSON 데이터를 Map으로 변환
      } else {
        print('이미지 업로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final category = _categoryValue;
      final material = _materialController.text;
      final color = _colorController.text;
      final condition = _selectedCondition;
      final body = _bodyController.text;
      final point = int.tryParse(_pointController.text) ?? 0;

      _showLoadingDialog();

      try {
        List<String> imageUrls = [];
        List<Map<String, dynamic>> results = [];  // 이미지 처리 결과 저장

        if (_images != null && _images!.isNotEmpty) {
          // 이미지를 Flask 서버로 업로드하고 면적/등급 정보 받기
          for (XFile image in _images!) {
            Map<String, dynamic>? result = await uploadImageToFlask(image); // Flask 서버에 이미지 업로드
            if (result != null) {
              imageUrls.add(result['image_url']);  // 이미지를 서버에 업로드하고 URL 받기
              results.add({'area': result['area'], 'grade': result['grade']});  // 처리 결과 받기
            } else {
              throw Exception('Image upload failed');
            }
          }
        }

        // Firestore에 상품 정보와 함께 이미지 URL 및 결과값(면적, 등급) 저장
        DocumentReference docRef = await _firestore.collection('DonaPosts').add({
          'title': title,
          'category': category,
          'material': material,
          'color': color,
          'condition': condition,
          'body': body,
          'img': imageUrls, // 서버로부터 받은 이미지 URL들 저장
          'viewCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': currentUser?.uid, // 현재 사용자의 UID 추가
          'point': point, // 포인트 필드 추가
          'results': results,  // 면적과 등급 정보 저장
        });

        // Users 컬렉션의 my_posts 배열에 문서 ID 추가
        await _firestore.collection('Users').doc(currentUser?.uid).update({
          'my_posts': FieldValue.arrayUnion([docRef.id]) // 새로운 문서 ID 추가
        });

        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기부 상품이 등록되었습니다.')),
        );

        Navigator.pop(context);
      } catch (e) {
        Navigator.of(context).pop();
        print('Error adding document: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문서 추가 실패: $e')),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("상품등록 중..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('기부하기'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('카메라로 촬영'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    captureImage();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('갤러리에서 선택'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    getImages();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.camera_alt, size: 50), // 항상 카메라 아이콘만 표시
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '수평에 맞춰서 A4용지와 함께 찍어야 면적 측정이 가능하여 포인트가 지급됩니다.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _images != null && _images!.isNotEmpty
                  ? SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_images![index].path),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _images!.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey[800],
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
                  : Container(),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '상품명'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '카테고리'),
                value: _categoryValue,
                items: ['상의', '하의', '가방', '신발', '기타'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _categoryValue = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '카테고리를 선택해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "물품 상태",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 16),
                  _buildConditionButton('S'),
                  SizedBox(width: 8),
                  _buildConditionButton('A'),
                  SizedBox(width: 8),
                  _buildConditionButton('B'),
                  SizedBox(width: 8),
                  _buildConditionButton('C'),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _materialController,
                decoration: InputDecoration(labelText: '재질'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '재질을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(labelText: '색'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '색을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: '자세한 설명',
                  hintText: '기부할 상품의 상태를 설명해주세요',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '자세한 설명을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _pointController,
                decoration: InputDecoration(labelText: '포인트'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '포인트를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('기부하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionButton(String condition) {
    return ChoiceChip(
      label: Text(condition),
      selected: _selectedCondition == condition,
      onSelected: (selected) {
        setState(() {
          _selectedCondition = condition;
        });
      },
    );
  }
}
