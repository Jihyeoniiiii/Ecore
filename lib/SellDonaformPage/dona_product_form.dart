import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DonaProductForm extends StatefulWidget {
  @override
  State<DonaProductForm> createState() => _DonaProductFormState();
}

class _DonaProductFormState extends State<DonaProductForm> {
  final _formKey = GlobalKey<FormState>();
  XFile? _image;
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('images/$fileName');
      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      throw e;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final price = double.parse(_priceController.text);
      final category = _categoryValue;
      final body = _bodyController.text;

      // 로딩 다이얼로그 표시
      _showLoadingDialog();

      try {
        String? imageUrl;
        if (_image != null) {
          final imageFile = File(_image!.path);
          imageUrl = await uploadImage(imageFile);
        }

        await _firestore.collection('DonaPosts').add({
          'title': title,
          'price': price,
          'category': category,
          'body': body,
          'img': imageUrl,
        });

        // 작업 완료 후 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기부 상품이 등록되었습니다.')),
        );

        Navigator.pop(context);
      } catch (e) {
        // 작업 실패 시 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        print('Error adding document: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문서 추가 실패: $e')),
        );
      }
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _categoryValue;

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부를 클릭해도 닫히지 않도록 설정
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
      appBar: AppBar(
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
                    onTap: getImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '브랜드 이름이나 로고, 해짐 상태 등이 잘 보이도록 찍어주세요!',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '가격을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '카테고리'),
                value: _categoryValue,
                items: ['상의', '하의', '가방', '신발'].map((String category) {
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
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: '자세한 설명',
                  hintText: '재질이나 색 등 옷의 상태를 설명해주세요',
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
}
