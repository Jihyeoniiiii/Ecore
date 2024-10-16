import '../../cosntants/firestore_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellPostModel {
  final String sellId; // sellPost ID
  final String marketId; // 마켓 ID (외래키)
  final String title;
  final List<String> img;
  final int price;
  final String category;
  final String body;
  final DateTime createdAt;
  final int viewCount;
  final int shippingFee;
  final int stock; // 재고 필드 추가
  final DocumentReference reference;

  SellPostModel({
    required this.sellId,
    required this.price,
    required this.title,
    required this.img,
    required this.category,
    required this.body,
    required this.marketId,
    required this.createdAt,
    required this.viewCount,
    required this.shippingFee,
    required this.stock, // 재고 필드 추가
    required this.reference,
  });

  // Map<String, dynamic>으로 변환
  Map<String, dynamic> toMap() {
    return {
      KEY_SELLID: sellId,
      KEY_SELL_MARKETID: marketId,
      KEY_SELLTITLE: title,
      KEY_SELLIMG: img,
      KEY_SELLPRICE: price,
      KEY_SELLCATEGORY: category,
      KEY_SELLBODY: body,
      KEY_SHIPPINGFEE : shippingFee,
      KEY_SELL_CREATED_AT: Timestamp.fromDate(createdAt),
      KEY_SELL_VIEW_COUNT: viewCount,
      KEY_SELL_STOCK: stock,
    };
  }

  // Firestore의 Map 데이터를 객체로 변환
  SellPostModel.fromMap(Map<String, dynamic> map, this.sellId, {required this.reference})
      : title = map[KEY_SELLTITLE] ?? '',
        shippingFee = (map[KEY_SHIPPINGFEE] as num?)?.toInt() ?? 0, // Null 처리
        marketId = map[KEY_SELL_MARKETID] ?? '',
        img = (map[KEY_SELLIMG] is String)
            ? [map[KEY_SELLIMG]] // String일 경우 리스트로 변환
            : (map[KEY_SELLIMG] as List<dynamic>?)?.cast<String>() ?? ['https://via.placeholder.com/150'], // List일 경우 그대로 사용
        price = (map[KEY_SELLPRICE] as num).toInt(),
        category = map[KEY_SELLCATEGORY] ?? '기타',
        body = map[KEY_SELLBODY] ?? '내용 없음',
        createdAt = (map[KEY_SELL_CREATED_AT] as Timestamp?)?.toDate() ?? DateTime.now(),
        viewCount = map[KEY_SELL_VIEW_COUNT] ?? 0,
        stock = (map['stock'] as num?)?.toInt() ?? 0; // Null 처리

  // DocumentSnapshot에서 객체 생성
  SellPostModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id, reference: snapshot.reference);
}

// 사용자 마켓 매칭 여부 확인 함수
Future<bool> isUserMarketMatched(SellPostModel sellPost) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not logged in.');
      return false;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      print('User document does not exist.');
      return false;
    }

    final userMarketId = userDoc.data()?['marketId'] as String?;

    if (userMarketId == null) {
      print('User market ID does not exist.');
      return false;
    }
    return sellPost.marketId == userMarketId;
  } catch (e) {
    print('Error checking market match: $e');
    return false;
  }
}
