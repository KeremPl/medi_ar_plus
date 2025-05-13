import 'package:flutter/foundation.dart';
import '../api/api_servisi.dart';
import '../modeller/egitim_model.dart';

class EgitimProvider with ChangeNotifier {
  final ApiServisi _apiServisi = ApiServisi();
  List<EgitimModel> _egitimler = [];
  bool _isLoading = false;
  String? _hataMesaji;

  List<EgitimModel> get egitimler => _egitimler;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;

  Future<void> egitimleriGetir() async {
    _isLoading = true;
    _hataMesaji = null;
    notifyListeners();
    try {
      _egitimler = await _apiServisi.getEgitimler();
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false;
    notifyListeners();
  }
}
