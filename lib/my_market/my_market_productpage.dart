import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/sell_post_model.dart';
import '../home_page/feed_detail.dart';
import '../widgets/sold_out.dart'; // SoldOutOverlay 임포트
import '../sell_donation_page/edit_sell_product_form.dart';

class MyMarketProductpage extends StatelessWidget {
  final String marketId;

  const MyMarketProductpage({Key? key, required this.marketId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SellPostModel>>(
      stream: FirebaseFirestore.instance
          .collection('SellPosts')
          .where('marketId', isEqualTo: marketId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => SellPostModel.fromSnapshot(doc)).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('상품이 없습니다.'));
        }

        var details = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,  // 3개의 열
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 0.6,  // 비율을 줄여 세로 공간을 더 확보
          ),
          itemCount: details.length,
          itemBuilder: (context, index) {
            var sellPost = details[index];

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
                        borderRadius: BorderRadius.circular(6.0),  // 모서리를 둥글게 설정
                        child: AspectRatio(
                          aspectRatio: 1.0,  // 1:1 비율 고정
                          child: Container(
                            color: Colors.blueGrey,
                            child: sellPost.img.isNotEmpty
                                ? Image.network(
                              sellPost.img[0],
                              fit: BoxFit.cover,  // 이미지를 컨테이너에 맞게 1:1로 채움
                            )
                                : Center(
                              child: Text(
                                '이미지 없음',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 솔드 아웃 오버레이
                      SoldOutOverlay(
                        isSoldOut: sellPost.stock == 0, // 솔드 아웃 상태 확인
                        radius: 30.0, // 모서리에 맞게 둥글게 설정
                        borderRadius: 6.0,
                      ),
                      Positioned(
                        top: 8,  // 상단에서 8px 아래
                        right: 8,  // 우측에서 8px 왼쪽
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('수정'),
                                        onTap: () {
                                          // 수정 버튼 동작
                                          Navigator.pop(context); // 모달 닫기
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditProductForm(
                                                productId: sellPost.sellId, // sellId 전달
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('삭제'),
                                        onTap: () async {
                                          // 삭제 확인 다이얼로그 띄우기
                                          final bool confirmed = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('삭제 확인'),
                                              content: Text('정말로 이 상품을 삭제하시겠습니까?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context, false); // '아니오' 선택 시 팝업 닫기
                                                  },
                                                  child: Text('아니오'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context, true); // '예' 선택 시 삭제 진행
                                                  },
                                                  child: Text('예'),
                                                ),
                                              ],
                                            ),
                                          );

                                          // '예'를 선택한 경우에만 삭제 진행
                                          if (confirmed == true) {
                                            try {
                                              // Firestore에서 해당 문서 삭제
                                              await FirebaseFirestore.instance
                                                  .collection('SellPosts')
                                                  .doc(sellPost.sellId) // sellId 사용
                                                  .delete();

                                              // 모달 시트 닫기 (수정, 삭제 버튼이 있는 하단 모달)
                                              Navigator.pop(context); // showModalBottomSheet 닫기

                                              // 삭제 완료 팝업 띄우기
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('삭제 완료'),
                                                    content: Text('상품이 삭제되었습니다.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context); // 삭제 완료 팝업 닫기
                                                        },
                                                        child: Text('확인'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } catch (e) {
                                              // 오류 처리 팝업
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('오류 발생'),
                                                    content: Text('삭제 실패: $e'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context); // 오류 팝업 닫기
                                                        },
                                                        child: Text('확인'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(Icons.more_vert, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),  // 이미지와 텍스트 간의 간격
                  Text(
                    '${sellPost.price}원',  // 가격 정보
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    sellPost.title,  // 제목 정보
                    maxLines: 2,  // 두 줄까지 표시
                    overflow: TextOverflow.ellipsis,  // 두 줄 이상일 경우 생략
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
