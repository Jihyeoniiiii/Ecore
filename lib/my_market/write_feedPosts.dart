import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class WritePostPage extends StatefulWidget {
  final String marketId;
  final Function(String) onPostAdded;

  const WritePostPage({
    Key? key,
    required this.marketId,
    required this.onPostAdded,
  }) : super(key: key);

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _postController = TextEditingController();
  final picker = ImagePicker();
  List<XFile>? _images = []; // 여러 이미지를 저장할 리스트

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage(); // 여러 이미지 선택

    // 선택된 이미지 수가 10개 이하인 경우에만 추가
    if (pickedFiles != null) {
      if (_images!.length + pickedFiles.length <= 10) {
        setState(() {
          _images!.addAll(pickedFiles); // 선택한 이미지를 리스트에 추가
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('최대 10개의 이미지를 선택할 수 있습니다.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 선택하세요.')),
      );
    }
  }

  Future<String?> _uploadImage(XFile imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('images/$fileName');
      await ref.putFile(File(imageFile.path));
      return await ref.getDownloadURL(); // 업로드된 이미지 URL 반환
    } catch (e) {
      print('Failed to upload image: $e');
      return null; // 오류 발생 시 null 반환
    }
  }

  Future<void> _submitPost() async {
    if (_postController.text.isNotEmpty) {
      // 팝업 형태의 로딩 화면 표시
      _showLoadingDialog();

      try {
        String postContent = _postController.text;
        List<String?> imageUrls = []; // 이미지 URL을 저장할 리스트

        // 선택된 모든 이미지 업로드
        for (var image in _images!) {
          String? imageUrl = await _uploadImage(image);
          imageUrls.add(imageUrl); // 업로드한 이미지 URL 추가
        }

        // Firestore에 문서 추가
        await FirebaseFirestore.instance
            .collection('Markets')
            .doc(widget.marketId)
            .collection('feedPosts') // 피드 포스트 서브컬렉션
            .add({
          'content': postContent,
          'createdAt': FieldValue.serverTimestamp(),
          'imageUrls': imageUrls, // 여러 이미지 URL을 배열로 저장
        });

        // 게시글 추가 후 콜백 호출
        widget.onPostAdded(postContent);

        // 성공적으로 추가되었음을 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글이 추가되었습니다.')),
        );

        // 페이지 닫기
        Navigator.pop(context); // 로딩 팝업 닫기
        Navigator.pop(context); // 현재 페이지 닫기
      } catch (e) {
        print('Error adding post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 추가 실패')),
        );
        Navigator.pop(context); // 로딩 팝업 닫기
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 로딩 중에는 팝업이 닫히지 않도록 설정
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("게시글을 업로드 중입니다...", style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images!.removeAt(index); // 선택 해제
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 글 쓰기'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submitPost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '게시글 내용을 입력하세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            Text(
              '이미지를 선택하세요 (최대 10개)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text('이미지를 선택하세요')),
              ),
            ),
            SizedBox(height: 16),
            // 선택된 이미지 미리보기
            _images!.isNotEmpty
                ? SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 8), // 이미지 간격 설정
                    width: 100, // 정사각형 크기
                    height: 100, // 정사각형 크기
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(File(_images![index].path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _removeImage(index), // 이미지 제거
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
                : SizedBox.shrink(), // 이미지가 없을 경우 빈 위젯
          ],
        ),
      ),
    );
  }
}
