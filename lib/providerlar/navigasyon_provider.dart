import 'package:flutter/foundation.dart';

class NavigasyonProvider with ChangeNotifier {
  int _seciliIndex = 0;

  int get seciliIndex => _seciliIndex;

  void seciliIndexAta(int index) {
    if (_seciliIndex != index) {
      _seciliIndex = index;
      notifyListeners();
    }
  }
}
