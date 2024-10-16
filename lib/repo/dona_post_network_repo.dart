import 'package:cloud_firestore/cloud_firestore.dart';

class DonaPostNetworkRepo {

  void getData(String select){
    FirebaseFirestore.instance
        .collection('DonaPosts')
        .where('category', isEqualTo: select)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.data());
      });
    });
  }
}

DonaPostNetworkRepo donaPostNetworkRepo = DonaPostNetworkRepo();