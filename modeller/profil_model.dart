// Kullanıcı ve rozet modellerini import eder, çünkü ProfilModel bu ikisini içerir.
import 'kullanici_model.dart';
import 'rozet_model.dart';

/// [ProfilModel], bir kullanıcının profil sayfasında gösterilecek tüm bilgileri bir arada tutar.
/// Bu, kullanıcının temel bilgilerini ([KullaniciModel]) ve kazandığı rozetlerin listesini ([RozetModel]) içerir.
class ProfilModel {
  final KullaniciModel kullaniciBilgileri; // Kullanıcının adı, soyadı, e-postası gibi detayları.
  final List<RozetModel> kazanilanRozetler; // Kullanıcının tamamladığı testler veya başarımlar sonucu kazandığı rozetler.

  /// [ProfilModel] için constructor.
  ProfilModel({
    required this.kullaniciBilgileri,
    required this.kazanilanRozetler,
  });

  /// JSON formatındaki bir Map'ten [ProfilModel] nesnesi oluşturur.
  /// API'den (genellikle `get_kullanici_profil.php` endpoint'inden) gelen veriyi parse etmek için kullanılır.
  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    // 'kazanilan_rozetler' alanı bir JSON listesi olarak beklenir.
    var rozetlerListesi = json['kazanilan_rozetler'] as List?;
    List<RozetModel> rozetler = rozetlerListesi != null
        // Eğer rozetler listesi varsa, her bir JSON öğesini RozetModel.fromProfil ile parse eder.
        // `fromProfil` metodu, profil API'sinden gelen rozet formatına özeldir.
        ? rozetlerListesi.map((i) => RozetModel.fromProfil(i)).toList()
        // Rozetler listesi null ise boş bir liste atanır.
        : [];

    return ProfilModel(
      // 'kullanici_bilgileri' alanı bir JSON nesnesi (Map) olarak beklenir ve KullaniciModel.fromJson ile parse edilir.
      kullaniciBilgileri: KullaniciModel.fromJson(json['kullanici_bilgileri']),
      kazanilanRozetler: rozetler, // Parse edilmiş rozetler listesi.
    );
  }
}
