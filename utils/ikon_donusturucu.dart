// Flutter materyal tasarım kütüphanesini import eder, bu sayede `IconData` tipi ve
// standart Materyal ikonları kullanılabilir.
import 'package:flutter/material.dart';

/// [IkonDonusturucu], API'den veya başka bir kaynaktan string olarak gelen
/// ikon adlarını Flutter'ın `IconData` nesnelerine dönüştüren yardımcı bir sınıftır.
/// Bu, dinamik olarak ikon belirlemeyi kolaylaştırır.
class IkonDonusturucu {
  /// Verilen string `iconName`'e karşılık gelen `IconData` nesnesini döndürür.
  ///
  /// Parametreler:
  ///   [iconName]: Dönüştürülecek ikonun string adı (örn: "quiz", "star_outline").
  ///                Bu ad küçük/büyük harfe duyarlı değildir (içeride `toLowerCase()` kullanılır).
  ///
  /// Dönüş Değeri:
  ///   Eşleşen bir `IconData` bulunursa onu döndürür.
  ///   Eğer `iconName` null ise veya eşleşen bir ikon bulunamazsa,
  ///   varsayılan olarak `Icons.help_outline` (soru işareti ikonu) döndürülür.
  static IconData getIconData(String? iconName) {
    // Eğer ikon adı null ise, varsayılan bir ikon döndür.
    if (iconName == null) return Icons.help_outline;

    // İkon adını küçük harfe çevirerek karşılaştırmalarda büyük/küçük harf duyarlılığını ortadan kaldır.
    switch (iconName.toLowerCase()) {
      // Test ve Sınav İkonları
      case 'quiz':
      case 'quiz_outline':
        return Icons.quiz_outlined;
      case 'assignment': // Görev, ödev veya test anlamında da kullanılabilir.
        return Icons.assignment_outlined;
      case 'rule': // Kurallar veya test yönergeleri için.
        return Icons.rule_outlined;
      case 'psychology': // Psikoloji veya zihinsel sağlıkla ilgili testler için.
        return Icons.psychology_outlined;

      // Sağlık ve İlk Yardım İkonları
      case 'medical_services': // Tıbbi hizmetler.
        return Icons.medical_services_outlined;
      case 'health_and_safety': // Sağlık ve güvenlik.
        return Icons.health_and_safety_outlined;
      case 'local_fire_department': // Yangın veya acil durum.
        return Icons.local_fire_department_outlined;
      case 'bloodtype': // Kan grubu veya kan bağışı.
        return Icons.bloodtype_outlined;
      case 'healing': // İyileşme, tedavi.
        return Icons.healing_outlined;

      // Başarı ve Rozet İkonları
      case 'military_tech': // Askeri teknoloji veya madalya benzeri bir başarı.
      case 'emoji_events': // Kupa, ödül.
        return Icons.emoji_events_outlined;
      case 'star':
      case 'star_outline': // Yıldız.
        return Icons.star_outline;
      case 'verified':
      case 'verified_user': // Onaylanmış, doğrulanmış.
        return Icons.verified_user_outlined;
      case 'workspace_premium': // Premium, özel başarı.
        return Icons.workspace_premium_outlined;

      // Genel Kullanım İkonları
      case 'info':
      case 'info_outline': // Bilgi.
        return Icons.info_outline;
      case 'settings': // Ayarlar.
        return Icons.settings_outlined;
      case 'person':
      case 'person_outline': // Kişi, profil.
        return Icons.person_outline;
      case 'school':
      case 'school_outline': // Okul, eğitim.
        return Icons.school_outlined;
      case 'home': // Ana sayfa.
        return Icons.home_outlined;
      case 'category': // Kategori.
        return Icons.category_outlined;

      // Navigasyon ve Eylem İkonları
      case 'arrow_back':
      case 'arrow_back_ios': // Geri ok (iOS stili).
        return Icons.arrow_back_ios_new;
      case 'arrow_forward':
      case 'arrow