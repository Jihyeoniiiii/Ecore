
import 'package:flutter/material.dart';

import 'firestore/dona_post_model.dart';

class DonaPostModelState extends ChangeNotifier{
  DonaPostModel? _donaPostModel;

  DonaPostModel get donaPostModel => _donaPostModel!;

  set donaPostModel(DonaPostModel donaPostModel){
    _donaPostModel = donaPostModel;
    notifyListeners();
  }

}