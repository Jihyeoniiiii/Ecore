import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/repo/transformers.dart';

import '../cosntants/firestore_key.dart';
import '../models/firestore/user_model.dart';

class UserNetworkRepository with Transformers {
  Future<void> attemptCreateUser({required String userkey, required String email}) async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection(COLLECTION_USERS).doc(userkey);

    DocumentSnapshot snapshot = await userRef.get();
    if (!snapshot.exists) {
      return await userRef.set(UserModel.getMapForCreateUser(email));
    }
  }

  Stream<UserModel>getUserModelStream(String userKey) {
    return FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .doc(userKey)
        .snapshots().transform(toUser);
  }
}

UserNetworkRepository userNetworkRepository = UserNetworkRepository();
//