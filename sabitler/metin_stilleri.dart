// Flutter materyal tasarım kütüphanesini ve uygulama içi renk sabitlerini import eder.
import 'package:flutter/material.dart';
import 'renkler.dart'; // Metin renkleri için Renkler sınıfını kullanır.

/// [MetinStilleri] sınıfı, uygulama genelinde kullanılacak olan standart metin stillerini
/// (`TextStyle`) merkezi bir yerde tanımlar. Bu, uygulamanın metin görünümünde
/// tutarlılık sağlar ve stil değişikliklerini kolaylaştırır.
/// "ar_medic" projesindeki isimlendirmeler ve stiller temel alınarak veya onlara benzetilerek oluşturulmuştur.
class MetinStilleri {
  /// AppBar başlıkları için kullanılacak stil.
  /// `ar_medic` projesindeki `baslikStili`'ne benzer.
  static TextStyle appBarBaslik = TextStyle(
    fontSize: 20.0, // Yazı tipi boyutu.
    fontWeight: FontWeight.w500, // Yazı tipi kalınlığı (orta).
    color: Renkler.ikonRengi, // Metin rengi (genellikle AppBar ikonlarıyla uyumlu).
  );

  /// Ekranların ana başlıkları için kullanılacak stil (örn: Giriş, Kayıt Ol).
  /// `ar_medic` projesindeki `baslikStili`'nin daha büyük ve kalın hali.
  static TextStyle ekranBasligi = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold, // Kalın yazı.
    color: Renkler.anaMetinRengi, // Ana metin rengi.
  );

  /// Alt başlıklar veya önemli metin bölümleri için kullanılacak stil.
  /// `ar_medic` projesindeki `altBaslik` stiline benzer.
  static TextStyle altBaslik = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500, // Orta kalınlık.
    color: Renkler.anaMetinRengi,
  );

  /// Kart içindeki başlıklar (örn: eğitim kartı başlığı) için kullanılacak stil.
  /// `ar_medic` projesindeki `kutuBaslik` stiline benzer.
  static TextStyle kartBasligi = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    color: Renkler.anaMetinRengi,
  );

  /// Genel gövde metinleri, paragraflar ve açıklamalar için kullanılacak standart stil.
  /// `ar_medic` projesindeki `normalMetin` stiline benzer.
  static TextStyle govdeMetni = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal, // Normal kalınlık.
    color: Renkler.anaMetinRengi,
    height: 1.4, // Satır yüksekliği (okunabilirliği artırır).
  );

  /// Daha az önemli veya ikincil gövde metinleri için kullanılacak stil (genellikle gri tonlarda).
  /// `ar_medic` projesindeki `normalMetinGri` stiline benzer.
  static TextStyle govdeMetniIkincil = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: Renkler.ikincilMetinRengi, // İkincil metin rengi (gri).
    height: 1.4,
  );

  /// Butonların üzerindeki yazılar için kullanılacak stil.
  /// `ar_medic` projesindeki `butonYazisi` stiline benzer.
  static TextStyle butonYazisi = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500, // Orta kalınlık.
    letterSpacing: 0.5, // Harfler arası boşluk (biraz daha yayvan görünüm).
  );

  /// Küçük boyutlu bilgilendirme metinleri veya etiketler için kullanılacak stil.
  /// `ar_medic` projesindeki `kucukMetin` stiline benzer.
  static TextStyle kucukMetin = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: Renkler.ikincilMetinRengi,
  );

  /// Çok küçük boyutlu metinler (örn: rozet kartındaki tarih, dipnotlar) için kullanılacak stil.
  /// `ar_medic` projesindeki `cokKucukMetin` stiline benzer.
  static TextStyle cokKucukMetin = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    color: Renkler.ikincilMetinRengi,
  );

  /// Tıklanabilir link benzeri metinler için kullanılacak stil.
  /// `ar_medic` projesindeki vurgu rengini kullanır.
  static TextStyle linkMetni = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500, // Orta kalınlık.
    color: Renkler.vurguRenk, // Vurgu rengi (genellikle mavi).
    // decoration: TextDecoration.underline, // İsteğe bağlı olarak altı çizili yapılabilir.
  );
}
