// Dart'ın temel kütüphanelerinden `convert` (JSON işlemleri için) ve `foundation` (ChangeNotifier için) import edilir.
import 'dart:convert'; // jsonEncode ve jsonDecode için.
import 'package:flutter/foundation.dart'; // ChangeNotifier sınıfı için.
import 'package:shared_preferences/shared_preferences.dart'; // Yerel depolama (kullanıcı oturumu) için.
// Uygulama içi API servisini ve kullanıcı modelini import eder.
import '../api/api_servisi.dart';
import '../modeller/kullanici_model.dart';

/// [AuthProvider], kullanıcı kimlik doğrulama (authentication) işlemlerini ve
/// oturum durumunu yöneten bir `ChangeNotifier` sınıfıdır.
/// Kullanıcının giriş yapması, kaydolması, çıkış yapması ve mevcut oturum bilgilerinin
/// SharedPreferences üzerinden yüklenmesi gibi işlevleri sağlar.
class AuthProvider with ChangeNotifier {
  // API isteklerini yapmak için ApiServisi örneği.
  final ApiServisi _apiServisi = ApiServisi();
  // SharedPreferences örneği, constructor ile enjekte edilir.
  final SharedPreferences _prefs;

  // State değişkenleri:
  KullaniciModel? _mevcutKullanici; // Giriş yapmış kullanıcının detaylarını tutar. Null olabilir.
  int? _mevcutKullaniciId; // Giriş yapmış kullanıcının ID'sini tutar. Null olabilir.
  bool _isLoading = false; // Bir işlem (login, register vb.) devam ediyorsa true olur.
  String? _hataMesaji; // Son işlemde bir hata oluştuysa hata mesajını tutar. Null olabilir.
  bool _initialAuthCheckDone = false; // Uygulama ilk açıldığında SharedPreferences'tan kullanıcı kontrolünün yapılıp yapılmadığını belirtir.

  /// [AuthProvider] constructor'ı.
  /// SharedPreferences örneğini alır ve hemen `_kullaniciIdYukle` metodunu çağırarak
  /// kaydedilmiş bir oturum olup olmadığını kontrol eder.
  AuthProvider(this._prefs) {
    _kullaniciIdYukle();
  }

  // Getter'lar (UI'ın state'e erişmesi için):
  KullaniciModel? get mevcutKullanici => _mevcutKullanici;
  int? get mevcutKullaniciId => _mevcutKullaniciId;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;
  bool get initialAuthCheckDone => _initialAuthCheckDone;


  /// SharedPreferences'tan kaydedilmiş kullanıcı ID'sini ve detaylarını yükler.
  /// Uygulama ilk açıldığında çağrılır.
  Future<void> _kullaniciIdYukle() async {
    _isLoading = true; // Yükleme başladığını belirtir.
    notifyListeners(); // Dinleyicilere (UI'a) state değişikliğini bildirir.

    // Kaydedilmiş kullanıcı ID'sini alır.
    _mevcutKullaniciId = _prefs.getInt('mevcutKullaniciId');
    if (_mevcutKullaniciId != null) {
      // Eğer kullanıcı ID'si varsa, kaydedilmiş kullanıcı detaylarını (JSON string) alır.
      final String? kullaniciJson = _prefs.getString('mevcutKullaniciDetay');
      if (kullaniciJson != null) {
        try {
          // JSON string'ini KullaniciModel'e dönüştürür.
          _mevcutKullanici = KullaniciModel.fromJson(jsonDecode(kullaniciJson));
        } catch (e) {
          // Kaydedilmiş kullanıcı detayı okunamadıysa veya formatı bozuksa,
          // güvenlik açısından mevcut oturumu sonlandırır.
          // print("Kaydedilmiş kullanıcı detayı okunamadı: $e"); // Geliştirme logu, üretimde kaldırılabilir.
          await cikisYap(); // Hatalı veriyi temizle.
        }
      }
    }
    _isLoading = false; // Yükleme bitti.
    _initialAuthCheckDone = true; // İlk kontrol tamamlandı.
    notifyListeners(); // Son state'i UI'a bildir.
  }

  /// Kullanıcıyı sisteme giriş yaptırır.
  ///
  /// Parametreler:
  ///   [kullaniciAdi]: Kullanıcının girdiği kullanıcı adı.
  ///   [sifre]: Kullanıcının girdiği şifre.
  ///
  /// Dönüş Değeri:
  ///   Giriş başarılıysa `true`, değilse `false` döndürür.
  Future<bool> login(String kullaniciAdi, String sifre) async {
    _isLoading = true;
    _hataMesaji = null; // Önceki hata mesajlarını temizle.
    notifyListeners();
    try {
      // ApiServisi üzerinden login isteği yapar.
      _mevcutKullanici = await _apiServisi.login(kullaniciAdi, sifre);
      _mevcutKullaniciId = _mevcutKullanici?.id; // Kullanıcı modelinden ID'yi al.

      // Eğer kullanıcı ID'si ve kullanıcı modeli başarıyla alındıysa.
      if (_mevcutKullaniciId != null && _mevcutKullanici != null) {
        // Kullanıcı ID'sini ve detaylarını (JSON string olarak) SharedPreferences'a kaydeder.
        await _prefs.setInt('mevcutKullaniciId', _mevcutKullaniciId!);
        await _prefs.setString('mevcutKullaniciDetay', jsonEncode(_mevcutKullanici!.toJson()));
        _isLoading = false;
        notifyListeners();
        return true; // Giriş başarılı.
      } else {
        // API'den beklenen yanıt gelmediyse.
        throw Exception("Giriş başarısız, sunucudan kullanıcı bilgisi alınamadı.");
      }
    } catch (e) {
      // Hata oluşursa, hata mesajını ayıklar ve kaydeder.
      _hataMesaji = e.toString().replaceFirst("Exception: ", ""); // "Exception: " önekini kaldır.
      _isLoading = false;
      notifyListeners();
      return false; // Giriş başarısız.
    }
  }

  /// Yeni bir kullanıcı kaydı oluşturur.
  ///
  /// Parametreler:
  ///   [ad], [soyad], [kullaniciAdi], [email], [sifre]: Kullanıcının kayıt formunda girdiği bilgiler.
  ///
  /// Dönüş Değeri:
  ///   Kayıt başarılıysa API'den dönen mesajı (`String?`), değilse `null` döndürür.
  Future<String?> register(String ad, String soyad, String kullaniciAdi, String email, String sifre) async {
    _isLoading = true;
    _hataMesaji = null;
    notifyListeners();
    try {
      // ApiServisi üzerinden register isteği yapar.
      String mesaj = await _apiServisi.register(ad, soyad, kullaniciAdi, email, sifre);
      _isLoading = false;
      notifyListeners();
      return mesaj; // Başarılı kayıt mesajı.
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return null; // Kayıt başarısız.
    }
  }

  /// Kullanıcının oturumunu sonlandırır (çıkış yapar).
  /// SharedPreferences'tan kullanıcı bilgilerini siler ve state'i sıfırlar.
  Future<void> cikisYap() async {
    _mevcutKullanici = null;
    _mevcutKullaniciId = null;
    // SharedPreferences'tan ilgili anahtarları kaldırır.
    await _prefs.remove('mevcutKullaniciId');
    await _prefs.remove('mevcutKullaniciDetay');
    _hataMesaji = null; // Hata mesajını temizle.
    // _isLoading genellikle çıkış işleminde false kalır, anlık bir işlem olduğu için.
    // Ancak gerekirse ayarlanabilir.
    notifyListeners(); // State değişikliğini UI'a bildir.
  }
}
