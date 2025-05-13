class EgitimModel {
  final int egitimId;
  final String egitimAdi;
  final String? egitimKapakVector;
  final int testId;
  final String? testIconAdi;

  EgitimModel({
    required this.egitimId,
    required this.egitimAdi,
    this.egitimKapakVector,
    required this.testId,
    this.testIconAdi,
  });

  factory EgitimModel.fromJson(Map<String, dynamic> json) {
    return EgitimModel(
      // API'den gelen değerlerin string olabileceği varsayımıyla güvenli parse etme
      egitimId: int.tryParse(json['egitimid'].toString()) ?? 0,
      egitimAdi: json['egitimadi'] as String,
      egitimKapakVector: json['egitim_kapak_vector'] as String?,
      testId: int.tryParse(json['testid'].toString()) ?? 0,
      testIconAdi: json['test_icon_adi'] as String?,
    );
  }
}
