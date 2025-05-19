class KullaniciModel {
  final int id;
  final String ad;
  final String soyad;
  final String kullaniciAdi;
  final String email;


  KullaniciModel({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.kullaniciAdi,
    required this.email,
  });

  factory KullaniciModel.fromJson(Map<String, dynamic> json) {
    return KullaniciModel(
      id: json['id'] as int,
      ad: json['ad'] as String,
      soyad: json['soyad'] as String,
      kullaniciAdi: json['kullaniciadi'] as String, // API'deki anahtar
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'soyad': soyad,
      'kullaniciadi': kullaniciAdi,
      'email': email,
    };
  }
}
