class EgitimModel {
  final int egitimId;
  final String egitimAdi;
  final String? egitimKapakVector;
  final int testId; // API'den int geldiği teyit edildi, String parse'a gerek kalmadı
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
      egitimId: int.tryParse(json['egitimid'].toString()) ?? 0,
      egitimAdi: json['egitimadi'] as String,
      egitimKapakVector: json['egitim_kapak_vector'] as String?,
      // testid API yanıtında int olarak geliyor, doğrudan cast edilebilir.
      // Ama emin olmak için tryParse yine de iyi bir önlem olabilir.
      testId: json['testid'] is int ? json['testid'] as int : int.tryParse(json['testid'].toString()) ?? 0,
      testIconAdi: json['test_icon_adi'] as String?,
    );
  }
}
