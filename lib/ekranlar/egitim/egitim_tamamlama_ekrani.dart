import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/navigasyon_provider.dart';
import '../../providerlar/egitim_detay_provider.dart'; // resetState için
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../test/test_soru_ekrani.dart';
import '../ana_sayfa_yonetici.dart';

class EgitimTamamlamaEkrani extends StatelessWidget {
  final String egitimAdi;
  final int testId;

  const EgitimTamamlamaEkrani({
    super.key,
    required this.egitimAdi,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    // Bu ekrana gelindiğinde EgitimDetayProvider'ı resetleyebiliriz.
    // Ancak zaten bir önceki ekrandan çıkarken resetlenmiş oluyor.
    // Provider.of<EgitimDetayProvider>(context, listen: false).resetState(); // İsteğe bağlı

    return Scaffold(
      body: Center( /* ... (içerik aynı, resetAdim -> resetState değişikliği yok) ... */ ),
    );
  }
}