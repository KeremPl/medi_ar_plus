/// [ApiSabitleri] sınıfı, uygulama genelinde kullanılacak olan API ile ilgili
/// sabit değerleri (temel URL ve endpoint yolları gibi) merkezi bir yerde toplar.
/// Bu, API adreslerinde veya endpoint'lerinde bir değişiklik olduğunda sadece
/// bu dosyayı güncellemenin yeterli olmasını sağlar.
class ApiSabitleri {
  /// API'nin temel (kök) URL'si. Tüm endpoint istekleri bu URL üzerine inşa edilir.
  /// Örnek: "http://example.com/api/"
  static const String kokUrl = "http://workwatchpro.xyz/api/";

  // API Endpoint'leri:
  // Her bir sabit, API'deki belirli bir işlevi yerine getiren PHP betiğinin
  // veya yolunun adını temsil eder.

  /// Yeni kullanıcı kaydı için endpoint.
  static const String register = "register.php";

  /// Mevcut kullanıcı girişi için endpoint.
  static const String login = "login.php";

  /// Tüm eğitimleri listelemek için endpoint.
  static const String getEgitimler = "get_egitimler.php";

  /// Belirli bir eğitimin detaylarını almak için endpoint.
  /// Genellikle `?egitim_id=X` gibi bir parametre ile kullanılır.
  static const String getEgitimDetay = "get_egitim_detay.php";

  /// Belirli bir testin sorularını almak için endpoint.
  /// Genellikle `?test_id=X` gibi bir parametre ile kullanılır.
  static const String getTestSorular = "get_test_sorular.php";

  /// Bir testin sonucunu (doğru/yanlış sayısı) sunucuya göndermek ve puan/rozet almak için endpoint.
  /// Genellikle `?kullanici_id=X&test_id=Y&dogru_sayisi=Z&yanlis_sayisi=W` gibi parametreler alır.
  static const String submitTestSonuc = "submit_test_sonuc.php";

  /// Belirli bir kullanıcının profil bilgilerini (kullanıcı detayları ve kazanılan rozetler) almak için endpoint.
  /// Genellikle `?kullanici_id=X` gibi bir parametre ile kullanılır.
  static const String getKullaniciProfil = "get_kullanici_profil.php";
}
