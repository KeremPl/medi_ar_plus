/// [EgitimModel], eğitim listelerinde gösterilecek bir eğitimin temel bilgilerini temsil eder.
/// Eğitimin ID'si, adı, kapak resmi, ilişkili testin ID'si ve test ikonunun adını içerir.
class EgitimModel {
  final int egitimId; // Eğitimin benzersiz ID'si.
  final String egitimAdi; // Eğitimin adı.
  final String? egitimKapakVector; // Eğitimin kapak görselinin (muhtemelen SVG) API'den gelen göreli dosya yolu. Null olabilir.
  final int testId; // Bu eğitimle ilişkili testin ID'si. Eğer eğitimle ilişkili test yoksa 0 olabilir.
                    // API'den integer geldiği teyit edildiği için String parse işlemine gerek kalmamış.
  final String? testIconAdi; // İlişkili testin ikonunun adı (örn: "quiz", "assignment"). Null olabilir.

  /// [EgitimModel] için constructor.
  EgitimModel({
    required this.egitimId,
    required this.egitimAdi,
    this.egitimKapakVector,
    required this.testId,
    this.testIconAdi,
  });

  /// JSON formatındaki bir Map'ten [EgitimModel] nesnesi oluşturur.
  /// API'den gelen veriyi parse etmek için kullanılır.
  factory EgitimModel.fromJson(Map<String, dynamic> json) {
    return EgitimModel(
      // 'egitimid' alanı API'den string veya integer gelebilir, bu yüzden `toString()` ve `int.tryParse` ile güvenli parse edilir.
      // Eğer parse edilemezse veya null ise varsayılan olarak 0 atanır.
      egitimId: int.tryParse(json['egitimid'].toString()) ?? 0,
      // 'egitimadi' alanı string olarak beklenir.
      egitimAdi: json['egitimadi'] as String,
      // 'egitim_kapak_vector' alanı string olarak beklenir, null olabilir.
      egitimKapakVector: json['egitim_kapak_vector'] as String?,
      // 'testid' alanı API yanıtında integer olarak geliyorsa doğrudan cast edilebilir.
      // Ancak, farklı veri tiplerine karşı daha robust olması için `is int` kontrolü ve
      // `int.tryParse` ile yedekli bir parse işlemi yapılmıştır.
      // Eğer parse edilemezse veya null ise varsayılan olarak 0 atanır.
      testId: json['testid'] is int
          ? json['testid'] as int
          : int.tryParse(json['testid'].toString()) ?? 0,
      // 'test_icon_adi' alanı string olarak beklenir, null olabilir.
      testIconAdi: json['test_icon_adi'] as String?,
    );
  }
}
