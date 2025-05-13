import 'dart:convert';
import 'dart:async'; // TimeoutException için eklendi
import 'dart:io'; // SocketException için eklendi
import 'package:http/http.dart' as http;
import '../sabitler/api_sabitleri.dart';
import '../modeller/kullanici_model.dart';
import '../modeller/egitim_model.dart';
import '../modeller/egitim_detay_model.dart';
import '../modeller/soru_model.dart';
// import '../modeller/rozet_model.dart'; // ProfilModel içinde zaten var
import '../modeller/profil_model.dart';

class ApiServisi {
  Future<Map<String, dynamic>> _getIstegi(String endpoint, Map<String, String> params) async {
    final uri = Uri.parse(ApiSabitleri.kokUrl + endpoint).replace(queryParameters: params);
    print('----------------------------------------------------');
    print('[API İSTEĞİ BAŞLADI]');
    print('Endpoint: $endpoint');
    print('Parametreler: $params');
    print('Tam URI: $uri');
    print('----------------------------------------------------');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      print('----------------------------------------------------');
      print('[API YANITI ALINDI]');
      print('Yanıt Kodu: ${response.statusCode}');
      // print('Yanıt Başlıkları: ${response.headers}'); // Gerekirse açılabilir, çok uzun olabilir
      print('--- Yanıt Gövdesi Başlangıcı ---');
      print(response.body);
      print('--- Yanıt Gövdesi Sonu ---');
      print('----------------------------------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);
        if (decodedJson is Map<String, dynamic>) {
          if (decodedJson['status'] == 'success') {
            print('[API İSTEĞİ BAŞARILI (status: success)]');
            return decodedJson;
          } else {
            String apiHataMesaji = decodedJson['message'] ?? 'API Hatası: Durum başarılı değil';
            print('[API İSTEĞİ BAŞARISIZ (status: error)] Mesaj: $apiHataMesaji');
            throw Exception(apiHataMesaji);
          }
        } else {
          print('[API HATASI] Yanıt formatı beklenmiyor (Map değil). Gelen tip: ${decodedJson.runtimeType}');
          throw Exception('API Hatası: Yanıt formatı beklenmiyor (Map değil)');
        }
      } else {
        String hataMesaji = 'API Hatası: Sunucudan ${response.statusCode} kodu alındı.';
        try {
            final decodedJson = jsonDecode(response.body);
            if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('message')) {
              hataMesaji = 'API Hatası ${response.statusCode}: ${decodedJson['message']}';
            } else if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('error') && decodedJson['error'] is Map && decodedJson['error'].containsKey('message')) {
              // Bazen hata mesajı "error": {"message": "..."} formatında gelebilir
              hataMesaji = 'API Hatası ${response.statusCode}: ${decodedJson['error']['message']}';
            }
        } catch (e) {
            print('Yanıt gövdesi JSON olarak parse edilemedi (status ${response.statusCode}): $e');
            // response.body'yi doğrudan hata mesajına ekleyebiliriz, eğer çok uzun değilse
            if (response.body.isNotEmpty && response.body.length < 200) { // Çok uzunsa logları boğmasın
              hataMesaji += ' Yanıt: ${response.body}';
            }
        }
        print('[API HATASI] $hataMesaji');
        throw Exception(hataMesaji);
      }
    } on SocketException catch (e, s) {
      print('****************************************************');
      print('[API İSTEĞİNDE SocketException OLUŞTU]');
      print('Hata Mesajı: $e');
      print('İstenen URI: $uri');
      print('Stack Trace: $s');
      print('****************************************************');
      throw Exception('Sunucuya ulaşılamıyor. İnternet bağlantınızı veya sunucu adresini kontrol edin.');
    } on TimeoutException catch (e, s) {
      print('****************************************************');
      print('[API İSTEĞİNDE TimeoutException OLUŞTU]');
      print('Hata Mesajı: $e');
      print('İstenen URI: $uri');
      print('Stack Trace: $s');
      print('****************************************************');
      throw Exception('Sunucudan yanıt alınamadı (zaman aşımı). Lütfen daha sonra tekrar deneyin.');
    } on FormatException catch (e, s) {
      print('****************************************************');
      print('[API İSTEĞİNDE FormatException OLUŞTU (JSON Parse Edilemedi)]');
      print('Hata Mesajı: $e');
      print('İstenen URI: $uri');
      // Yanıt gövdesini loglamak burada çok önemli
      // print('Alınan Ham Yanıt (parse edilemeyen): ${response.body}'); // response burada scope dışında, yukarıda loglandı.
      print('Stack Trace: $s');
      print('****************************************************');
      throw Exception('Sunucudan gelen yanıt anlaşılamadı (hatalı format).');
    } catch (e, s) { // Diğer tüm hatalar
      print('****************************************************');
      print('[API İSTEĞİNDE GENEL HATA OLUŞTU]');
      print('Hata Türü: ${e.runtimeType}');
      print('Hata Mesajı: $e');
      print('İstenen URI: $uri');
      print('Stack Trace: $s');
      print('****************************************************');
      if (e is Exception && e.toString().startsWith("Exception: API Hatası")) {
         throw e; // Kendi fırlattığımız Exception'ı tekrar fırlat
      }
      throw Exception('İşlem sırasında bilinmeyen bir sorun oluştu.');
    }
  }

  Future<KullaniciModel> login(String kullaniciAdi, String sifre) async {
    final params = {'kullaniciadi': kullaniciAdi, 'sifre': sifre};
    final response = await _getIstegi(ApiSabitleri.login, params);
    if (response.containsKey('user') && response['user'] != null && response['user'] is Map<String,dynamic>) {
      return KullaniciModel.fromJson(response['user']);
    } else {
      throw Exception('Kullanıcı bilgisi API yanıtında bulunamadı veya formatı hatalı.');
    }
  }

  Future<String> register(String ad, String soyad, String kullaniciAdi, String email, String sifre) async {
    final params = {
      'ad': ad,
      'soyad': soyad,
      'kullaniciadi': kullaniciAdi,
      'email': email,
      'sifre': sifre,
    };
    final response = await _getIstegi(ApiSabitleri.register, params);
    return response['message'] as String? ?? 'Kayıt başarılı mesajı alınamadı.';
  }

  Future<List<EgitimModel>> getEgitimler() async {
    final response = await _getIstegi(ApiSabitleri.getEgitimler, {});
    if (response.containsKey('data') && response['data'] is List) {
      final List<dynamic> egitimlerJson = response['data'];
      return egitimlerJson.map((json) => EgitimModel.fromJson(json)).toList();
    } else {
      throw Exception('Eğitim verisi API yanıtında bulunamadı veya formatı yanlış.');
    }
  }

  Future<EgitimDetayModel> getEgitimDetay(int egitimId) async {
    final params = {'egitim_id': egitimId.toString()};
    final response = await _getIstegi(ApiSabitleri.getEgitimDetay, params);
    if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
      return EgitimDetayModel.fromJson(response['data']);
    } else {
      throw Exception('Eğitim detay verisi API yanıtında bulunamadı veya formatı yanlış.');
    }
  }

  Future<TestSorularModel> getTestSorular(int testId) async {
    final params = {'test_id': testId.toString()};
    final response = await _getIstegi(ApiSabitleri.getTestSorular, params);
    return TestSorularModel.fromJson(response);
  }

  Future<Map<String, dynamic>> submitTestSonuc(int kullaniciId, int testId, int dogruSayisi, int yanlisSayisi) async {
    final params = {
      'kullanici_id': kullaniciId.toString(),
      'test_id': testId.toString(),
      'dogru_sayisi': dogruSayisi.toString(),
      'yanlis_sayisi': yanlisSayisi.toString(),
    };
    final response = await _getIstegi(ApiSabitleri.submitTestSonuc, params);
    return {
      'puan': response['puan']?.toString(),
      'kazanilan_rozetler_detayli': response['kazanilan_rozetler_detayli'] as List<dynamic>? ?? []
    };
  }

  Future<ProfilModel> getKullaniciProfil(int kullaniciId) async {
    final params = {'kullanici_id': kullaniciId.toString()};
    final response = await _getIstegi(ApiSabitleri.getKullaniciProfil, params);
    return ProfilModel.fromJson(response);
  }
}