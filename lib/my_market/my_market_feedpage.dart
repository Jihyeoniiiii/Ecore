import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyMarketFeedpage extends StatefulWidget {
  final String marketId;

  const MyMarketFeedpage({super.key, required this.marketId});

  @override
  _MyMarketFeedpageState createState() => _MyMarketFeedpageState();
}

class _MyMarketFeedpageState extends State<MyMarketFeedpage> {
  List<String> _feedPosts = [];

  // Firestore에서 데이터를 불러오는 함수
  Future<Map<String, dynamic>?> _getMarketData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        _feedPosts = List<String>.from(data['feedPosts'] ?? []);
        return data;
      }
    } catch (e) {
      print('Error fetching market data: $e');
    }
    return null;
  }

  void _showAddPostDialog({int? index}) {
    final TextEditingController _postController = TextEditingController(
      text: index != null ? _feedPosts[index] : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            index == null ? '공지사항 입력' : '공지사항 수정',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _postController,
            decoration: InputDecoration(
              hintText: '공지사항을 입력해주세요',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  if (index == null) {
                    _feedPosts.add(_postController.text);
                  } else {
                    _feedPosts[index] = _postController.text;
                  }
                });
                _saveFeedPostsToFirestore();  // Firestore에 저장
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.check),
              label: Text(index == null ? '추가' : '수정'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(int index) {
    setState(() {
      _feedPosts.removeAt(index);
    });
    _saveFeedPostsToFirestore();  // Firestore에 저장
  }

  Future<void> _saveFeedPostsToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .update({'feedPosts': _feedPosts});
    } catch (e) {
      print('Error saving feed posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getMarketData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
        }

        var marketData = snapshot.data!;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign_outlined),
                    SizedBox(width: 8),
                    Text('커뮤니티 | 공지사항', style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _showAddPostDialog,
                    ),
                  ],
                ),
                SizedBox(height: 16), // 공지사항 리스트와의 간격
                // 공지사항 리스트
                ..._feedPosts.asMap().entries.map((entry) {
                  int index = entry.key;
                  String post = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity, // 부모 위젯의 가로 길이를 채우도록 설정
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(post, style: TextStyle(fontSize: 16)),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showAddPostDialog(index: index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePost(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
