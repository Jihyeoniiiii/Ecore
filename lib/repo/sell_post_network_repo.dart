import 'package:cloud_firestore/cloud_firestore.dart';

class SellPostNetworkRepo {

  void getData(String select){
    FirebaseFirestore.instance
        .collection('SellPosts')
        .where('category', isEqualTo: select)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.data());
      });
    });
  }
}

SellPostNetworkRepo sellPostNetworkRepo = SellPostNetworkRepo();