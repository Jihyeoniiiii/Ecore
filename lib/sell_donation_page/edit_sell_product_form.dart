import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProductForm extends StatefulWidget {
  final String productId; // 수정할 상품의 ID

  const EditProductForm({Key? key, required this.productId}) : super(key: key);

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  List<XFile>? _images = [];
  List<String> _existingImages = [];
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(); // 가격 입력 필드
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(); // 재고 입력 필드
  final TextEditingController _shippingFeeController = TextEditingController(); // 배송비 입력 필드
  String? _categoryValue;

  @override
  void initState() {
    super.initState();
    _loadProductData(); // Firestore에서 기존 상품 데이터를 불러옴
  }

  // Firestore에서 기존 데이터를 로드하여 필드에 채우는 함수
  Future<void> _loadProductData() async {
    DocumentSnapshot productSnapshot = await _firestore.collection('SellPosts').doc(widget.productId).get();

    if (productSnapshot.exists) {
      Map<String, dynamic>? productData = productSnapshot.data() as Map<String, dynamic>?;

      // 기존 데이터를 각 필드에 할당
      _titleController.text = productData?['title'] ?? '';

      // 가격을 double에서 int로 변환하여 처리
      double price = (productData?['price'] ?? 0).toDouble();
      _priceController.text = price.toInt().toString(); // 가격을 int로 변환하여 표시

      _categoryValue = productData?['category'] ?? '';
      _bodyController.text = productData?['body'] ?? '';

      // 재고 정보를 필드에 할당
      _stockController.text = productData?['stock']?.toString() ?? ''; // 재고 필드

      // 배송비 정보를 필드에 할당
      _shippingFeeController.text = productData?['shippingFee']?.toString() ?? ''; // 배송비 필드

      _existingImages = List<String>.from(productData?['img'] ?? []);
      setState(() {}); // UI 업데이트
    }
  }

  Future<void> getImages() async {
    if (_images!.length + _existingImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 10개의 이미지까지 선택할 수 있습니다.')),
      );
      return;
    }

    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = (_images! + pickedFiles).take(10 - _existingImages.length).toList();
      });
    }
  }

  Future<void> captureImage() async {
    if (_images!.length + _existingImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 10개의 이미지까지 선택할 수 있습니다.')),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images = (_images! + [pickedFile]).take(10 - _existingImages.length).toList();
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final price = int.parse(_priceController.text); // 가격을 int형으로 변환
      final category = _categoryValue;
      final body = _bodyController.text;
      final stock = int.parse(_stockController.text); // 재고 필드를 정수로 변환하여 저장
      final shippingFee = int.parse(_shippingFeeController.text); // 배송비 필드를 int로 변환

      _showLoadingDialog();

      try {
        List<String>? imageUrls;
        if (_images != null && _images!.isNotEmpty) {
          imageUrls = await uploadImages(_images!);
        }

        List<String> allImageUrls = [..._existingImages, ...?imageUrls];

        await _firestore.collection('SellPosts').doc(widget.productId).update({
          'title': title,
          'price': price, // int형으로 저장
          'category': category,
          'body': body,
          'img': allImageUrls,
          'stock': stock, // 재고 필드를 업데이트
          'shippingFee': shippingFee, // 배송비 필드를 업데이트
          'updatedAt': FieldValue.serverTimestamp(),
        });

        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상품 정보가 수정되었습니다.')),
        );
        Navigator.pop(context); // 폼 화면 닫기
      } catch (e) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문서 업데이트 실패: $e')),
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
                Text("수정 중..."),
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
        title: Text('판매 상품 수정'),
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
                      child: Icon(Icons.camera_alt, size: 50),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '브랜드 이름이나 로고, 상태가 잘 보이도록 찍어주세요!',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _existingImages.isNotEmpty || (_images != null && _images!.isNotEmpty)
                  ? SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImages.length + (_images?.length ?? 0),
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
                                    _existingImages.removeAt(index);
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
                      final localImageIndex = index - _existingImages.length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_images![localImageIndex].path),
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
                                    _images!.removeAt(localImageIndex);
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
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 입력 가능
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '가격을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // 재고 수정 필드 추가
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: '재고 수량'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '재고를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // 배송비 입력 필드 추가
              TextFormField(
                controller: _shippingFeeController,
                decoration: InputDecoration(labelText: '배송비'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 입력 가능
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '배송비를 입력해주세요';
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
                child: Text('수정하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
