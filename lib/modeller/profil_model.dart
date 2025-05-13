import 'kullanici_model.dart';
import 'rozet_model.dart';

class ProfilModel {
  final KullaniciModel kullaniciBilgileri;
  final List<RozetModel> kazanilanRozetler;

  ProfilModel({
    required this.kullaniciBilgileri,
    required this.kazanilanRozetler,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    var rozetlerListesi = json['kazanilan_rozetler'] as List?;
    List<RozetModel> rozetler = rozetlerListesi != null
        ? rozetlerListesi.map((i) => RozetModel.fromProfil(i)).toList()
        : [];

    return ProfilModel(
      kullaniciBilgileri: KullaniciModel.fromJson(json['kullanici_bilgileri']),
      kazanilanRozetler: rozetler,
    );
  }
}
