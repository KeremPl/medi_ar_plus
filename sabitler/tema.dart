// Flutter materyal tasarım kütüphanesini ve uygulama içi renk/metin stili sabitlerini import eder.
import 'package:flutter/material.dart';
import 'renkler.dart'; // Uygulamanın renk paletini içerir.
import 'metin_stilleri.dart'; // Uygulamanın standart metin stillerini içerir.

/// [AppTema] sınıfı, uygulamanın genel görünümünü ve hissini tanımlayan
/// `ThemeData` nesnesini merkezi bir yerde yapılandırır.
/// Bu, renkler, yazı tipleri, buton stilleri, AppBar stilleri gibi birçok
/// UI bileşeninin varsayılan görünümünü belirler.
/// "ar_medic" projesindeki tema yapısına benzetilerek oluşturulmuştur.
class AppTema {
  /// Uygulamanın açık (light) teması.
  static final ThemeData acikTema = ThemeData(
    // Genel Tema Ayarları
    brightness: Brightness.light, // Temanın aydınlık modda olduğunu belirtir.
    primaryColor: Renkler.anaRenk, // Uygulamanın birincil markalaşma rengi.
    scaffoldBackgroundColor: Renkler.arkaPlanRengi, // Sayfaların varsayılan arkaplan rengi.
    fontFamily: 'Roboto', // Uygulama genelinde kullanılacak varsayılan yazı tipi ailesi.
                         // "ar_medic" projesinde de bu veya benzeri bir yazı tipi kullanılıyordu.

    // Renk Şeması (ColorScheme): Materyal Tasarım 3 (Material 3) ile daha önemli hale gelmiştir.
    // Farklı UI bileşenlerinin renklerini daha detaylı kontrol etmeyi sağlar.
    colorScheme: ColorScheme.light(
      primary: Renkler.anaRenk, // Birincil renk.
      secondary: Renkler.vurguRenk, // İkincil (vurgu) renk.
      surface: Renkler.kartArkaPlanRengi, // Kartlar, Dialoglar gibi yüzeylerin rengi.
      background: Renkler.arkaPlanRengi, // Genel arkaplan rengi.
      error: Renkler.hataRengi, // Hata durumları için renk.
      onPrimary: Renkler.butonYaziRengi, // Birincil renk üzerindeki metin/ikon rengi (örn: ana renkli butonun yazısı).
      onSecondary: Colors.white, // İkincil renk üzerindeki metin/ikon rengi.
      onSurface: Renkler.anaMetinRengi, // Yüzeyler (kartlar, dialoglar) üzerindeki metin/ikon rengi.
      onBackground: Renkler.anaMetinRengi, // Arkaplan üzerindeki metin/ikon rengi.
      onError: Colors.white, // Hata rengi üzerindeki metin/ikon rengi.
    ),

    // AppBar (Üst Bilgi Çubuğu) Teması
    appBarTheme: AppBarTheme(
      color: Renkler.appBarArkaPlan, // AppBar arkaplan rengi (`ar_medic` gibi beyaz).
      elevation: 1.0, // AppBar'ın altındaki gölge yüksekliği (`ar_medic` gibi hafif).
      iconTheme: IconThemeData(color: Renkler.ikonRengi), // AppBar ikonlarının rengi (`ar_medic` gibi).
      titleTextStyle: MetinStilleri.appBarBaslik, // AppBar başlık metni stili.
      centerTitle: true, // Başlığı ortalar (`ar_medic` gibi).
    ),

    // ElevatedButton (Yükseltilmiş Buton) Teması
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Renkler.anaRenk, // Butonun varsayılan arkaplan rengi (`ar_medic` ana buton rengi).
        foregroundColor: Renkler.butonYaziRengi, // Buton üzerindeki metin/ikon rengi.
        textStyle: MetinStilleri.butonYazisi, // Buton metni stili.
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0), // Buton içi dolgu (biraz daha dolgun).
        shape: RoundedRectangleBorder( // Buton şekli.
          borderRadius: BorderRadius.circular(12.0), // Köşeleri yuvarlatılmış (`ar_medic` gibi).
        ),
        elevation: 4.0, // Buton gölgesi (hafif).
      ),
    ),

    // TextButton (Metin Buton) Teması
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Renkler.vurguRenk, // Metin butonunun varsayılan rengi (`ar_medic` link rengi).
        textStyle: MetinStilleri.govdeMetni.copyWith(fontWeight: FontWeight.w500), // Metin stili.
      ),
    ),

    // InputDecoration (Giriş Alanı Dekorasyonu) Teması (TextFormField'lar için)
    inputDecorationTheme: InputDecorationTheme(
      filled: true, // Alanın içinin doldurulacağını belirtir.
      fillColor: Colors.white, // Giriş alanlarının iç rengi (veya `Renkler.kartArkaPlanRengi`).
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Alan içi dolgu.
      // Varsayılan kenarlık stili.
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      // Aktif (seçili olmayan) durumdaki kenarlık.
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[350]!, width: 1.0),
      ),
      // Odaklanılmış (içine tıklanmış) durumdaki kenarlık.
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Renkler.anaRenk, width: 2.0), // Odaklandığında ana renkte ve daha kalın.
      ),
      // Hata durumundaki kenarlık.
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Renkler.hataRengi, width: 1.5),
      ),
      // Hata durumunda ve odaklanılmış durumdaki kenarlık.
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Renkler.hataRengi, width: 2.0),
      ),
      labelStyle: MetinStilleri.govdeMetni.copyWith(color: Renkler.ikincilMetinRengi), // Etiket metni stili.
      hintStyle: MetinStilleri.govdeMetni.copyWith(color: Colors.grey[400]), // İpucu metni stili.
      prefixIconColor: Renkler.anaRenk, // Başlangıç ikonlarının rengi (`ar_medic` gibi).
    ),

    // Card (Kart) Teması
    cardTheme: CardTheme(
      elevation: 3.0, // Kartların varsayılan gölge yüksekliği (hafif).
      shape: RoundedRectangleBorder( // Kart şekli.
        borderRadius: BorderRadius.circular(12.0), // Köşeleri yuvarlatılmış (yumuşak).
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Kartlar arası varsayılan dış boşluk.
      color: Renkler.kartArkaPlanRengi, // Kart arkaplan rengi.
      clipBehavior: Clip.antiAlias, // Kart içeriğinin köşelerden taşmasını engeller.
    ),

    // BottomNavigationBar (Alt Navigasyon Çubuğu) Teması
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white, // Arkaplan rengi (`ar_medic` gibi).
      selectedItemColor: Renkler.anaRenk, // Seçili öğenin rengi.
      unselectedItemColor: Colors.grey[600], // Seçili olmayan öğelerin rengi.
      selectedLabelStyle: MetinStilleri.kucukMetin.copyWith(fontWeight: FontWeight.w500), // Seçili etiketin stili.
      unselectedLabelStyle: MetinStilleri.kucukMetin, // Seçili olmayan etiketin stili.
      showUnselectedLabels: true, // Seçili olmayan etiketleri de göster.
      type: BottomNavigationBarType.fixed, // Tüm etiketler her zaman görünür (kayan tip değil).
      elevation: 8.0, // Navigasyon çubuğunun üstündeki gölge.
    ),

    // Dialog (Diyalog Kutusu) Teması
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Daha yuvarlak köşeli diyaloglar.
      ),
      backgroundColor: Renkler.kartArkaPlanRengi, // Diyalog arkaplan rengi.
      titleTextStyle: MetinStilleri.altBaslik, // Diyalog başlığı stili.
      contentTextStyle: MetinStilleri.govdeMetni, // Diyalog içeriği metin stili.
    ),

    // Chip (Etiket) Teması
    chipTheme: ChipThemeData(
      backgroundColor: Renkler.vurguRenk.withAlpha(30), // Chip'lerin varsayılan hafif arkaplanı.
      labelStyle: MetinStilleri.kucukMetin.copyWith(color: Renkler.vurguRenk), // Etiket metni stili.
      selectedColor: Renkler.vurguRenk, // Seçili chip rengi.
      secondarySelectedColor: Renkler.anaRenk, // İkincil seçili chip rengi (kullanım senaryosuna bağlı).
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0), // Chip içi dolgu.
      // Stadyum şeklinde (tam yuvarlak kenarlı) ve hafif bir kenarlığa sahip chip'ler.
      shape: StadiumBorder(side: BorderSide(color: Renkler.vurguRenk.withAlpha(100))),
    ),

    // Divider (Ayırıcı Çizgi) Teması
    dividerTheme: DividerThemeData(
      color: Colors.grey[300], // Ayırıcı çizgi rengi.
      thickness: 1.0, // Çizgi kalınlığı.
      space: 1.0, // Çizginin kapladığı dikey/yatay boşluk (genellikle padding ile daha iyi yönetilir).
    ),
  );
}
