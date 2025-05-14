// Flutter foundation kütüphanesini (ChangeNotifier için) ve SharedPreferences paketini import eder.
import 'package:flutter/foundation.dart'; // ChangeNotifier sınıfı için.
import 'package:shared_preferences/shared_preferences.dart'; // Kullanıcı ID'sini yerel depodan okumak için.
// Uygulama içi API servisini ve profil modelini import eder.
import '../api/api_servisi.dart';
import '../modeller/profil_model.dart';

/// [ProfilProvider], kullanıcının profil bilgilerini (kişisel detaylar ve kazanılan rozetler)
/// yöneten bir `ChangeNotifier` sınıfıdır.
/// API'den profil verilerini çeker, yükleme durumunu ve olası hataları yönetir.
/// Kullanıcının ID'sini SharedPreferences'tan okur.
class ProfilProvider with ChangeNotifier {
  // API isteklerini yapmak için ApiServisi örneği.
  final ApiServisi _apiServisi = ApiServisi();
  // SharedPreferences örneği, constructor ile enjekte edilir.
  final SharedPreferences _prefs;

  // State değişkenleri:
  ProfilModel? _profilModel; // Yüklenen kullanıcının profil bilgilerini tutar. Null olabilir.
  bool _isLoading = false; // Veri yükleme işlemi devam ediyorsa true olur.
  String? _hataMesaji; // Veri yükleme sırasında bir hata oluştuysa hata mesajını tutar. Null olabilir.

  /// [ProfilProvider] constructor'ı.
  /// SharedPreferences örneğini alır.
  ProfilProvider(this._prefs);

  // Getter'lar (UI'ın state'e erişmesi için):
  ProfilModel? get profilModel => _profilModel;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;

  /// Mevcut kullanıcının profil bilgilerini API'den asenkron olarak çeker.
  /// SharedPreferences'tan 'mevcutKullaniciId' anahtarını okuyarak kullanıcı ID'sini alır.
  Future<void> kullaniciProfiliniGetir() async {
    // Geliştirme için loglama: Metodun ne zaman çağrıldığını gösterir.
    print('[ProfilProvider] kullaniciProfiliniGetir çağrıldı.');
    // SharedPreferences'tan kaydedilmiş kullanıcı ID'sini alır.
    final int? kullaniciId = _prefs.getInt('mevcutKullaniciId');

    // Eğer kullanıcı ID'si bulunamazsa (kullanıcı giriş yapmamış veya oturum bilgisi silinmişse).
    if (kullaniciId == null) {
      _hataMesaji = "Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.";
      _profilModel = null; // Profil modelini temizle.
      // Geliştirme için loglama: Kullanıcı ID'sinin bulunamadığını belirtir.
      print('[ProfilProvider] Kullanıcı ID bulunamadı, profil çekilemedi.');
      // Bu durumda notifyListeners() çağırmak UI'da bir güncelleme tetikleyebilir,
      // ancak UI zaten bu duruma (hataMesaji dolu, profilModel null) göre ayarlanmış olmalıdır.
      // İsteğe bağlı olarak çağrılabilir: notifyListeners();
      return; // İşlemi sonlandır.
    }

    _isLoading = true;
    _hataMesaji = null; // Yeni bir istek öncesinde önceki hata mesajlarını temizler.
    // Veri çekilirken eski profil modelini silmek, UI'da anlık bir sıçramaya (boş ekran) neden olabilir.
    // Bu yüzden, `_profilModel = null;` satırı genellikle burada yorum satırı olarak bırakılır veya
    // UI'da yükleme göstergesi aktifken eski veri gösterilmeye devam eder.
    notifyListeners(); // Yükleme başladığını UI'a bildirir.

    try {
      // ApiServisi üzerinden kullanıcı profilini çeker.
      _profilModel = await _apiServisi.getKullaniciProfil(kullaniciId);
      // Geliştirme için loglama: Profilin kimin için çekildiğini gösterir.
      print('[ProfilProvider] Profil başarıyla çekildi. Kullanıcı: ${_profilModel?.kullaniciBilgileri.kullaniciAdi}');
    } catch (e) {
      // Hata oluşursa, hata mesajını ayıklar ve kaydeder.
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
      _profilModel = null; // Hata durumunda profil modelini temizler.
      // Geliştirme için loglama: Oluşan hatayı gösterir.
      print('[ProfilProvider] Profil çekilirken hata: $_hataMesaji');
    }
    _isLoading = false; // Yükleme bitti.
    notifyListeners(); // Yükleme bittiğini ve verinin geldiğini/hata olduğunu UI'a bildirir.
  }

  /// Provider'ın tüm state'ini başlangıç durumuna sıfırlar.
  /// Bu, örneğin kullanıcı çıkış yaptığında çağrılır.
  void resetState() {
    _profilModel = null;
    _isLoading = false;
    _hataMesaji = null;
    // Geliştirme için loglama: State'in resetlendiğini belirtir.
    print('[ProfilProvider] State resetlendi.');
    notifyListeners(); // UI'ın bu temizlenmiş durumu yansıtması için.
  }
}
