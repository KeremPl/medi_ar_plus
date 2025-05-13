import 'package:flutter/material.dart';
import 'renkler.dart';

// "ar_medic" projesinden alınan veya ona benzetilen metin stilleri
class MetinStilleri {
  static TextStyle appBarBaslik = TextStyle( // ar_medic'teki baslikStili
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    color: Renkler.ikonRengi,
  );

  static TextStyle ekranBasligi = TextStyle( // ar_medic'teki baslikStili.copyWith(fontSize: 24, fontWeight: FontWeight.bold)
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Renkler.anaMetinRengi,
  );

  static TextStyle altBaslik = TextStyle( // ar_medic'teki altBaslik
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: Renkler.anaMetinRengi,
  );

  static TextStyle kartBasligi = TextStyle( // ar_medic'teki kutuBaslik
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    color: Renkler.anaMetinRengi,
  );

  static TextStyle govdeMetni = TextStyle( // ar_medic'teki normalMetin
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: Renkler.anaMetinRengi,
    height: 1.4,
  );

  static TextStyle govdeMetniIkincil = TextStyle( // ar_medic'teki normalMetinGri
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: Renkler.ikincilMetinRengi,
    height: 1.4,
  );

  static TextStyle butonYazisi = const TextStyle( // ar_medic'teki butonYazisi
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle kucukMetin = TextStyle( // ar_medic'teki kucukMetin
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: Renkler.ikincilMetinRengi,
  );

   static TextStyle cokKucukMetin = TextStyle( // ar_medic'teki cokKucukMetin
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    color: Renkler.ikincilMetinRengi,
  );

  static TextStyle linkMetni = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Renkler.vurguRenk, // ar_medic'teki gibi vurgu rengi
    // decoration: TextDecoration.underline, // İsteğe bağlı
  );
}
