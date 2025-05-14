// Gerekli paketlerin ve dosyaların import edilmesi.
import 'dart:convert'; // JSON verilerini kodlamak ve çözmek için.
import 'dart:async'; // Asenkron işlemler ve TimeoutException için.
import 'dart:io'; // Dosya ve ağ işlemleri, SocketException için.
import 'package:http/http.dart' as http; // HTTP istekleri yapmak için.
import '../sabitler/api_sabitleri.dart'; // API endpoint'leri ve temel URL gibi sabitleri içerir.
import '../modeller/kullanici_model.dart'; // KullaniciModel veri yapısını tanımlar.
import '../modeller/egitim_model.dart'; // EgitimModel veri yapısını tanımlar.
import '../modeller/egitim_detay_model.dart'; // EgitimDetayModel veri yapısını tanımlar.
import '../modeller/soru_model.dart'; // SoruModel ve ilgili modelleri tanımlar.
// import '../modeller/rozet_model.dart'; // ProfilModel içinde zaten import edildiği için burada tekrar import edilmesine gerek yok.
import '../modeller/profil_model.dart'; // ProfilModel veri yapısını tanımlar.

/// [ApiServisi] sınıfı, uygulamanın backend API'si ile iletişim kurmak için
/// gerekli metotları içerir. HTTP isteklerini yönetir, yanıtları işler ve
/// hata durumlarını kapsamlı bir şekilde ele alır.
class ApiServisi {
  /// Belirtilen endpoint'e ve parametrelere göre bir HTTP GET isteği yapar.
  /// Bu metot, tüm GET istekleri için temel işleyici olarak kullanılır.
  ///
  /// Parametreler:
  ///   [endpoint]: API'nin hedef yolunu belirtir (örn: "login.php").
  ///   [params]: İstekle birlikte gönderilecek sorgu parametrelerini içeren bir Map.
  ///
  /// Dönüş Değeri:
  ///   Başarılı olursa API'den dönen JSON verisini `Map<String, dynamic>` olarak döndürür.
  ///   Hata durumunda, hatanın türüne ve kaynağına göre özelleştirilmiş bir `Exception` fırlatır.
  Future<Map<String, dynamic>> _getIstegi(String endpoint, Map<String, String> params) async {
    // İstek için tam URI'nin oluşturulması. ApiSabitleri.kokUrl ile endpoint birleştirilir
    // ve varsa query parametreleri ('?' sonrası gelenler) eklenir.
    final uri = Uri.parse(ApiSabitleri.kokUrl + endpoint).replace(queryParameters: params);

    // Geliştirme ve hata ayıklama süreçlerini kolaylaştırmak için konsola detaylı loglama yapılır.
    print('----------------------------------------------------');
    print('[API İSTEĞİ BAŞLADI]');
    print('Endpoint: $endpoint');
    print('Parametreler: $params');
    print('Tam URI: $uri');
    print('----------------------------------------------------');

    try {
      // HTTP GET isteğinin yapılması ve sunucudan yanıt için maksimum 20 saniye beklenmesi.
      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      // Yanıt alındığında konsola detaylı loglama yapılır.
      print('----------------------------------------------------');
      print('[API YANITI ALINDI]');
      print('Yanıt Kodu: ${response.statusCode}');
      // Yanıt başlıkları genellikle çok uzun olabileceğinden, gerekmedikçe loglanmaz.
      // print('Yanıt Başlıkları: ${response.headers}');
      print('--- Yanıt Gövdesi Başlangıcı ---');
      print(response.body); // Sunucudan gelen ham yanıt gövdesi.
      print('--- Yanıt Gövdesi Sonu ---');
      print('----------------------------------------------------');

      // Yanıtın başarılı olup olmadığının HTTP durum koduna göre kontrolü (200 OK veya 201 Created).
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Yanıt gövdesinin JSON formatından Dart Map objesine dönüştürülmesi.
        final decodedJson = jsonDecode(response.body);
        // API yanıtının beklenen formatta (Map<String, dynamic>) olup olmadığının kontrolü.
        if (decodedJson is Map<String, dynamic>) {
          // API'nin kendi içindeki 'status' alanının kontrolü ('success' veya 'error').
          if (decodedJson['status'] == 'success') {
            print('[API İSTEĞİ BAŞARILI (status: success)]');
            return decodedJson; // Başarılı ise çözülmüş JSON verisi döndürülür.
          } else {
            // API'den 'status: error' durumu geldiyse, 'message' alanından hata mesajı ayıklanır.
            String apiHataMesaji = decodedJson['message'] ?? 'API Hatası: Durum başarılı değil ama mesaj da yok.';
            print('[API İSTEĞİ BAŞARISIZ (status: error)] Mesaj: $apiHataMesaji');
            throw Exception(apiHataMesaji); // Hata fırlatılır.
          }
        } else {
          // API'den beklenen formatta (Map) bir yanıt gelmediyse.
          print('[API HATASI] Yanıt formatı beklenmiyor (Map değil). Gelen tip: ${decodedJson.runtimeType}');
          throw Exception('API Hatası: Yanıt formatı beklenmiyor (Map değil)');
        }
      } else {
        // HTTP durum kodu başarısız ise (200 veya 201 değilse), hata mesajı oluşturulur.
        String hataMesaji = 'API Hatası: Sunucudan ${response.statusCode} kodu alındı.';
        try {
            // Hata yanıtının gövdesinden daha detaylı bir mesaj alınmaya çalışılır.
            final decodedJson = jsonDecode(response.body);
            if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('message')) {
              hataMesaji = 'API Hatası ${response.statusCode}: ${decodedJson['message']}';
            } else if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('error') && decodedJson['error'] is Map && decodedJson['error'].containsKey('message')) {
              // Bazı API'ler hatayı "error": {"message": "..."} gibi iç içe bir yapıda gönderebilir.
              hataMesaji = 'API Hatası ${response.statusCode}: ${decodedJson['error']['message']}';
            }
        } catch (e) {
            // Yanıt gövdesi JSON değilse veya parse edilemiyorsa bu durum loglanır.
            print('Yanıt gövdesi JSON olarak parse edilemedi (status ${response.statusCode}): $e');
            // Yanıt gövdesi çok uzun değilse, hata mesajına eklenerek daha fazla bilgi sağlanır.
            if (response.body.isNotEmpty && response.body.length < 200) {
              hataMesaji += ' Yanıt: ${response.body}';
            }
        }
        print('[API HATASI] $hataMesaji');
        throw Exception(hataMesaji); // Hata fırlatılır.
      }
    } on SocketException catch (e, s) {
      // Ağ bağlantısı sorunları (örn: internet yok, sunucuya ulaşılamıyor) yakalanır.
      print('****************************************************');
      print('[API İSTEĞİNDE SocketException OLUŞTU]');
      print('Hata Mesajı: $e');
      print('İstenen URI: $uri');
      print('Stack Trace (Yığın İzleme): $s');
      print('****************************************************');
      throw Exception('Sunucuya ulaşılamıyor. İnternet bağlantınızı veya sunucu adresini kontrol edin.');
    } on TimeoutException catch (e, s) {
      // Sunucudan belirtilen `timeout` süresi içinde yanıt alınamaması durumu yakalanır.
      print('****************************************************');
      print('[API İSTEĞİNDE TimeoutException OLUŞTU]');
      print('Hata Mesajı: $e');
      print('İstenen URI: $uri');
      print('Stack Trace: $s');
      print('****************************************************');
      throw Exception('Sunucudan yanıt alınamadı (zaman aşımı). Lütfen daha sonra tekrar deneyin.');
    } on FormatException catch (e, s) {
      // Sunucudan gelen yanıtın JSON formatında olmaması veya doğru şekilde parse edilememesi durumu.
      print('****************************************************');
      print('[API İSTEĞİNDE FormatException OLUŞTU (JSON Parse Edilemedi)]');
      print('Hata Mesajı: $e');
      print('İstenen URI: $uri');
      // 'response.body' bu scope'ta erişilebilir değil, yanıt gövdesi yukarıdaki try bloğunda zaten loglandı.
      print('Stack Trace: $s');
      print('****************************************************');
      throw Exception('Sunucudan gelen yanıt anlaşılamadı (hatalı format).');
    } catch (e, s) { // Yukarıdaki özel `Exception` türleri dışındaki tüm diğer hatalar bu blokta yakalanır.
      print('****************************************************');
      print('[API İSTEĞİNDE GENEL HATA OLUŞTU]');
      print('Hata Türü: ${e.runtimeType}');
      print('Hata Mesajı: $e');
      print('İstenen URI: $uri');
      print('Stack Trace: $s');
      print('****************************************************');
      // Eğer bu hata, bu sınıfın kendi fırlattığı, "API Hatası" ile başlayan bir Exception ise,
      // hata mesajını değiştirmeden aynen tekrar fırlatılır.
      if (e is Exception && e.toString().startsWith("Exception: API Hatası")) {
         throw e;
      }
      // Diğer tüm bilinmeyen ve beklenmedik hatalar için genel bir kullanıcı dostu mesaj fırlatılır.
      throw Exception('İşlem sırasında bilinmeyen bir sorun oluştu. Lütfen teknik destek ile iletişime geçin.');
    }
  }

  /// Kullanıcı girişi yapmak için API'ye istek gönderir.
  ///
  /// Parametreler:
  ///   [kullaniciAdi]: Kullanıcının girdiği kullanıcı adı.
  ///   [sifre]: Kullanıcının girdiği şifre.
  ///
  /// Dönüş Değeri:
  ///   Başarılı giriş durumunda `KullaniciModel` nesnesi döndürür.
  ///   Hata durumunda bir `Exception` fırlatır.
  Future<KullaniciModel> login(String kullaniciAdi, String sifre) async {
    final params = {'kullaniciadi': kullaniciAdi, 'sifre': sifre};
    final response = await _getIstegi(ApiSabitleri.login, params);
    // API yanıtında 'user' anahtarı var mı ve null değil mi kontrolü.
    if (response.containsKey('user') && response['user'] != null && response['user'] is Map<String,dynamic>) {
      // 'user' verisinden KullaniciModel oluşturulur.
      return KullaniciModel.fromJson(response['user']);
    } else {
      // Yanıtta kullanıcı bilgisi yoksa veya formatı hatalıysa.
      throw Exception('Kullanıcı bilgisi API yanıtında bulunamadı veya formatı hatalı.');
    }
  }

  /// Yeni kullanıcı kaydı yapmak için API'ye istek gönderir.
  ///
  /// Parametreler:
  ///   [ad], [soyad], [kullaniciAdi], [email], [sifre]: Kullanıcının kayıt formunda girdiği bilgiler.
  ///
  /// Dönüş Değeri:
  ///   Başarılı kayıt durumunda API'den dönen mesajı (`String`) döndürür.
  ///   Hata durumunda bir `Exception` fırlatır.
  Future<String> register(String ad, String soyad, String kullaniciAdi, String email, String sifre) async {
    final params = {
      'ad': ad,
      'soyad': soyad,
      'kullaniciadi': kullaniciAdi,
      'email': email,
      'sifre': sifre,
    };
    final response = await _getIstegi(ApiSabitleri.register, params);
    // API yanıtından 'message' anahtarıyla gelen mesajı döndürür.
    // Eğer 'message' null ise varsayılan bir mesaj kullanılır.
    return response['message'] as String? ?? 'Kayıt başarılı ancak API mesajı alınamadı.';
  }

  /// Tüm eğitimleri listelemek için API'ye istek gönderir.
  ///
  /// Dönüş Değeri:
  ///   Eğitimlerin listesini (`List<EgitimModel>`) döndürür.
  ///   Hata durumunda veya veri formatı yanlışsa bir `Exception` fırlatır.
  Future<List<EgitimModel>> getEgitimler() async {
    // Bu endpoint için parametreye gerek yok, boş bir Map gönderiliyor.
    final response = await _getIstegi(ApiSabitleri.getEgitimler, {});
    // Yanıtta 'data' anahtarı var mı ve bu bir liste mi kontrolü.
    if (response.containsKey('data') && response['data'] is List) {
      final List<dynamic> egitimlerJson = response['data'];
      // JSON listesindeki her bir öğe EgitimModel'e dönüştürülür.
      return egitimlerJson.map((json) => EgitimModel.fromJson(json)).toList();
    } else {
      // Yanıtta eğitim verisi yoksa veya formatı hatalıysa.
      throw Exception('Eğitim verisi API yanıtında bulunamadı veya formatı yanlış.');
    }
  }

  /// Belirli bir eğitimin detaylarını almak için API'ye istek gönderir.
  ///
  /// Parametreler:
  ///   [egitimId]: Detayları istenen eğitimin ID'si.
  ///
  /// Dönüş Değeri:
  ///   Eğitim detaylarını içeren `EgitimDetayModel` nesnesini döndürür.
  ///   Hata durumunda veya veri formatı yanlışsa bir `Exception` fırlatır.
  Future<EgitimDetayModel> getEgitimDetay(int egitimId) async {
    final params = {'egitim_id': egitimId.toString()}; // ID'yi string'e çevirerek gönder.
    final response = await _getIstegi(ApiSabitleri.getEgitimDetay, params);
    // Yanıtta 'data' anahtarı var mı ve bu bir Map mi kontrolü.
    if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
      // 'data' verisinden EgitimDetayModel oluşturulur.
      return EgitimDetayModel.fromJson(response['data']);
    } else {
      // Yanıtta eğitim detay verisi yoksa veya formatı hatalıysa.
      throw Exception('Eğitim detay verisi API yanıtında bulunamadı veya formatı yanlış.');
    }
  }

  /// Belirli bir testin sorularını almak için API'ye istek gönderir.
  ///
  /// Parametreler:
  ///   [testId]: Soruları istenen testin ID'si.
  ///
  /// Dönüş Değeri:
  ///   Test sorularını ve test adını içeren `TestSorularModel` nesnesini döndürür.
  Future<TestSorularModel> getTestSorular(int testId) async {
    final params = {'test_id': testId.toString()};
    final response = await _getIstegi(ApiSabitleri.getTestSorular, params);
    // Gelen yanıtın tamamı TestSorularModel.fromJson'a gönderilir.
    // Modelin kendisi içindeki 'data' ve 'test_adi' gibi alanları parse eder.
    return TestSorularModel.fromJson(response);
  }

  /// Kullanıcının bir testteki cevaplarını ve sonucunu API'ye gönderir.
  ///
  /// Parametreler:
  ///   [kullaniciId]: Testi çözen kullanıcının ID'si.
  ///   [testId]: Çözülen testin ID'si.
  ///   [dogruSayisi]: Kullanıcının testteki doğru cevap sayısı.
  ///   [yanlisSayisi]: Kullanıcının testteki yanlış cevap sayısı.
  ///
  /// Dönüş Değeri:
  ///   API'den dönen puanı ve kazanılan rozetlerin detaylı listesini içeren bir Map döndürür.
  Future<Map<String, dynamic>> submitTestSonuc(int kullaniciId, int testId, int dogruSayisi, int yanlisSayisi) async {
    final params = {
      'kullanici_id': kullaniciId.toString(),
      'test_id': testId.toString(),
      'dogru_sayisi': dogruSayisi.toString(),
      'yanlis_sayisi': yanlisSayisi.toString(),
    };
    final response = await _getIstegi(ApiSabitleri.submitTestSonuc, params);
    // API yanıtından 'puan' ve 'kazanilan_rozetler_detayli' alanları ayıklanır.
    // 'kazanilan_rozetler_detayli' null ise boş bir liste atanır.
    return {
      'puan': response['puan']?.toString(), // Puan string'e çevrilir.
      'kazanilan_rozetler_detayli': response['kazanilan_rozetler_detayli'] as List<dynamic>? ?? []
    };
  }

  /// Belirli bir kullanıcının profil bilgilerini (kullanıcı detayları ve kazanılan rozetler) almak için API'ye istek gönderir.
  ///
  /// Parametreler:
  ///   [kullaniciId]: Profili istenen kullanıcının ID'si.
  ///
  /// Dönüş Değeri:
  ///   Kullanıcı profil bilgilerini içeren `ProfilModel` nesnesini döndürür.
  Future<ProfilModel> getKullaniciProfil(int kullaniciId) async {
    final params = {'kullanici_id': kullaniciId.toString()};
    final response = await _getIstegi(ApiSabitleri.getKullaniciProfil, params);
    // Gelen yanıtın tamamı ProfilModel.fromJson'a gönderilir.
    return ProfilModel.fromJson(response);
  }
}
