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
  EgitimAdimModel? get mevcutAdim =>
      _egitimDetay != null && _egitimDetay!.adimlar.isNotEmpty && _mevcutAdimIndex < _egitimDetay!.adimlar.length
          ? _egitimDetay!.adimlar[_mevcutAdimIndex]
          : null;
  bool get sonAdimdaMi =>
      _egitimDetay != null && _mevcutAdimIndex == _egitimDetay!.adimlar.length - 1;


  Future<void> egitimDetayiniGetir(int egitimId) async {
    _isLoading = true;
    _hataMesaji = null;
    _egitimDetay = null; // Yeni eğitim yüklenirken eski detayı temizle
    _mevcutAdimIndex = 0; // Adım indeksini sıfırla
    notifyListeners();
    try {
      _egitimDetay = await _apiServisi.getEgitimDetay(egitimId);
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false;
    notifyListeners();
  }

  void sonrakiAdimaGec() {
    if (_egitimDetay != null && _mevcutAdimIndex < _egitimDetay!.adimlar.length - 1) {
      _mevcutAdimIndex++;
      notifyListeners();
    }
  }

  void resetAdim() {
    _mevcutAdimIndex = 0;
    // notifyListeners(); // Bu genellikle egitimDetayiniGetir içinde çağrıldığı için gerekmeyebilir
  }
}
