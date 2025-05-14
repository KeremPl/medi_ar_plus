class RozetModel {
  final int? rozetId;
  final String rozetAdi;
  final String? rozetIconAdi;
  final String? rozetAciklama; // Düzeltildi: rozetAciklama
  final String? kazanmaTarihi;

  RozetModel({
    this.rozetId,
    required this.rozetAdi,
    this.rozetIconAdi,
    this.rozetAciklama, // Düzeltildi: rozetAciklama
    this.kazanmaTarihi,
  });

  factory RozetModel.fromTestSonuc(Map<String, dynamic> json) {
    return RozetModel(
      rozetAdi: json['rozetadi'] as String,
      rozetIconAdi: json['rozet_icon_adi'] as String?,
    );
  }

  factory RozetModel.fromProfil(Map<String, dynamic> json) {
    return RozetModel(
      rozetId: json['rozetid'] as int?,
      rozetAdi: json['rozetadi'] as String,
      rozetIconAdi: json['rozet_icon_adi'] as String?,
      rozetAciklama:
          json['rozetaciklama'] as String?, // API'den gelen 'rozetaciklama'
      kazanmaTarihi: json['kazanma_tarihi'] as String?,
    );
  }
}
