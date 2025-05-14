// Flutter foundation kütüphanesini (ChangeNotifier için) ve uygulama içi dosyaları import eder.
import 'package:flutter/foundation.dart'; // ChangeNotifier sınıfı için.
import '../api/api_servisi.dart'; // API isteklerini yapmak için.
import '../modeller/egitim_detay_model.dart'; // Eğitim detay ve adım modelleri için.

/// [EgitimDetayProvider], seçilen bir eğitimin detaylarını, adımlarını ve bu adımlar
/// arasındaki geçiş durumunu yöneten bir `ChangeNotifier` sınıfıdır.
/// API'den eğitim detaylarını çeker, mevcut eğitim adımını takip eder ve UI'ı günceller.
class EgitimDetayProvider with ChangeNotifier {
  // API isteklerini yapmak için ApiServisi örneği.
  final ApiServisi _apiServisi = ApiServisi();

  // State değişkenleri:
  EgitimDetayModel? _egitimDetay; // Yüklenen eğitimin detaylarını ve adımlarını tutar. Null olabilir.
  bool _isLoading = false; // Veri yükleme işlemi devam ediyorsa true olur.
  String? _hataMesaji; // Veri yükleme sırasında bir hata oluştuysa hata mesajını tutar. Null olabilir.
  int _mevcutAdimIndex = 0; // Gösterilmekte olan eğitim adımının indeksi (0'dan başlar).

  // Getter'lar (UI'ın state'e erişmesi için):
  EgitimDetayModel? get egitimDetay => _egitimDetay;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;
  int get mevcutAdimIndex => _mevcutAdimIndex;

  /// Mevcut gösterilen eğitim adımını döndürür.
  /// Eğer eğitim detayı veya adımlar yüklenmemişse ya da index geçersizse null döner.
  EgitimAdimModel? get mevcutAdim {
    if (_egitimDetay != null &&
        _egitimDetay!.adimlar.isNotEmpty &&
        _mevcutAdimIndex >= 0 &&
        _mevcutAdimIndex < _egitimDetay!.adimlar.length) {
      return _egitimDetay!.adimlar[_mevcutAdimIndex];
    }
    return null; // Geçerli bir adım bulunamazsa.
  }

  /// Mevcut adımın eğitimdeki son adım olup olmadığını kontrol eder.
  bool get sonAdimdaMi {
    if (_egitimDetay == null || _egitimDetay!.adimlar.isEmpty) return false; // Adım yoksa son adımda olamaz.
    return _mevcutAdimIndex == _egitimDetay!.adimlar.length - 1;
  }

  /// Belirli bir `egitimId`'ye sahip eğitimin detaylarını API'den asenkron olarak çeker.
  /// Bu işlem sırasında `_isLoading` ve `_hataMesaji` state'lerini günceller.
  Future<void> egitimDetayiniGetir(int egitimId) async {
    _isLoading = true;
    _hataMesaji = null;
    _egitimDetay = null; // Yeni bir eğitim çekilirken önceki veriyi temizler.
    _mevcutAdimIndex = 0; // Yeni eğitim için adım indeksini sıfırlar.
    notifyListeners(); // Yükleme başladığını ve state'in sıfırlandığını UI'a bildirir.

    try {
      // ApiServisi üzerinden eğitim detayını çeker.
      _egitimDetay = await _apiServisi.getEgitimDetay(egitimId);
    } catch (e) {
      // Hata oluşursa, hata mesajını ayıklar ve kaydeder.
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false; // Yükleme bitti.
    notifyListeners(); // Yükleme bittiğini ve verinin geldiğini/hata olduğunu UI'a bildirir.
  }

  /// Mevcut eğitim adımından bir sonraki adıma geçer.
  /// Eğer son adımda değilse `_mevcutAdimIndex`'i artırır ve UI'ı günceller.
  void sonrakiAdimaGec() {
    if (_egitimDetay != null && _mevcutAdimIndex < _egitimDetay!.adimlar.length - 1) {
      _mevcutAdimIndex++;
      notifyListeners(); // Değişikliği UI'a bildirir.
    }
  }

  /// `PageView` widget'ından gelen sayfa değişikliği olayını işler.
  /// `_mevcutAdimIndex`'i yeni indekse ayarlar, eğer gerçekten değişmişse UI'ı günceller.
  /// Bu, `PageView` ile manuel kaydırma yapıldığında state'in senkronize kalmasını sağlar.
  void setMevcutAdimIndexFromPageView(int newIndex){
    if (_egitimDetay != null && newIndex >= 0 && newIndex < _egitimDetay!.adimlar.length) {
      // Sadece index gerçekten değiştiyse notifyListeners çağrılır, gereksiz rebuild'leri önler.
      if (_mevcutAdimIndex != newIndex) {
        _mevcutAdimIndex = newIndex;
        notifyListeners();
      }
    }
  }

  /// Provider'ın tüm state'ini başlangıç durumuna sıfırlar.
  /// Bu, eğitim detay ekranından çıkıldığında veya yeni bir eğitim yüklenmeden önce çağrılabilir.
  void resetState() {
    _egitimDetay = null;
    _mevcutAdimIndex = 0;
    _isLoading = false;
    _hataMesaji = null;
    notifyListeners(); // UI'ın bu temizlenmiş durumu yansıtması için.
  }
}
