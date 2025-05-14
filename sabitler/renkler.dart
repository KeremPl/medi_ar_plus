// Flutter materyal tasarım kütüphanesini import eder, bu sayede `Color` tipi kullanılabilir.
import 'package:flutter/material.dart';

/// [Renkler] sınıfı, uygulama genelinde kullanılacak olan standart renk paletini
/// merkezi bir yerde tanımlar. Bu, uygulamanın renk temasında tutarlılık sağlar
/// ve renk değişikliklerini kolaylaştırır.
/// "ar_medic" projesindeki renk tanımlamaları temel alınarak veya onlara benzetilerek oluşturulmuştur.
class Renkler {
  // Ana Tema Renkleri
  /// Uygulamanın ana rengi. Genellikle birincil eylemler, markalaşma ve önemli vurgular için kullanılır.
  /// Kırmızı tonu (İlk Yardım temasına uygun olarak) seçilmiştir. `ar_medic` projesinden.
  static Color anaRenk = const Color(0xFFE53935);

  /// Uygulamanın vurgu (accent) rengi. İkincil eylemler, aktif durumlar veya
  /// ana renkten farklılaşması gereken bileşenler için kullanılır.
  /// Mavi tonu (Testler/Bilgi temasına uygun olarak) seçilmiştir. `ar_medic` projesinden.
  static Color vurguRenk = const Color(0xFF1E88E5);

  /// Yardımcı renk. Genellikle başarı, tamamlama veya pozitif geri bildirimler için kullanılır.
  /// Yeşil tonu seçilmiştir. `ar_medic` projesindeki `basariRengi` ile aynı.
  static Color yardimciRenk = const Color(0xFF4CAF50);


  // Arkaplan Renkleri
  /// Uygulamanın genel sayfa arkaplan rengi.
  /// Açık gri bir ton seçilmiştir. `ar_medic` projesinden.
  static Color arkaPlanRengi = const Color(0xFFF5F5F5);

  /// Kartlar, dialoglar ve diğer yüzey bileşenleri için varsayılan arkaplan rengi.
  /// Genellikle beyazdır.
  static Color kartArkaPlanRengi = Colors.white;

  /// AppBar (üst bilgi çubuğu) için varsayılan arkaplan rengi.
  /// Beyaz seçilmiştir. `ar_medic` projesinden.
  static Color appBarArkaPlan = Colors.white;


  // Metin ve İkon Renkleri
  /// Ana metinler için varsayılan renk (örn: paragraflar, başlıklar).
  /// Hafifçe siyahtan açılmış bir ton (`Colors.black87`). `ar_medic` projesindeki `metinRengi`.
  static Color anaMetinRengi = Colors.black87;

  /// İkincil veya daha az önemli metinler için varsayılan renk (örn: alt yazılar, ipuçları).
  /// Koyu gri bir ton (`Colors.grey[700]`). `ar_medic` projesindeki `ikincilMetinRengi` (önceki 600 idi, 700 yapıldı).
  static Color ikincilMetinRengi = Colors.grey[700]!; // `!` null olamayacağını belirtir.

  /// İkonlar ve bazı başlıklar için varsayılan renk.
  /// `anaMetinRengi` ile aynı, koyu gri. `ar_medic` projesinden.
  static Color ikonRengi = Colors.black87;

  /// Butonların üzerindeki yazılar için varsayılan renk.
  /// Genellikle buton arkaplanıyla kontrast oluşturacak şekilde beyazdır.
  static Color butonYaziRengi = Colors.white;


  // Durum Renkleri (Geri Bildirim)
  /// Başarılı işlemler veya onaylar için kullanılacak renk.
  /// `yardimciRenk` ile aynı, yeşil. `ar_medic` projesiyle uyumlu.
  static Color basariRengi = const Color(0xFF4CAF50);

  /// Hatalı işlemler veya uyarılar için kullanılacak renk.
  /// Kırmızı bir ton.
  static Color hataRengi = const Color(0xFFF44336);

  /// Dikkat çekilmesi gereken durumlar veya hafif uyarılar için kullanılacak renk.
  /// Turuncu bir ton.
  static Color uyariRengi = const Color(0xFFFF9800);
}
