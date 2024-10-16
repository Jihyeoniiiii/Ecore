import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page/feed_detail.dart';
import '../models/firestore/sell_post_model.dart';
import '../widgets/sold_out.dart';

class SearchPage extends StatefulWidget {
  final String marketId;

  const SearchPage({Key? key, required this.marketId}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  bool showResults = false;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                    showResults = false;
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '상품을 검색해보세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    searchQuery = '';
                    showResults = false;
                  });
                },
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: Colors.black),
            onPressed: () {
              if (searchQuery.isNotEmpty) {
                setState(() {
                  showResults = true;
                });
              }
            },
          ),
        ],
      ),
      body: showResults && searchQuery.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('SellPosts')
            .where('marketId', isEqualTo: widget.marketId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('상품이 없습니다.'));
          }

          // 필터링 로직
          var filteredPosts = snapshot.data!.docs.where((doc) {
            var title = (doc['title'] as String).toLowerCase();
            return title.contains(searchQuery.toLowerCase());
          }).toList();

          if (filteredPosts.isEmpty) {
            return Center(child: Text('검색 결과가 없습니다.'));
          }

          int resultCount = filteredPosts.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '상품 $resultCount',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: resultCount,
                  itemBuilder: (context, index) {
                    var sellPost = SellPostModel.fromSnapshot(filteredPosts[index]);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FeedDetail(sellPost: sellPost),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: sellPost.img.isNotEmpty
                                      ? Image.network(
                                    sellPost.img[0],
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text(
                                        '이미지 없음',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // SoldOutOverlay 위젯이 Stack 내부에 위치해야 함
                              SoldOutOverlay(
                                isSoldOut: sellPost.stock == 0,
                                radius: 30.0,
                                borderRadius: 6.0,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${sellPost.price}원',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            sellPost.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      )
          : Center(
        child: Text('검색어를 입력하고 검색 버튼을 눌러주세요.'),
      ),
    );
  }
}
