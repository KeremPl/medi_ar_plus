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
    final int? kullaniciId = _prefs.getInt('mevcutKullaniciId');
    if (kullaniciId == null) {
      _hataMesaji = "Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.";
      _profilModel = null; // Önceki profili temizle
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hataMesaji = null;
    _profilModel = null; // Yeni profil yüklenirken eskiyi temizle
    notifyListeners();
    try {
      _profilModel = await _apiServisi.getKullaniciProfil(kullaniciId);
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false;
    notifyListeners();
  }
}
