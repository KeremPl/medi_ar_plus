import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_servisi.dart';
import '../modeller/profil_model.dart';

class ProfilProvider with ChangeNotifier {
  final ApiServisi _apiServisi = ApiServisi();
  final SharedPreferences _prefs;

  ProfilModel? _profilModel;
  bool _isLoading = false;
  String? _hataMesaji;

  ProfilProvider(this._prefs);

  ProfilModel? get profilModel => _profilModel;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;

  Future<void> kullaniciProfiliniGetir() async {
    print('[ProfilProvider] kullaniciProfiliniGetir çağrıldı.');
    final int? kullaniciId = _prefs.getInt('mevcutKullaniciId');
    if (kullaniciId == null) {
      _hataMesaji = "Kullanıcı oturumu bulunamadı.";
      _profilModel = null;
      print('[ProfilProvider] Kullanıcı ID yok, profil çekilemedi.');
      // notifyListeners(); // Gereksiz, UI zaten bu duruma göre ayarlanmalı
      return;
    }
    _isLoading = true;
    _hataMesaji = null;
    // _profilModel = null; // Veri çekilirken eskiyi silme, UI'da sıçrama yapar
    notifyListeners();
    try {
      _profilModel = await _apiServisi.getKullaniciProfil(kullaniciId);
      print('[ProfilProvider] Profil çekildi. Kullanıcı: ${_profilModel?.kullaniciBilgileri.kullaniciAdi}');
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
      _profilModel = null;
      print('[ProfilProvider] Profil çekilirken hata: $_hataMesaji');
    }
    _isLoading = false;
    notifyListeners();
  }

  void resetState() {
    _profilModel = null;
    _isLoading = false;
    _hataMesaji = null;
    print('[ProfilProvider] State resetlendi.');
    notifyListeners();
  }
}
