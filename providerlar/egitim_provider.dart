// Flutter foundation kütüphanesini (ChangeNotifier için) ve uygulama içi dosyaları import eder.
import 'package:flutter/foundation.dart'; // ChangeNotifier sınıfı için.
import '../api/api_servisi.dart'; // API isteklerini yapmak için.
import '../modeller/egitim_model.dart'; // Eğitim modeli için.

/// [EgitimProvider], uygulamadaki eğitimlerin listesini yöneten bir `ChangeNotifier` sınıfıdır.
/// API'den eğitim listesini çeker, yükleme durumunu ve olası hataları yönetir,
/// ve bu bilgileri UI'a sunar.
class EgitimProvider with ChangeNotifier {
  // API isteklerini yapmak için ApiServisi örneği.
  final ApiServisi _apiServisi = ApiServisi();

  // State değişkenleri:
  List<EgitimModel> _egitimler = []; // Yüklenen eğitimlerin listesini tutar. Başlangıçta boştur.
  bool _isLoading = false; // Veri yükleme işlemi devam ediyorsa true olur.
  String? _hataMesaji; // Veri yükleme sırasında bir hata oluştuysa hata mesajını tutar. Null olabilir.

  // Getter'lar (UI'ın state'e erişmesi için):
  List<EgitimModel> get egitimler => _egitimler;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;

  /// Tüm eğitimleri API'den asenkron olarak çeker.
  /// Bu işlem sırasında `_isLoading`, `_hataMesaji` ve `_egitimler` state'lerini günceller.
  Future<void> egitimleriGetir() async {
    // Geliştirme için loglama: Metodun ne zaman çağrıldığını gösterir.
    print('[EgitimProvider] egitimleriGetir çağrıldı.');
    _isLoading = true;
    _hataMesaji = null; // Yeni bir istek öncesinde önceki hata mesajlarını temizler.

    // İlk yüklemede UI'ın hemen tepki vermesi için burada bir notifyListeners() çağrısı yapılabilirdi.
    // Ancak, veri geldikten sonra (veya hata oluştuğunda) zaten tekrar çağrılacağı için
    // bu genellikle zorunlu değildir, performans optimizasyonu olarak düşünülebilir.
    // notifyListeners();

    try {
      // ApiServisi üzerinden eğitimleri çeker.
      _egitimler = await _apiServisi.getEgitimler();
      // Geliştirme için loglama: Kaç adet eğitim çekildiğini gösterir.
      print('[EgitimProvider] Eğitimler başarıyla çekildi: ${_egitimler.length} adet.');
    } catch (e) {
      // Hata oluşursa, hata mesajını ayıklar ve kaydeder.
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
      _egitimler = []; // Hata durumunda eğitim listesini boşaltır, böylece UI'da eski veri kalmaz.
      // Geliştirme için loglama: Oluşan hatayı gösterir.
      print('[EgitimProvider] Eğitimler çekilirken hata: $_hataMesaji');
    }
    _isLoading = false; // Yükleme bitti.
    notifyListeners(); // Yükleme bittiğini ve verinin geldiğini/hata olduğunu UI'a bildirir.
  }

  /// Provider'ın tüm state'ini başlangıç durumuna sıfırlar.
  /// Bu, örneğin kullanıcı çıkış yaptığında veya state'in temizlenmesi gereken
  /// başka bir durumda çağrılabilir.
  void resetState() {
    _egitimler = [];
    _isLoading = false;
    _hataMesaji = null;
    // Geliştirme için loglama: State'in resetlendiğini belirtir.
    print('[EgitimProvider] State resetlendi.');
    // Bu notifyListeners çağrısı önemlidir, çünkü UI'ın state sıfırlandıktan sonra
    // güncellenmesi gerekir (örn: listedeki eski verilerin temizlenmesi).
    notifyListeners();
  }
}
