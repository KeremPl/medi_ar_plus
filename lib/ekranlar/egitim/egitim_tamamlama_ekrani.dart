import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Kullanılmıyor
// import '../../providerlar/navigasyon_provider.dart'; // Kullanılmıyor
// import '../../providerlar/egitim_detay_provider.dart'; // Kullanılmıyor
import '../../sabitler/renkler.dart'; // Kullanılıyor (style için)
import '../../sabitler/metin_stilleri.dart'; // Kullanılıyor (style için)
// import '../test/test_soru_ekrani.dart'; // Navigator içinde kullanılıyor
// import '../ana_sayfa_yonetici.dart'; // Navigator içinde kullanılıyor
// NOT: Yukarıdaki yorumlu importlar Navigator.pushReplacement/pushAndRemoveUntil içinde
// builder: (_) => const EkranAdi() şeklinde kullanıldığı için direkt import'a gerek yok.
// Ancak Renkler ve MetinStilleri doğrudan kullanıldığı için importları kalmalı.
// Provider'lar da context üzerinden erişildiği için direkt import'a gerek yok.
import 'package:provider/provider.dart'; // NavigasyonProvider için lazım olacak
import '../../providerlar/navigasyon_provider.dart'; // NavigasyonProvider için lazım olacak
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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Renkler.yardimciRenk,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Tebrikler!',
                style: MetinStilleri.ekranBasligi.copyWith(color: Renkler.yardimciRenk),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '"$egitimAdi" eğitimini başarıyla tamamladınız.',
                style: MetinStilleri.altBaslik,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TestSoruEkrani(testId: testId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.vurguRenk,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Şimdi Teste Başla'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(1);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AnaSayfaYoneticisi()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(
                  'Ana Sayfaya Dön',
                  style: MetinStilleri.linkMetni.copyWith(color: Renkler.ikincilMetinRengi),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}