/// [CevapModel], bir test sorusunun tek bir cevap seçeneğini temsil eder.
/// Cevabın ID'si, metni ve doğru olup olmadığı bilgisini içerir.
class CevapModel {
  final int cevapId; // Cevap seçeneğinin benzersiz ID'si.
  final String cevapMetni; // Cevap seçeneğinin kullanıcıya gösterilecek metni.
  final bool dogruMu; // Bu cevap seçeneğinin doğru cevap olup olmadığını belirtir (true/false).

  /// [CevapModel] için constructor.
  CevapModel({
    required this.cevapId,
    required this.cevapMetni,
    required this.dogruMu,
  });

  /// JSON formatındaki bir Map'ten [CevapModel] nesnesi oluşturur.
  /// API'den gelen veriyi parse etmek için kullanılır.
  factory CevapModel.fromJson(Map<String, dynamic> json) {
    return CevapModel(
      // 'cevapid' alanı integer olarak beklenir.
      cevapId: json['cevapid'] as int,
      // 'cevap_metni' alanı string olarak beklenir.
      cevapMetni: json['cevap_metni'] as String,
      // 'dogru_mu' alanı API'den boolean (true/false) veya integer (1/0) olarak gelebilir.
      // Bu yüzden her iki durumu da kontrol ederek boolean'a çevirir.
      dogruMu: (json['dogru_mu'] == true || json['dogru_mu'] == 1),
    );
  }
}

/// [SoruModel], bir testteki tek bir soruyu temsil eder.
/// Sorunun ID'si, metni ve cevap seçeneklerinin listesini içerir.
class SoruModel {
  final int soruId; // Sorunun benzersiz ID'si.
  final String soru; // Sorunun kullanıcıya gösterilecek metni.
  final List<CevapModel> cevaplar; // Soruya ait cevap seçeneklerini içeren liste.

  /// [SoruModel] için constructor.
  SoruModel({
    required this.soruId,
    required this.soru,
    required this.cevaplar,
  });

  /// JSON formatındaki bir Map'ten [SoruModel] nesnesi oluşturur.
  /// API'den gelen veriyi parse etmek için kullanılır.
  factory SoruModel.fromJson(Map<String, dynamic> json) {
    // 'cevaplar' alanı bir JSON listesi olarak beklenir.
    var cevaplarListesi = json['cevaplar'] as List?;
    List<CevapModel> cevaplar = cevaplarListesi != null
        // Eğer cevaplar listesi varsa, her bir JSON öğesini CevapModel.fromJson ile parse eder.
        ? cevaplarListesi.map((i) => CevapModel.fromJson(i)).toList()
        // Cevaplar listesi null ise boş bir liste atanır.
        : [];

    return SoruModel(
      // 'soruid' alanı integer olarak beklenir.
      soruId: json['soruid'] as int,
      // 'soru' alanı string olarak beklenir.
      soru: json['soru'] as String,
      cevaplar: cevaplar, // Parse edilmiş cevaplar listesi.
    );
  }
}

/// [TestSorularModel], bir testin adını ve o teste ait tüm soruları bir arada tutar.
/// API'den (`get_test_sorular.php`) gelen yanıtın genel yapısını temsil eder.
class TestSorularModel {
  final String testAdi; // Testin adı.
  final List<SoruModel> sorular; // Teste ait soruları içeren liste.

  /// [TestSorularModel] için constructor.
  TestSorularModel({required this.testAdi, required this.sorular});

  /// JSON formatındaki bir Map'ten [TestSorularModel] nesnesi oluşturur.
  /// API'den gelen veriyi parse etmek için kullanılır.
  factory TestSorularModel.fromJson(Map<String, dynamic> json) {
    // API yanıtında soruların 'data' anahtarı altında bir liste olarak geldiği varsayılır.
    var sorularListesi = json['data'] as List?;
    List<SoruModel> sorular = sorularListesi != null
        // Eğer sorular listesi varsa, her bir JSON öğesini SoruModel.fromJson ile parse eder.
        ? sorularListesi.map((i) => SoruModel.fromJson(i)).toList()
        // Sorular listesi null ise boş bir liste atanır.
        : [];

    return TestSorularModel(
      // 'test_adi' alanı string olarak beklenir.
      testAdi: json['test_adi'] as String,
      sorular: sorular, // Parse edilmiş sorular listesi.
    );
  }
}
