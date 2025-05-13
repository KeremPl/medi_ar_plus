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
        _mevcutAdimIndex >= 0 && // Güvenlik kontrolü
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
    print('[EgitimDetayProvider] egitimDetayiniGetir çağrıldı. ID: $egitimId');
    _isLoading = true;
    _hataMesaji = null;
    _egitimDetay = null;
    _mevcutAdimIndex = 0;
    notifyListeners(); // Yükleme başladığını bildir
    try {
      _egitimDetay = await _apiServisi.getEgitimDetay(egitimId);
      print('[EgitimDetayProvider] API\'den yanıt alındı. Adım sayısı: ${_egitimDetay?.adimlar.length}');
      if (_egitimDetay != null && _egitimDetay!.adimlar.isNotEmpty) {
        print('[EgitimDetayProvider] İlk adımın açıklaması (kısmi): ${_egitimDetay!.adimlar.first.adimAciklama?.substring(0, (_egitimDetay!.adimlar.first.adimAciklama?.length ?? 0) > 20 ? 20 : _egitimDetay!.adimlar.first.adimAciklama?.length)}...');
      } else if (_egitimDetay != null && _egitimDetay!.adimlar.isEmpty) {
        print('[EgitimDetayProvider] Eğitim için adım bulunamadı (API boş adım listesi döndü).');
      }
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
      print('[EgitimDetayProvider] Hata oluştu: $_hataMesaji');
    }
    _isLoading = false;
    print('[EgitimDetayProvider] Yükleme bitti, notifyListeners çağrılıyor.');
    notifyListeners();
  }

  void sonrakiAdimaGec() {
    if (_egitimDetay != null && _mevcutAdimIndex < _egitimDetay!.adimlar.length - 1) {
      _mevcutAdimIndex++;
      print('[EgitimDetayProvider] Sonraki adıma geçildi. Yeni index: $_mevcutAdimIndex');
      notifyListeners();
    } else {
      print('[EgitimDetayProvider] Sonraki adıma geçilemedi, zaten son adımda veya eğitim detayı yok.');
    }
  }

  void setMevcutAdimIndexFromPageView(int newIndex){ // PageView için yeni metod
    if (_egitimDetay != null && newIndex >= 0 && newIndex < _egitimDetay!.adimlar.length) {
      if (_mevcutAdimIndex != newIndex) {
        _mevcutAdimIndex = newIndex;
        print('[EgitimDetayProvider] PageView tarafından adım indexi güncellendi: $_mevcutAdimIndex');
        notifyListeners();
      }
    }
  }

  void resetAdim() {
    _mevcutAdimIndex = 0;
    _egitimDetay = null; // Detayı da sıfırla ki tekrar yüklenirken eski veri görünmesin
    _hataMesaji = null;
    print('[EgitimDetayProvider] Adım ve detay resetlendi.');
    // notifyListeners(); // Bu genellikle ekran pop edilirken çağrılır, yeni ekran açılırken zaten yükleme olur.
  }
}
