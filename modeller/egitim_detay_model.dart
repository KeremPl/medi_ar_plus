/// [EgitimAdimModel], bir eğitimin tek bir adımını temsil eder.
/// Her adım bir sıra numarası, isteğe bağlı bir fotoğraf ve bir açıklama içerebilir.
class EgitimAdimModel {
  final int adimSira; // Adımın eğitim içindeki sıra numarası (örn: 1, 2, 3...).
  final String? adimFotograf; // Adımla ilgili görselin API'den gelen göreli dosya yolu (örn: "/images/adimlar/yanik_adim1.svg"). Null olabilir.
  final String? adimAciklama; // Adımın metinsel açıklaması. Null olabilir.

  /// [EgitimAdimModel] için constructor.
  EgitimAdimModel({
    required this.adimSira,
    this.adimFotograf,
    this.adimAciklama,
  });

  /// JSON formatındaki bir Map'ten [EgitimAdimModel] nesnesi oluşturur.
  /// API'den gelen veriyi parse etmek için kullanılır.
  factory EgitimAdimModel.fromJson(Map<String, dynamic> json) {
    return EgitimAdimModel(
      // 'adim_sira' alanı integer olarak beklenir.
      adimSira: json['adim_sira'] as int,
      // 'adim_fotograf' alanı string olarak beklenir, null olabilir.
      adimFotograf: json['adim_fotograf'] as String?,
      // 'adim_aciklama' alanı string olarak beklenir, null olabilir.
      adimAciklama: json['adim_aciklama'] as String?,
    );
  }
}

/// [EgitimDetayModel], bir eğitimin tüm detaylarını ve adımlarını içerir.
/// Eğitimin ID'si, adı, kapak resmi (vektörel) ve eğitim adımlarının listesini barındırır.
class EgitimDetayModel {
  final int egitimId; // Eğitimin benzersiz ID'si.
  final String egitimAdi; // Eğitimin adı.
  final String? egitimKapakVector; // Eğitimin kapak görselinin (muhtemelen SVG) API'den gelen göreli dosya yolu. Null olabilir.
  final List<EgitimAdimModel> adimlar; // Eğitimin adımlarını içeren liste.

  /// [EgitimDetayModel] için constructor.
  EgitimDetayModel({
    required this.egitimId,
    required this.egitimAdi,
    this.egitimKapakVector,
    required this.adimlar,
  });

  /// JSON formatındaki bir Map'ten [EgitimDetayModel] nesnesi oluşturur.
  /// API'den gelen veriyi parse etmek için kullanılır.
  factory EgitimDetayModel.fromJson(Map<String, dynamic> json) {
    // 'adimlar' alanı bir JSON listesi olarak beklenir.
    var adimlarListesi = json['adimlar'] as List?;
    List<EgitimAdimModel> adimlar = adimlarListesi != null
        // Eğer adımlar listesi varsa, her bir JSON öğesini EgitimAdimModel.fromJson ile parse eder.
        ? adimlarListesi.map((i) => EgitimAdimModel.fromJson(i)).toList()
        // Adımlar listesi null ise boş bir liste atanır.
        : [];

    return EgitimDetayModel(
      // 'egitimid' alanı integer olarak beklenir. API'de 'egitimId' yerine 'egitimid' kullanılmış olabilir.
      egitimId: json['egitimid'] as int,
      // 'egitimadi' alanı string olarak beklenir.
      egitimAdi: json['egitimadi'] as String,
      // 'egitim_kapak_vector' alanı string olarak beklenir, null olabilir.
      egitimKapakVector: json['egitim_kapak_vector'] as String?,
      adimlar: adimlar, // Parse edilmiş adımlar listesi.
    );
  }
}
