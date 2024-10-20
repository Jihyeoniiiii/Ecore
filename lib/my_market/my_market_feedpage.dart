import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/my_market/write_feedPosts.dart';

class MyMarketFeedPage extends StatefulWidget {
  final String marketId;

  const MyMarketFeedPage({Key? key, required this.marketId}) : super(key: key);

  @override
  _MyMarketFeedPageState createState() => _MyMarketFeedPageState();
}

class _MyMarketFeedPageState extends State<MyMarketFeedPage> {
  List<Map<String, dynamic>> _feedPosts = [];
  String? marketProfileImageUrl;
  String? marketName;
  PageController _pageController = PageController();
  int _currentIndex = 0;

  Future<void> _getMarketData() async {
    try {
      DocumentSnapshot marketDoc = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .get();

      if (marketDoc.exists) {
        setState(() {
          marketProfileImageUrl = marketDoc['img'];
          marketName = marketDoc['name'];
        });
      }

      QuerySnapshot feedPostsSnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .collection('feedPosts')
          .get();

      setState(() {
        _feedPosts = feedPostsSnapshot.docs
            .map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        })
            .toList()
          ..sort((a, b) =>
              (b['createdAt'] as Timestamp)
                  .compareTo(a['createdAt'] as Timestamp));
      });
    } catch (e) {
      print('Error fetching market data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getMarketData();
  }

  String _formatTimestamp(DateTime createdDate) {
    final now = DateTime.now();
    final difference = now.difference(createdDate);

    if (difference.inMinutes == 0) {
      return '방금 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inMinutes}분 전';
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .collection('feedPosts')
          .doc(postId)
          .delete();
      setState(() {
        _feedPosts.removeWhere((post) => post['id'] == postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글이 삭제되었습니다.')),
      );
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 삭제 실패')),
      );
    }
  }

  void _showOptionsMenu(String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("옵션"),
          content: Text("수정 또는 삭제할 수 있습니다."),
          actions: [
            TextButton(
              onPressed: () {
                // 수정 기능 추가 (추후 구현)
                Navigator.of(context).pop();
              },
              child: Text("수정"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(postId);
              },
              child: Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  void _showAddPostDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritePostPage(
          marketId: widget.marketId,
          onPostAdded: (String newPost) {
            _getMarketData();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 16),

            ..._feedPosts.map((post) {
              String content = post['content'] ?? '';
              List<dynamic> imageUrls = post['imageUrls'] ?? [];
              Timestamp createdAt = post['createdAt'];
              DateTime createdDate = createdAt.toDate();
              String postId = post['id'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: marketProfileImageUrl != null
                                    ? NetworkImage(marketProfileImageUrl!)
                                    : null,
                                radius: 20,
                              ),
                              SizedBox(width: 8),
                              Text(marketName ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () => _showOptionsMenu(postId),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      Text(
                        _formatTimestamp(createdDate),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 4),

                      if (imageUrls.isNotEmpty)
                        Stack(
                          children: [
                            SizedBox(
                              height: 300,
                              child: PageView.builder(
                                itemCount: imageUrls.length,
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentIndex = index; // 현재 페이지 인덱스 업데이트
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return AspectRatio(
                                    aspectRatio: 1, // 정사각형 비율로 설정
                                    child: Image.network(
                                      imageUrls[index],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(imageUrls.length, (index) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                                    height: 8.0,
                                    width: 8.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index == _currentIndex ? Colors.white : Colors.grey,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 4),
                      Text(content, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
