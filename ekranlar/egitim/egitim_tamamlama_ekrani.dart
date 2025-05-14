// Flutter materyal tasarım kütüphanesini ve Provider paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // NavigasyonProvider'a erişmek için gerekli.
// Uygulama içi sabitleri, provider'ları ve ekranları import eder.
import '../../providerlar/navigasyon_provider.dart'; // Ana sayfaya dönerken sekme ayarlamak için.
import '../../sabitler/renkler.dart'; // Uygulama renklerini içerir.
import '../../sabitler/metin_stilleri.dart'; // Uygulama metin stillerini içerir.
import '../test/test_soru_ekrani.dart'; // "Teste Başla" butonu tıklandığında yönlendirilecek ekran.
import '../ana_sayfa_yonetici.dart'; // "Ana Sayfaya Dön" butonu tıklandığında yönlendirilecek ekran.

// Yorumlu importlar:
// Direkt olarak kullanılmayan provider ve ekranlar, Navigator içinde `MaterialPageRoute(builder: (_) => Ekran())`
// şeklinde çağrıldığı için direkt import edilmelerine gerek yoktur. Ancak, provider'lara
// `Provider.of<XProvider>(context)` ile erişilecekse import edilmeleri gerekir (NavigasyonProvider gibi).
// import '../../providerlar/egitim_detay_provider.dart'; // Bu ekranda direkt kullanılmıyor.


/// [EgitimTamamlamaEkrani], bir eğitimin başarıyla tamamlandığını kullanıcıya bildiren
/// ve kullanıcıyı bir sonraki adıma (genellikle ilgili teste) veya ana sayfaya yönlendiren
/// bir arayüz sunar.
class EgitimTamamlamaEkrani extends StatelessWidget {
  final String egitimAdi; // Tamamlanan eğitimin adı, tebrik mesajında gösterilir.
  final int testId; // İlgili testin ID'si, "Teste Başla" butonuna basıldığında kullanılır.

  /// Constructor. Gerekli `egitimAdi` ve `testId` parametrelerini alır.
  const EgitimTamamlamaEkrani({
    super.key,
    required this.egitimAdi,
    required this.testId,
  });

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( // İçeriği dikey ve yatay olarak ortalar.
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Ekranın etrafına dolgu.
          child: Column( // İçeriği dikey bir sütun halinde düzenler.
            mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortalar.
            crossAxisAlignment: CrossAxisAlignment.stretch, // Elemanları yatayda ekran genişliğine yayar.
            children: [
              // Başarı ikonu.
              Icon(
                Icons.check_circle_outline,
                color: Renkler.yardimciRenk, // Yeşil tonunda başarı rengi.
                size: 80, // İkon boyutu.
              ),
              const SizedBox(height: 24), // İkon ile tebrik mesajı arasına boşluk.

              // Tebrik başlığı.
              Text(
                'Tebrikler!',
                style: MetinStilleri.ekranBasligi.copyWith(color: Renkler.yardimciRenk),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8), // Başlık ile detay mesajı arasına boşluk.

              // Tamamlanan eğitim hakkında detaylı mesaj.
              Text(
                '"$egitimAdi" eğitimini başarıyla tamamladınız.',
                style: MetinStilleri.altBaslik,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32), // Mesaj ile butonlar arasına boşluk.

              // "Şimdi Teste Başla" butonu.
              ElevatedButton(
                onPressed: () {
                  // Kullanıcıyı TestSoruEkrani'na yönlendirir ve mevcut ekranı yığından kaldırır (pushReplacement).
                  // `testId` parametresi ile hangi testin açılacağı belirtilir.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TestSoruEkrani(testId: testId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.vurguRenk, // Buton rengi (vurgu rengi).
                  minimumSize: const Size(double.infinity, 50), // Butonun minimum boyutu.
                ),
                child: const Text('Şimdi Teste Başla'), // Buton üzerindeki yazı.
              ),
              const SizedBox(height: 16), // Butonlar arasına boşluk.

              // "Ana Sayfaya Dön" butonu (TextButton olarak).
              TextButton(
                onPressed: () {
                  // NavigasyonProvider üzerinden ana sayfada "Kütüphane" (index 1) sekmesinin seçili olmasını sağlar.
                  Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(1);
                  // Kullanıcıyı AnaSayfaYoneticisi'ne yönlendirir ve aradaki tüm ekranları yığından kaldırır.
                  // Bu, geri tuşuna basıldığında tamamlanmış eğitime veya teste dönülmesini engeller.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AnaSayfaYoneticisi()),
                    (Route<dynamic> route) => false, // Tüm önceki yolları kaldırır.
                  );
                },
                child: Text(
                  'Ana Sayfaya Dön',
                  style: MetinStilleri.linkMetni.copyWith(color: Renkler.ikincilMetinRengi), // Link stili.
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
