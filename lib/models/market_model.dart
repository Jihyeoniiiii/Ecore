import 'package:flutter/material.dart';

import 'firestore/market_model.dart';

class MarketModelState extends ChangeNotifier {
  MarketModel? _marketModel;

  MarketModel? get marketModel => _marketModel;

  set marketModel(MarketModel? marketModel) {
    _marketModel = marketModel;
    notifyListeners();
  }
}
