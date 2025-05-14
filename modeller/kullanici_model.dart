/// [KullaniciModel], bir kullanıcıyı temsil eden veri yapısıdır.
/// Kullanıcının ID'si, adı, soyadı, kullanıcı adı ve e-posta adresi gibi temel bilgilerini içerir.
class KullaniciModel {
  final int id; // Kullanıcının benzersiz ID'si.
  final String ad; // Kullanıcının adı.
  final String soyad; // Kullanıcının soyadı.
  final String kullaniciAdi; // Kullanıcının sistemdeki benzersiz kullanıcı adı.
  final String email; // Kullanıcının e-posta adresi.

  // Not: API'den `kayit_tarihi` gibi ek bilgiler geliyorsa, bunlar modele eklenebilir.
  // Mevcut model, genellikle login işlemi sonrası dönen yanıta göre şekillendirilmiştir.

  /// [KullaniciModel] için constructor.
  KullaniciModel({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.kullaniciAdi,
    required this.email,
  });

  /// JSON formatındaki bir Map'ten [KullaniciModel] nesnesi oluşturur.
  /// API'den gelen veriyi parse etmek için kullanılır.
  factory KullaniciModel.fromJson(Map<String, dynamic> json) {
    return KullaniciModel(
      // 'id' alanı integer olarak beklenir.
      id: json['id'] as int,
      // 'ad' alanı string olarak beklenir.
      ad: json['ad'] as String,
      // 'soyad' alanı string olarak beklenir.
      soyad: json['soyad'] as String,
      // 'kullaniciadi' alanı (API'deki anahtar) string olarak beklenir.
      kullaniciAdi: json['kullaniciadi'] as String,
      // 'email' alanı string olarak beklenir.
      email: json['email'] as String,
    );
  }

  /// [KullaniciModel] nesnesini JSON formatında bir Map'e dönüştürür.
  /// Örneğin, SharedPreferences'a kaydetmek veya bir API isteğinde göndermek için kullanılabilir.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'soyad': soyad,
      'kullaniciadi': kullaniciAdi, // API'deki anahtarla uyumlu.
      'email': email,
    };
  }
}
