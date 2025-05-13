import 'package:flutter/material.dart';

class IkonDonusturucu {
  static IconData getIconData(String? iconName) {
    if (iconName == null) return Icons.help_outline;

    switch (iconName.toLowerCase()) {
      case 'quiz':
      case 'quiz_outline':
        return Icons.quiz_outlined;
      case 'assignment':
        return Icons.assignment_outlined;
      case 'rule':
        return Icons.rule_outlined;
      case 'psychology':
        return Icons.psychology_outlined;
       case 'medical_services':
        return Icons.medical_services_outlined;
      case 'health_and_safety':
        return Icons.health_and_safety_outlined;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events_outlined;
      case 'star':
      case 'star_outline':
        return Icons.star_outline;
      case 'verified':
      case 'verified_user':
        return Icons.verified_user_outlined;
      case 'workspace_premium':
        return Icons.workspace_premium_outlined;
      case 'local_fire_department':
         return Icons.local_fire_department_outlined;
      case 'bloodtype':
         return Icons.bloodtype_outlined;
      case 'healing':
         return Icons.healing_outlined;
      case 'info':
      case 'info_outline':
        return Icons.info_outline;
      case 'settings':
        return Icons.settings_outlined;
      case 'person':
      case 'person_outline':
        return Icons.person_outline;
      case 'school':
      case 'school_outline':
        return Icons.school_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'category':
        return Icons.category_outlined;
      case 'arrow_back':
      case 'arrow_back_ios':
        return Icons.arrow_back_ios_new;
      case 'arrow_forward':
      case 'arrow_forward_ios':
        return Icons.arrow_forward_ios;
      case 'done':
        return Icons.done;
      case 'close':
        return Icons.close;
      case 'error':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'visibility':
        return Icons.visibility_outlined;
      case 'visibility_off':
        return Icons.visibility_off_outlined;
      default:
        // print("Uyarı: Bilinmeyen ikon adı '$iconName', varsayılan ikon kullanılıyor."); // Kaldırıldı
        return Icons.help_outline;
    }
  }
}