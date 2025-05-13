class CevapModel {
  final int cevapId;
  final String cevapMetni;
  final bool dogruMu;

  CevapModel({
    required this.cevapId,
    required this.cevapMetni,
    required this.dogruMu,
  });

  factory CevapModel.fromJson(Map<String, dynamic> json) {
    return CevapModel(
      cevapId: json['cevapid'] as int,
      cevapMetni: json['cevap_metni'] as String,
      dogruMu: (json['dogru_mu'] == true || json['dogru_mu'] == 1), // API'den bool veya int gelebilir
    );
  }
}

class SoruModel {
  final int soruId;
  final String soru;
  final List<CevapModel> cevaplar;

  SoruModel({
    required this.soruId,
    required this.soru,
    required this.cevaplar,
  });

  factory SoruModel.fromJson(Map<String, dynamic> json) {
    var cevaplarListesi = json['cevaplar'] as List?;
    List<CevapModel> cevaplar = cevaplarListesi != null
        ? cevaplarListesi.map((i) => CevapModel.fromJson(i)).toList()
        : [];

    return SoruModel(
      soruId: json['soruid'] as int,
      soru: json['soru'] as String,
      cevaplar: cevaplar,
    );
  }
}

class TestSorularModel {
  final String testAdi;
  final List<SoruModel> sorular;

  TestSorularModel({required this.testAdi, required this.sorular});

  factory TestSorularModel.fromJson(Map<String, dynamic> json) {
    var sorularListesi = json['data'] as List?; // API yanıtında sorular 'data' altında
    List<SoruModel> sorular = sorularListesi != null
        ? sorularListesi.map((i) => SoruModel.fromJson(i)).toList()
        : [];

    return TestSorularModel(
      testAdi: json['test_adi'] as String,
      sorular: sorular,
    );
  }
}
