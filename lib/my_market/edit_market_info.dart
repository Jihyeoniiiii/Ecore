import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditMarketInfoPage extends StatefulWidget {
  final String marketId;

  EditMarketInfoPage({required this.marketId});

  @override
  _EditMarketInfoPageState createState() => _EditMarketInfoPageState();
}

class _EditMarketInfoPageState extends State<EditMarketInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _marketNameController = TextEditingController();
  final _marketDescriptionController = TextEditingController();
  final _csPhoneController = TextEditingController();
  final _csemailController = TextEditingController();

  String? _businessNumber;
  String? _profileImageUrl;
  String? _bannerImageUrl;

  File? _profileImage;
  File? _bannerImage;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    try {
      DocumentSnapshot marketDoc = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .get();
      if (marketDoc.exists) {
        Map<String, dynamic>? marketData =
        marketDoc.data() as Map<String, dynamic>?;

        _marketNameController.text = marketData?['name'] ?? '';
        _marketDescriptionController.text =
            (marketData?['feedPosts'] as List<dynamic>?)
                ?.join('\n') ??
                '';
        _csPhoneController.text = marketData?['cs_phone'] ?? '';
        _csemailController.text = marketData?['cs_email'] ?? '';
        _businessNumber = marketData?['business_number'];
        _profileImageUrl = marketData?['img'];
        _bannerImageUrl = marketData?['bannerImg'];
        setState(() {});  // 이전 이미지를 UI에 반영
      }
    } catch (e) {
      print('Failed to load market data: $e');
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBannerImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = 'market_images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _updateMarketInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      String marketName = _marketNameController.text;
      List<String> marketDescription =
      _marketDescriptionController.text.split('\n');
      String csPhone = _csPhoneController.text;
      String csemail = _csemailController.text;

      Map<String, dynamic> updateData = {
        'name': marketName,
        'feedPosts': marketDescription,
        'cs_phone': csPhone,
        'cs_email': csemail,
        'business_number': _businessNumber ?? '',
      };

      try {
        // 프로필 이미지 업데이트
        if (_profileImage != null) {
          String? profileImageUrl = await _uploadImage(_profileImage!);
          if (profileImageUrl != null) {
            updateData['img'] = profileImageUrl;
          }
        }

        // 배너 이미지 업데이트
        if (_bannerImage != null) {
          String? bannerImageUrl = await _uploadImage(_bannerImage!);
          if (bannerImageUrl != null) {
            updateData['bannerImg'] = bannerImageUrl;
          }
        }

        await FirebaseFirestore.instance
            .collection('Markets')
            .doc(widget.marketId)
            .update(updateData);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마켓 정보가 수정되었습니다.')),
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마켓 정보 수정 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  Widget _buildProfileImagePicker({
    required String label,
    File? imageFile,
    String? imageUrl,
    required Function() pickImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imageFile != null
                      ? FileImage(imageFile)
                      : (imageUrl != null ? NetworkImage(imageUrl) as ImageProvider : null),
                  child: imageFile == null && imageUrl == null
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.camera_alt, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBannerImagePicker({
    required String label,
    File? imageFile,
    String? imageUrl,
    required Function() pickImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              image: imageFile != null
                  ? DecorationImage(
                image: FileImage(imageFile),
                fit: BoxFit.cover,
              )
                  : imageUrl != null
                  ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: Stack(
              children: [
                if (imageFile == null && imageUrl == null)
                  Center(child: Icon(Icons.add_a_photo, color: Colors.grey[700], size: 50)),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마켓 정보 수정', style: TextStyle(fontFamily: 'NanumSquare',)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImagePicker(
                  label: '프로필 이미지',
                  imageFile: _profileImage,
                  imageUrl: _profileImageUrl,
                  pickImage: _pickProfileImage,
                ),
                _buildBannerImagePicker(
                  label: '배너 이미지',
                  imageFile: _bannerImage,
                  imageUrl: _bannerImageUrl,
                  pickImage: _pickBannerImage,
                ),
                Text('마켓이름', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextField(
                  controller: _marketNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                SizedBox(height: 16),
                Text('소개글', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextField(
                  controller: _marketDescriptionController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                ),
                SizedBox(height: 16),
                Text('CS 전화번호', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextField(
                  controller: _csPhoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 16),
                Text('CS 이메일', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                TextField(
                  controller: _csemailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                Text(
                  _businessNumber != null
                      ? '사업자 번호: $_businessNumber'
                      : '사업자 등록 번호가 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateMarketInfo,
                  child: Text('수정 완료'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
