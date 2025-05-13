import 'package:flutter/material.dart';

// "ar_medic" projesinden alınan veya ona benzetilen renkler
class Renkler {
  static Color anaRenk = const Color(0xFFE53935); // Kırmızı tonu (İlk Yardım) - ar_medic
  static Color vurguRenk = const Color(0xFF1E88E5); // Mavi tonu (Testler/Bilgi) - ar_medic
  static Color yardimciRenk = const Color(0xFF4CAF50); // Yeşil (Başarı/Tamamlama) - ar_medic'teki basariRengi

  static Color arkaPlanRengi = const Color(0xFFF5F5F5); // Açık gri arka plan - ar_medic
  static Color kartArkaPlanRengi = Colors.white; // Genellikle beyaz kartlar
  static Color appBarArkaPlan = Colors.white; // Beyaz AppBar - ar_medic

  static Color anaMetinRengi = Colors.black87; // Genel metin rengi - ar_medic metinRengi
  static Color ikincilMetinRengi = Colors.grey[700]!; // Daha soluk metinler - ar_medic ikincilMetinRengi (600 idi, 700 yaptık)
  static Color ikonRengi = Colors.black87; // Koyu gri ikonlar/başlıklar - ar_medic
  static Color butonYaziRengi = Colors.white;

  // Bunlar zaten vardı, isimleri ve değerleri ar_medic'e uyumlu
  static Color basariRengi = const Color(0xFF4CAF50); // ar_medic ile aynı
  static Color hataRengi = const Color(0xFFF44336);
  static Color uyariRengi = const Color(0xFFFF9800); // Turuncu uyarı
}
