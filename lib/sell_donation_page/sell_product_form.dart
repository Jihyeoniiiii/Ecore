import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SellProductForm extends StatefulWidget {
  final String name;

  const SellProductForm({super.key, required this.name});

  @override
  State<SellProductForm> createState() => _SellProductFormState();
}

class _SellProductFormState extends State<SellProductForm> {
  final _formKey = GlobalKey<FormState>();
  List<XFile>? _images = [];
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _shippingFeeController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _categoryValue;

  List<Map<String, dynamic>> _displayedDonaOrders = []; // 화면에 표시할 기부글 목록

  Future<void> getImages() async {
    if (_images!.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 10개의 이미지까지 선택할 수 있습니다.')),
      );
      return;
    }

    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final price = double.parse(_priceController.text);
      final category = _categoryValue;
      final body = _bodyController.text;
      final shippingFee = double.parse(_shippingFeeController.text);
      final stock = int.parse(_stockController.text);

      _showLoadingDialog();

      try {
        List<String>? imageUrls;
        if (_images != null && _images!.isNotEmpty) {
          imageUrls = await uploadImages(_images!);
        }

        QuerySnapshot marketQuery = await _firestore
            .collection('Markets')
            .where('name', isEqualTo: widget.name)
            .get();

        if (marketQuery.docs.isNotEmpty) {
          String marketDocumentId = marketQuery.docs.first.id;

          // SellPosts에 새로운 문서를 추가
          DocumentReference sellPostRef = await _firestore.collection('SellPosts').add({
            'title': title,
            'price': price,
            'category': category,
            'body': body,
            'img': imageUrls,
            'marketId': marketDocumentId,
            'viewCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'shippingFee': shippingFee,
            'stock': stock,
          });

          // 선택된 기부글을 DonaList 서브컬렉션에 추가
          for (var donaOrder in _displayedDonaOrders) {
            await sellPostRef.collection('DonaList').add(donaOrder);
          }

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('판매 상품이 등록되었습니다.')));
          Navigator.pop(context);
        } else {
          throw '해당 이름의 마켓을 찾을 수 없습니다.';
        }
      } catch (e) {
        Navigator.of(context).pop();
        print('Error adding document: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('문서 추가 실패: $e')));
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

  Future<void> _fetchDonaOrders() async {
    // Markets 컬렉션에서 DonaOrders 서브컬렉션 불러오기
    QuerySnapshot marketQuery = await _firestore
        .collection('Markets')
        .where('name', isEqualTo: widget.name)
        .get();

    if (marketQuery.docs.isNotEmpty) {
      String marketDocumentId = marketQuery.docs.first.id;

      QuerySnapshot donaOrdersQuery = await _firestore
          .collection('Markets')
          .doc(marketDocumentId)
          .collection('DonaOrders')
          .get();

      List<Map<String, dynamic>> donaOrders = donaOrdersQuery.docs.map((doc) {
        return {
          'date': doc['date'],
          'donaId': doc['donaId'],
          'paymentMethod': doc['paymentMethod'],
          'title': doc['title'],
          'userId': doc['userId'],
          'username': doc['username'],
          'donaImg': doc['donaImg'], // donaImg 추가
        };
      }).toList();

      // 새로운 페이지로 기부글 목록 보여주기
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonaOrdersSelectionPage(
            donaOrders: donaOrders,
            onDonaOrdersSelected: (selectedDonaOrders) {
              setState(() {
                _displayedDonaOrders = selectedDonaOrders; // 선택된 기부글을 저장
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('판매하기'),
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
                          '브랜드 이름이나 로고, 해짐 상태 등이 잘 보이도록 찍어주세요!',
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
              // 배송비 입력 필드 추가
              TextFormField(
                controller: _shippingFeeController,
                decoration: InputDecoration(labelText: '배송비'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                onPressed: _fetchDonaOrders,
                child: Text('기부글 선택하기'),
              ),
              SizedBox(height: 16),
              // 선택된 기부글 표시
              if (_displayedDonaOrders.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('선택된 기부글:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ..._displayedDonaOrders.map((donaOrder) {
                      return ListTile(
                        title: Text(donaOrder['title']),
                        subtitle: Text('기부자: ${donaOrder['username']}'),
                        leading: donaOrder['donaImg'] != null && donaOrder['donaImg'].isNotEmpty
                            ? Image.network(
                          donaOrder['donaImg'][0], // 첫 번째 이미지를 표시
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _displayedDonaOrders.remove(donaOrder); // 선택 해제
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('판매하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonaOrdersSelectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> donaOrders;
  final ValueChanged<List<Map<String, dynamic>>> onDonaOrdersSelected;

  const DonaOrdersSelectionPage({
    Key? key,
    required this.donaOrders,
    required this.onDonaOrdersSelected,
  }) : super(key: key);

  @override
  _DonaOrdersSelectionPageState createState() => _DonaOrdersSelectionPageState();
}

class _DonaOrdersSelectionPageState extends State<DonaOrdersSelectionPage> {
  List<Map<String, dynamic>> selectedDonaOrders = []; // 선택된 기부글 목록

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 기부글 목록'),
      ),
      body: ListView.builder(
        itemCount: widget.donaOrders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.donaOrders[index]['title']),
            subtitle: Text('기부자: ${widget.donaOrders[index]['username']}'),
            leading: widget.donaOrders[index]['donaImg'] != null && widget.donaOrders[index]['donaImg'].isNotEmpty
                ? Image.network(
              widget.donaOrders[index]['donaImg'][0], // 첫 번째 이미지를 표시
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : null,
            trailing: Checkbox(
              value: selectedDonaOrders.contains(widget.donaOrders[index]),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    selectedDonaOrders.add(widget.donaOrders[index]); // 선택된 기부글 추가
                  } else {
                    selectedDonaOrders.remove(widget.donaOrders[index]); // 선택 해제
                  }
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onDonaOrdersSelected(selectedDonaOrders); // 선택된 기부글을 부모 위젯에 전달
          Navigator.pop(context); // 페이지 닫기
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
