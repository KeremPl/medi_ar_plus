import 'dart:convert'; // Eklendi
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_servisi.dart';
import '../modeller/kullanici_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiServisi _apiServisi = ApiServisi();
  final SharedPreferences _prefs;

  KullaniciModel? _mevcutKullanici;
  int? _mevcutKullaniciId;
  bool _isLoading = false;
  String? _hataMesaji;
  bool _initialAuthCheckDone = false;

  AuthProvider(this._prefs) {
    _kullaniciIdYukle();
  }

  KullaniciModel? get mevcutKullanici => _mevcutKullanici;
  int? get mevcutKullaniciId => _mevcutKullaniciId;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;
  bool get initialAuthCheckDone => _initialAuthCheckDone;


  Future<void> _kullaniciIdYukle() async {
    _isLoading = true;
    notifyListeners();
    _mevcutKullaniciId = _prefs.getInt('mevcutKullaniciId');
    if (_mevcutKullaniciId != null) {
      final String? kullaniciJson = _prefs.getString('mevcutKullaniciDetay');
      if (kullaniciJson != null) {
        try {
          _mevcutKullanici = KullaniciModel.fromJson(jsonDecode(kullaniciJson)); // jsonDecode kullanıldı
        } catch (e) {
          print("Kaydedilmiş kullanıcı detayı okunamadı: $e"); 
          await cikisYap();
        }
      }
    }
    _isLoading = false;
    _initialAuthCheckDone = true;
    notifyListeners();
  }

  Future<bool> login(String kullaniciAdi, String sifre) async {
    _isLoading = true;
    _hataMesaji = null;
    notifyListeners();
    try {
      _mevcutKullanici = await _apiServisi.login(kullaniciAdi, sifre);
      _mevcutKullaniciId = _mevcutKullanici?.id;
      if (_mevcutKullaniciId != null && _mevcutKullanici != null) {
        await _prefs.setInt('mevcutKullaniciId', _mevcutKullaniciId!);
        await _prefs.setString('mevcutKullaniciDetay', jsonEncode(_mevcutKullanici!.toJson())); // jsonEncode kullanıldı
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception("Giriş başarısız oldu.");
      }
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> register(String ad, String soyad, String kullaniciAdi, String email, String sifre) async {
    _isLoading = true;
    _hataMesaji = null;
    notifyListeners();
    try {
      String mesaj = await _apiServisi.register(ad, soyad, kullaniciAdi, email, sifre);
      _isLoading = false;
      notifyListeners();
      return mesaj;
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> cikisYap() async {
    _mevcutKullanici = null;
    _mevcutKullaniciId = null;
    await _prefs.remove('mevcutKullaniciId');
    await _prefs.remove('mevcutKullaniciDetay');
    _hataMesaji = null;
    notifyListeners();
  }
}
