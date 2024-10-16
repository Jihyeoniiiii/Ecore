import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cosntants/firestore_key.dart';

class ReviewModel {
  final String reviewId;
  final String userId;
  final String orderId;
  final int itemIndex;
  final String itemTitle;
  final String marketId;
  final String review;
  final String satisfaction;
  final double rating;
  final DateTime timestamp;
  final DocumentReference reference;

  ReviewModel.fromMap(Map<String, dynamic> map, this.reviewId, {required this.reference})
      : userId = map[KEY_REVIEW_USERID] ?? '',
        orderId = map[KEY_REVIEW_ORDERID] ?? '',
        itemIndex = map[KEY_REVIEW_ITEMINDEX] ?? 0,
        itemTitle = map[KEY_REVIEW_TITLE] ?? '',
        marketId = map[KEY_REVIEW_MARKETID] ?? '',
        review = map[KEY_REVIEW_REVIEW] ?? '',
        satisfaction = map[KEY_REVIEW_SATISFACTION] ?? '',
        rating = map[KEY_REVIEW_RATING]?.toDouble() ?? 0.0,
        timestamp = (map[KEY_REVIEW_TIMESTAMP] as Timestamp?)?.toDate() ?? DateTime.now();

  ReviewModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id,
      reference: snapshot.reference);

  // Map으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      KEY_REVIEW_USERID: userId,
      KEY_REVIEW_ORDERID: orderId,
      KEY_REVIEW_ITEMINDEX: itemIndex,
      KEY_REVIEW_TITLE: itemTitle,
      KEY_REVIEW_MARKETID: marketId,
      KEY_REVIEW_REVIEW: review,
      KEY_REVIEW_SATISFACTION: satisfaction,
      KEY_REVIEW_RATING: rating,
      KEY_REVIEW_TIMESTAMP: Timestamp.fromDate(timestamp),
    };
  }
}
