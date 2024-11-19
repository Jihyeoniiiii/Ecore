import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditPostPage extends StatefulWidget {
  final String marketId;
  final String postId;  // Post ID to fetch and update
  final Function(String) onPostEdited;

  const EditPostPage({
    Key? key,
    required this.marketId,
    required this.postId,
    required this.onPostEdited,
  }) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController _postController = TextEditingController();
  final picker = ImagePicker();
  List<XFile>? _newImages = []; // Newly selected images
  List<String>? _existingImageUrls = []; // Existing images from Firebase
  bool _isLoading = true; // Flag to show loading indicator

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    try {
      DocumentSnapshot postDoc = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .collection('feedPosts')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        setState(() {
          _postController.text = postDoc['content'] ?? '';  // Load existing content
          _existingImageUrls = List<String>.from(postDoc['imageUrls'] ?? []);  // Load existing images
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading post data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage(); // Pick multiple images

    if (pickedFiles != null) {
      if (_newImages!.length + _existingImageUrls!.length + pickedFiles.length <= 10) {
        setState(() {
          _newImages!.addAll(pickedFiles); // Add new images to the list
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('최대 10개의 이미지를 선택할 수 있습니다.')),
        );
      }
    }
  }

  Future<String?> _uploadImage(XFile imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('images/$fileName');
      await ref.putFile(File(imageFile.path));
      return await ref.getDownloadURL(); // Get uploaded image URL
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _submitEditedPost() async {
    if (_postController.text.isNotEmpty) {
      // Show loading dialog
      _showLoadingDialog();

      try {
        String postContent = _postController.text;
        List<String> allImageUrls = List.from(_existingImageUrls!); // Copy existing images

        // Upload new images
        for (var image in _newImages!) {
          String? imageUrl = await _uploadImage(image);
          allImageUrls.add(imageUrl!);
        }

        // Update Firestore post document
        await FirebaseFirestore.instance
            .collection('Markets')
            .doc(widget.marketId)
            .collection('feedPosts')
            .doc(widget.postId) // Reference the existing post document
            .update({
          'content': postContent,
          'imageUrls': allImageUrls,  // Updated list of images
        });

        // Notify post was edited
        widget.onPostEdited(postContent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글이 수정되었습니다.')),
        );

        Navigator.pop(context); // Close the dialog
        Navigator.pop(context); // Close the page
      } catch (e) {
        print('Error updating post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 수정 실패')),
        );
        Navigator.pop(context); // Close the loading dialog
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("게시글을 수정 중입니다...", style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index, {bool isExisting = true}) {
    setState(() {
      if (isExisting) {
        _existingImageUrls!.removeAt(index);
      } else {
        _newImages!.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 수정'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submitEditedPost,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '게시글 내용을 수정하세요',
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
            // Display existing images and newly added images
            if (_existingImageUrls!.isNotEmpty || _newImages!.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageUrls!.length + _newImages!.length,
                  itemBuilder: (context, index) {
                    // Show existing or new images in the list
                    bool isExisting = index < _existingImageUrls!.length;
                    String imageUrl = isExisting
                        ? _existingImageUrls![index]
                        : _newImages![index - _existingImageUrls!.length].path;

                    return Container(
                      margin: EdgeInsets.only(right: 8),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: isExisting
                              ? NetworkImage(imageUrl)
                              : FileImage(File(imageUrl)) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index, isExisting: isExisting),
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
              ),
          ],
        ),
      ),
    );
  }
}
