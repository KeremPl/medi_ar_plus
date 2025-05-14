/// [RozetModel], bir başarı rozetini temsil eder.
/// Rozetin ID'si (isteğe bağlı), adı, ikonunun adı, açıklaması (isteğe bağlı)
/// ve kazanılma tarihi (isteğe bağlı) gibi bilgileri içerir.
class RozetModel {
  final int? rozetId; // Rozetin benzersiz ID'si. Profil API'sinden gelebilir, test sonucundan gelmeyebilir. Null olabilir.
  final String rozetAdi; // Rozetin adı (örn: "İlk Yardım Uzmanı", "Hızlı Tepki").
  final String? rozetIconAdi; // Rozetin ikonunun sistemdeki adı (örn: "star", "verified"). Null olabilir.
  final String? rozetAciklama; // Rozetin ne anlama geldiğini veya nasıl kazanıldığını açıklayan metin. Null olabilir.
                               // Alan adı `rozetAciklama` olarak düzeltilmiştir (önceki versiyonda farklı olabilirdi).
  final String? kazanmaTarihi; // Rozetin kazanıldığı tarih (örn: "YYYY-MM-DD HH:MM:SS" formatında). Null olabilir.

  /// [RozetModel] için constructor.
  RozetModel({
    this.rozetId,
    required this.rozetAdi,
    this.rozetIconAdi,
    this.rozetAciklama,
    this.kazanmaTarihi,
  });

  /// Test sonucu API'sinden (`submit_test_sonuc.php`) gelen JSON formatındaki bir Map'ten
  /// [RozetModel] nesnesi oluşturur. Bu fabrika metodu, test sonucu API'sinin
  /// döndürdüğü rozet yapısına özeldir (genellikle daha az detay içerir).
  factory RozetModel.fromTestSonuc(Map<String, dynamic> json) {
    return RozetModel(
      // Test sonucu API'sinden `rozetId`, `rozetAciklama`, `kazanmaTarihi` genellikle gelmez.
      rozetAdi: json['rozetadi'] as String, // 'rozetadi' alanı string olarak beklenir.
      rozetIconAdi: json['rozet_icon_adi'] as String?, // 'rozet_icon_adi' alanı string olarak beklenir, null olabilir.
    );
  }

  /// Kullanıcı profili API'sinden (`get_kullanici_profil.php`) gelen JSON formatındaki bir Map'ten
  /// [RozetModel] nesnesi oluşturur. Bu fabrika metodu, profil API'sinin
  /// döndürdüğü rozet yapısına özeldir (genellikle daha fazla detay içerir).
  factory RozetModel.fromProfil(Map<String, dynamic> json) {
    return RozetModel(
      rozetId: json['rozetid'] as int?, // 'rozetid' alanı integer olarak beklenir, null olabilir.
      rozetAdi: json['rozetadi'] as String, // 'rozetadi' alanı string olarak beklenir.
      rozetIconAdi: json['rozet_icon_adi'] as String?, // 'rozet_icon_adi' alanı string olarak beklenir, null olabilir.
      // 'rozetaciklama' alanı (API'den gelen) string olarak beklenir, null olabilir.
      rozetAciklama: json['rozetaciklama'] as String?,
      // 'kazanma_tarihi' alanı string olarak beklenir, null olabilir.
      kazanmaTarihi: json['kazanma_tarihi'] as String?,
    );
  }
}
