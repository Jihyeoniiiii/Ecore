import 'package:ecore/models/firestore/sell_post_model.dart';
import 'package:flutter/material.dart';

class SellPostModelState extends ChangeNotifier{
  SellPostModel? _sellPostModel;

  SellPostModel get sellPostModel => _sellPostModel!;

  set sellPostModel(SellPostModel sellPostModel){
    _sellPostModel = sellPostModel;
    notifyListeners();
  }

}