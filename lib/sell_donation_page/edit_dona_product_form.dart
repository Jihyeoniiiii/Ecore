import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class DonaProductEditForm extends StatefulWidget {
  final String donaId; // 수정할 기부 글의 ID

  const DonaProductEditForm({Key? key, required this.donaId}) : super(key: key);

  @override
  State<DonaProductEditForm> createState() => _DonaProductEditFormState();
}

class _DonaProductEditFormState extends State<DonaProductEditForm> {
  final _formKey = GlobalKey<FormState>();
  List<XFile>? _newImages = [];
  List<String> _existingImages = []; // 기존 이미지 URL
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();
  String? _categoryValue;
  String? _selectedCondition = 'S';

  @override
  void initState() {
    super.initState();
    _loadDonaPostData(); // 데이터 로드
  }

  Future<void> _loadDonaPostData() async {
    DocumentSnapshot doc = await _firestore.collection('DonaPosts').doc(widget.donaId).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _categoryValue = data['category'];
      _bodyController.text = data['body'] ?? '';
      _materialController.text = data['material'] ?? '';
      _colorController.text = data['color'] ?? '';
      _pointController.text = data['point']?.toString() ?? '';
      _selectedCondition = data['condition'] ?? 'S';

      // 기존 이미지 로드
      _existingImages = List<String>.from(data['img'] ?? []);

      setState(() {});
    }
  }

  Future<void> getImages() async {
    if (_newImages!.length + _existingImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 10개의 이미지까지 선택할 수 있습니다.')),
      );
      return;
    }

    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _newImages = (_newImages! + pickedFiles).take(10 - _existingImages.length).toList();
      });
    }
  }

  Future<void> captureImage() async {
    if (_newImages!.length + _existingImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 10개의 이미지까지 선택할 수 있습니다.')),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _newImages = (_newImages! + [pickedFile]).take(10 - _existingImages.length).toList();
      });
    }
  }

  Future<List<String>> uploadImages(List<XFile> imageFiles) async {
    List<String> downloadUrls = [];
    for (XFile imageFile in imageFiles) {
      try {
        final file = File(imageFile.path);
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('images/$fileName');
        final uploadTask = ref.putFile(file);

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
        List<String> imageUrls = List.from(_existingImages);
        if (_newImages != null && _newImages!.isNotEmpty) {
          imageUrls.addAll(await uploadImages(_newImages!));
        }

        // Firestore에서 수정된 내용을 업데이트
        await _firestore.collection('DonaPosts').doc(widget.donaId).update({
          'title': title,
          'category': category,
          'material': material,
          'color': color,
          'condition': condition,
          'body': body,
          'img': imageUrls,
          'point': point,
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기부 상품이 수정되었습니다.')),
        );

        Navigator.pop(context);
      } catch (e) {
        Navigator.of(context).pop();

        print('Error updating document: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문서 수정 실패: $e')),
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
                Text("상품수정 중..."),
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
        title: Text('기부 상품 수정'),
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
              if (_existingImages.isNotEmpty || _newImages != null && _newImages!.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingImages.length + _newImages!.length,
                    itemBuilder: (context, index) {
                      if (index < _existingImages.length) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _existingImages[index],
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
                                      _existingImages.removeAt(index); // 기존 이미지 삭제
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
                      } else {
                        int newIndex = index - _existingImages.length;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_newImages![newIndex].path),
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
                                      _newImages!.removeAt(newIndex); // 새 이미지 삭제
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
                      }
                    },
                  ),
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
                child: Text('수정하기'),
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
