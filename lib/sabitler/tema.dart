import 'package:flutter/material.dart';
import 'renkler.dart';
import 'metin_stilleri.dart';

// "ar_medic" projesine benzetilmiş tema
class AppTema {
  static final ThemeData acikTema = ThemeData(
    brightness: Brightness.light,
    primaryColor: Renkler.anaRenk,
    scaffoldBackgroundColor: Renkler.arkaPlanRengi,
    fontFamily: 'Roboto', // "ar_medic" projesinde de bu veya benzeri kullanılıyordu

    colorScheme: ColorScheme.light(
      primary: Renkler.anaRenk,
      secondary: Renkler.vurguRenk,
      surface: Renkler.kartArkaPlanRengi, // Kartlar, Dialoglar için
      background: Renkler.arkaPlanRengi, // Genel arkaplan
      error: Renkler.hataRengi,
      onPrimary: Renkler.butonYaziRengi, // Ana renk üzerindeki yazılar
      onSecondary: Colors.white, // Vurgu rengi üzerindeki yazılar (örn: mavi buton yazı beyaz)
      onSurface: Renkler.anaMetinRengi, // Kart, dialog yüzeylerindeki yazılar
      onBackground: Renkler.anaMetinRengi, // Arkaplan üzerindeki yazılar
      onError: Colors.white, // Hata rengi üzerindeki yazılar
    ),

    appBarTheme: AppBarTheme(
      color: Renkler.appBarArkaPlan, // ar_medic
      elevation: 1.0, // ar_medic
      iconTheme: IconThemeData(color: Renkler.ikonRengi), // ar_medic
      titleTextStyle: MetinStilleri.appBarBaslik, // ar_medic'teki baslikStili
      centerTitle: true, // ar_medic
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Renkler.anaRenk, // ar_medic ana buton rengi
        foregroundColor: Renkler.butonYaziRengi,
        textStyle: MetinStilleri.butonYazisi,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0), // Biraz daha dolgun butonlar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // ar_medic'teki gibi yuvarlak köşeler
        ),
        elevation: 4.0, // Hafif gölge
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Renkler.vurguRenk, // ar_medic link rengi
        textStyle: MetinStilleri.govdeMetni.copyWith(fontWeight: FontWeight.w500),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme( // ar_medic Login/Kayıt ekranlarındaki gibi
      filled: true,
      fillColor: Colors.white, // Alanların içi beyaz olabilir veya Renkler.kartArkaPlanRengi
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder( // Normal durumdaki border
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[350]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Renkler.anaRenk, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Renkler.hataRengi, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Renkler.hataRengi, width: 2.0),
      ),
      labelStyle: MetinStilleri.govdeMetni.copyWith(color: Renkler.ikincilMetinRengi),
      hintStyle: MetinStilleri.govdeMetni.copyWith(color: Colors.grey[400]),
      prefixIconColor: Renkler.anaRenk, // ar_medic
    ),

    cardTheme: CardTheme( // ar_medic'teki gibi
      elevation: 3.0, // Hafif yükselti
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Yumuşak köşeler
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Kartlar arası boşluk
      color: Renkler.kartArkaPlanRengi,
      clipBehavior: Clip.antiAlias, // Önemli
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData( // ar_medic
      backgroundColor: Colors.white,
      selectedItemColor: Renkler.anaRenk,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: MetinStilleri.kucukMetin.copyWith(fontWeight: FontWeight.w500),
      unselectedLabelStyle: MetinStilleri.kucukMetin,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
    ),

    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Daha yuvarlak dialoglar
      ),
      backgroundColor: Renkler.kartArkaPlanRengi,
      titleTextStyle: MetinStilleri.altBaslik,
      contentTextStyle: MetinStilleri.govdeMetni,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Renkler.vurguRenk.withAlpha(30), // Hafif arkaplan
      labelStyle: MetinStilleri.kucukMetin.copyWith(color: Renkler.vurguRenk),
      selectedColor: Renkler.vurguRenk,
      secondarySelectedColor: Renkler.anaRenk,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      shape: StadiumBorder(side: BorderSide(color: Renkler.vurguRenk.withAlpha(100))),
    ),

    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1.0,
      space: 1.0, // Genellikle divider'lar sıkışık olur, padding ile yönetilir
    ),
  );
}
