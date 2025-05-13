class EgitimAdimModel {
  final int adimSira;
  final String? adimFotograf; // API'den gelen `/images/...` yolu
  final String? adimAciklama;

  EgitimAdimModel({
    required this.adimSira,
    this.adimFotograf,
    this.adimAciklama,
  });

  factory EgitimAdimModel.fromJson(Map<String, dynamic> json) {
    return EgitimAdimModel(
      adimSira: json['adim_sira'] as int,
      adimFotograf: json['adim_fotograf'] as String?,
      adimAciklama: json['adim_aciklama'] as String?,
    );
  }
}

class EgitimDetayModel {
  final int egitimId;
  final String egitimAdi;
  final String? egitimKapakVector;
  final List<EgitimAdimModel> adimlar;

  EgitimDetayModel({
    required this.egitimId,
    required this.egitimAdi,
    this.egitimKapakVector,
    required this.adimlar,
  });

  factory EgitimDetayModel.fromJson(Map<String, dynamic> json) {
    var adimlarListesi = json['adimlar'] as List?;
    List<EgitimAdimModel> adimlar = adimlarListesi != null
        ? adimlarListesi.map((i) => EgitimAdimModel.fromJson(i)).toList()
        : [];

    return EgitimDetayModel(
      egitimId: json['egitimid'] as int,
      egitimAdi: json['egitimadi'] as String,
      egitimKapakVector: json['egitim_kapak_vector'] as String?,
      adimlar: adimlar,
    );
  }
}
