import 'package:flutter/foundation.dart';
import '../api/api_servisi.dart';
import '../modeller/egitim_detay_model.dart';

class EgitimDetayProvider with ChangeNotifier {
  final ApiServisi _apiServisi = ApiServisi();
  EgitimDetayModel? _egitimDetay;
  bool _isLoading = false;
  String? _hataMesaji;
  int _mevcutAdimIndex = 0;

  EgitimDetayModel? get egitimDetay => _egitimDetay;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;
  int get mevcutAdimIndex => _mevcutAdimIndex;

  EgitimAdimModel? get mevcutAdim {
    if (_egitimDetay != null &&
        _egitimDetay!.adimlar.isNotEmpty &&
        _mevcutAdimIndex >= 0 &&
        _mevcutAdimIndex < _egitimDetay!.adimlar.length) {
      return _egitimDetay!.adimlar[_mevcutAdimIndex];
    }
    return null;
  }

  bool get sonAdimdaMi {
    if (_egitimDetay == null || _egitimDetay!.adimlar.isEmpty) return false;
    return _mevcutAdimIndex == _egitimDetay!.adimlar.length - 1;
  }

  Future<void> egitimDetayiniGetir(int egitimId) async {
    _isLoading = true;
    _hataMesaji = null;
    _egitimDetay = null; // Önceki veriyi temizle
    _mevcutAdimIndex = 0; // Adım index'ini sıfırla
    notifyListeners(); // Yükleme başladığını UI'a bildir
    try {
      _egitimDetay = await _apiServisi.getEgitimDetay(egitimId);
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false;
    notifyListeners(); // Yükleme bittiğini ve verinin geldiğini/hata olduğunu bildir
  }

  void sonrakiAdimaGec() {
    if (_egitimDetay != null && _mevcutAdimIndex < _egitimDetay!.adimlar.length - 1) {
      _mevcutAdimIndex++;
      notifyListeners();
    }
  }

  void setMevcutAdimIndexFromPageView(int newIndex){
    if (_egitimDetay != null && newIndex >= 0 && newIndex < _egitimDetay!.adimlar.length) {
      if (_mevcutAdimIndex != newIndex) { // Sadece değiştiyse notify et
        _mevcutAdimIndex = newIndex;
        notifyListeners();
      }
    }
  }

  void resetState() {
    _egitimDetay = null;
    _mevcutAdimIndex = 0;
    _isLoading = false;
    _hataMesaji = null;
    notifyListeners(); // UI'ın bu temizlenmiş durumu yansıtması için
  }
}
