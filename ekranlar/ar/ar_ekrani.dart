// Flutter materyal tasarım kütüphanesini ve uygulama içi sabitleri import eder.
import 'package:flutter/material.dart';
import '../../sabitler/renkler.dart'; // Uygulama renklerini içerir.
import '../../sabitler/metin_stilleri.dart'; // Uygulama metin stillerini içerir.

/// [ArEkrani], Artırılmış Gerçeklik (AR) özelliklerinin sunulacağı ekranı temsil eder.
/// Şu anki implementasyonda, bu ekran bir yer tutucudur ve AR işlevselliğinin
/// gelecekte ekleneceğini belirten bir mesaj ve buton içerir.
class ArEkrani extends StatelessWidget {
  /// Constructor. `key` parametresi widget ağacında bu widget'ı benzersiz şekilde tanımlamak için kullanılır.
  const ArEkrani({super.key});

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar (üst bilgi çubuğu).
      appBar: AppBar(
        // AppBar başlığı, MetinStilleri.appBarBaslik stilini kullanır.
        title: Text('AR Kamera', style: MetinStilleri.appBarBaslik),
        // Bu ekran BottomNavigationBar üzerinden geldiği için genellikle geri butonu olmaz.
        // Eğer direkt bir sayfadan gelinmiş olsaydı, aşağıdaki gibi bir geri butonu eklenebilirdi:
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      // Ekranın ana gövdesi.
      body: Center( // İçeriği dikey ve yatay olarak ortalar.
        child: Padding(
          // İçeriğe her yönden 32 piksellik bir dolgu (padding) ekler.
          padding: const EdgeInsets.all(32.0),
          child: Column( // İçeriği dikey bir sütun halinde düzenler.
            mainAxisAlignment: MainAxisAlignment.center, // Sütun içindeki elemanları dikeyde ortalar.
            children: [
              // Bir kamera ikonu gösterir.
              Icon(
                Icons.camera_enhance_outlined,
                size: 80, // İkon boyutu.
                color: Renkler.anaRenk.withAlpha(180), // Ana rengin hafif şeffaf bir tonu.
              ),
              const SizedBox(height: 24), // İkon ile başlık arasına 24 piksellik dikey boşluk ekler.
              // AR deneyimi hakkında bir başlık metni.
              Text(
                'Artırılmış Gerçeklik Deneyimi',
                style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.w600), // Alt başlık stilini kullanır, kalınlaştırılmış.
                textAlign: TextAlign.center, // Metni ortalar.
              ),
              const SizedBox(height: 12), // Başlık ile açıklama arasına 12 piksellik dikey boşluk.
              // AR bölümünün amacı hakkında bir açıklama metni.
              Text(
                'Bu bölüm, ilk yardım senaryolarını artırılmış gerçeklik ile deneyimlemeniz için geliştirilmektedir.',
                style: MetinStilleri.govdeMetniIkincil, // İkincil gövde metni stilini kullanır.
                textAlign: TextAlign.center, // Metni ortalar.
              ),
              const SizedBox(height: 32), // Açıklama ile buton arasına 32 piksellik dikey boşluk.
              // AR kamerasını başlatmak için bir buton (şu an için işlevsel değil).
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt, size: 20), // Buton ikonu (biraz daha küçük).
                label: Text(
                  'AR Kamerayı Başlat',
                  style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi), // Tema'dan gelen buton yazı stili, ancak yazı rengi özellikle beyaz olarak ayarlanmış.
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.anaRenk, // Butonun arkaplan rengi ana renk.
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Buton içi dolgu.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Tam yuvarlak köşeli buton.
                  ),
                  // elevation: 5.0, // Buton gölgesi (Tema'dan ayarlanabilir).
                ),
                onPressed: () {
                  // TODO: AR kamera işlevselliği bu kısma eklenecek.
                  // Şu an için bir SnackBar mesajı gösterilir.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AR özelliği henüz aktif değil.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
