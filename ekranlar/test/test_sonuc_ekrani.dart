// Flutter materyal tasarım kütüphanesini ve Provider paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Uygulama içi provider'ları, sabitleri, modelleri ve yardımcı sınıfları import eder.
import '../../providerlar/test_provider.dart';
import '../../providerlar/profil_provider.dart'; // Kazanılan rozetler sonrası profili güncellemek için.
import '../../providerlar/navigasyon_provider.dart'; // Ana sayfaya dönerken sekme ayarlamak için.
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
// import '../../modeller/rozet_model.dart'; // RozetModel, TestProvider'dan dolaylı olarak geliyor, direkt import'a gerek yok.
import '../../utils/ikon_donusturucu.dart'; // String ikon adlarını IconData'ya çevirmek için.
import '../ana_sayfa_yonetici.dart'; // Ana sayfaya veya profile gitmek için.
// import '../profil/profil_ekrani.dart'; // Profil ekranına direkt gitmek yerine AnaSayfaYoneticisi üzerinden gidilecek.

/// [TestSonucEkrani], tamamlanan bir testin sonuçlarını (puan, doğru/yanlış sayısı, kazanılan rozetler)
/// kullanıcıya gösteren ve kullanıcıyı ana sayfaya veya profil sayfasına yönlendiren arayüzü sunar.
/// Bu bir `StatefulWidget`'tır çünkü `initState` içinde test sonucunu API'ye gönderme ve alma işlemi başlatılır.
class TestSonucEkrani extends StatefulWidget {
  final int testId; // Sonuçları gösterilecek testin ID'si.

  /// Constructor. Gerekli `testId` parametresini alır.
  const TestSonucEkrani({super.key, required this.testId});

  /// Bu widget için state nesnesini oluşturur.
  @override
  State<TestSonucEkrani> createState() => _TestSonucEkraniState();
}

/// [TestSonucEkrani] için state yönetimini ve UI mantığını içeren sınıf.
class _TestSonucEkraniState extends State<TestSonucEkrani> {
  /// Widget ilk oluşturulduğunda ve ağaca eklendiğinde çağrılır.
  @override
  void initState() {
    super.initState();
    // `WidgetsBinding.instance.addPostFrameCallback` ile build metodu tamamlandıktan sonra işlem yapılır.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final testProvider = Provider.of<TestProvider>(context, listen: false);
      // TestProvider üzerinden test sonucunu API'ye gönderir ve sonucu alır.
      await testProvider.testiBitir(widget.testId);
      // Eğer yeni rozetler kazanıldıysa ve widget hala ağaçtaysa, ProfilProvider'ı tetikleyerek
      // profil sayfasındaki rozet listesinin güncellenmesini sağlar.
      if (testProvider.kazanilanRozetler.isNotEmpty && mounted) {
          Provider.of<ProfilProvider>(context, listen: false).kullaniciProfiliniGetir();
      }
    });
  }

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    // TestProvider'a erişim sağlar (dinleme yaparak, UI güncellemeleri için).
    final testProvider = Provider.of<TestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucunuz'), // AppBar başlığı.
        // Geri butonunu otomatik olarak eklemez, çünkü bu ekran genellikle bir final adımdır.
        automaticallyImplyLeading: false,
      ),
      // Ekranın ana gövdesini `_buildBody` metodu ile oluşturur.
      body: _buildBody(testProvider),
    );
  }

  /// Ekranın ana gövdesini oluşturan yardımcı metot.
  /// Test sonucu yükleme durumu, hata durumu ve sonucun içeriğine göre farklı UI'lar gösterir.
  Widget _buildBody(TestProvider provider) {
    // Test sonucu yükleniyorsa ve henüz puan bilgisi yoksa yükleme göstergesi gösterir.
    if (provider.testSonucuYukleniyor && provider.sonucPuan == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Hata mesajı varsa ve puan bilgisi yoksa hata mesajını gösterir.
    if (provider.hataMesaji != null && provider.sonucPuan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            provider.hataMesaji!,
            style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // Puan bilgisi yüklenememişse (null ise) bilgilendirme mesajı gösterir.
    if (provider.sonucPuan == null) {
      return Center(
        child: Text('Test sonucu hesaplanamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    // Puanı double'a çevirir (API'den string olarak gelebilir). Başarısız olursa 0.0 atanır.
    double puan = double.tryParse(provider.sonucPuan!) ?? 0.0;
    // Başarı durumu: Puan 80 veya üzeriyse başarılı kabul edilir.
    bool basarili = puan >= 80;

    // Doğru, yanlış ve toplam soru sayılarını hesaplar.
    int dogruSayisi = 0;
    int yanlisSayisi = 0;
    // TestProvider'daki `testSorulariModel` null değilse soru sayısını alır.
    int toplamSoru = provider.testSorulariModel?.sorular.length ?? 0;

    // Eğer soru modeli varsa ve cevaplar verilmişse doğru/yanlış sayısını hesaplar.
    // Bu kısım, TestProvider'da `testiBitir` içinde zaten yapıldığı için burada tekrar
    // yapılmasına gerek olmayabilir. Ancak, UI'da anlık gösterim için tutulmuş olabilir.
    // Optimal durumda bu hesaplama provider'da merkezi olarak yapılır ve UI sadece sonucu gösterir.
    if (provider.testSorulariModel != null) {
       for (var soru in provider.testSorulariModel!.sorular) {
          int? kullaniciCevapId = provider.verilenCevaplar[soru.soruId];
          if (kullaniciCevapId != null) {
            bool soruDogruMu = soru.cevaplar.any((c) => c.cevapId == kullaniciCevapId && c.dogruMu);
            if (soruDogruMu) {dogruSayisi++;} else {yanlisSayisi++;}
          } else {
            // Cevaplanmamış sorular yanlış kabul ediliyor.
            yanlisSayisi++;
          }
        }
    }

    // Sonuç ekranının ana içeriği.
    return Padding(
      padding: const EdgeInsets.all(24.0), // Ekranın etrafına dolgu.
      child: Column( // İçeriği dikey bir sütun halinde düzenler.
        mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortalar.
        crossAxisAlignment: CrossAxisAlignment.stretch, // Elemanları yatayda ekran genişliğine yayar.
        children: [
          // Başarı durumuna göre farklı ikon gösterir.
          Icon(
            basarili ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied_rounded,
            color: basarili ? Renkler.basariRengi : Renkler.hataRengi, // Başarı/hata rengi.
            size: 90, // İkon boyutu.
          ),
          const SizedBox(height: 20), // İkon ile başlık arasına boşluk.

          // Başarı durumuna göre farklı başlık metni.
          Text(
            basarili ? 'Harika İş Çıkardın!' : 'Biraz Daha Çalışmalısın',
            style: MetinStilleri.ekranBasligi.copyWith(color: basarili ? Renkler.basariRengi : Renkler.hataRengi),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12), // Başlık ile puan arasına boşluk.

          // Kullanıcının puanını gösterir.
          Text(
            'Puanınız: ${provider.sonucPuan}%',
            style: MetinStilleri.ekranBasligi.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          // Eğer toplam soru sayısı biliniyorsa (0'dan büyükse), doğru/yanlış sayısını gösterir.
          if(toplamSoru > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '$toplamSoru sorudan $dogruSayisi doğru, $yanlisSayisi yanlış.',
              style: MetinStilleri.govdeMetniIkincil,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28), // Puan/doğru-yanlış bilgisi ile rozetler arasına boşluk.

          // Eğer yeni rozetler kazanıldıysa, bu rozetleri listeler.
          if (provider.kazanilanRozetler.isNotEmpty) ...[
            Text(
              'Yeni Rozetler Kazandın!',
              style: MetinStilleri.altBaslik.copyWith(color: Renkler.yardimciRenk, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16), // Rozet başlığı ile rozetler arasına boşluk.
            // Wrap widget'ı, rozetleri satıra sığdığı kadar dizer, sığmazsa alt satıra geçer.
            Wrap(
              alignment: WrapAlignment.center, // Rozetleri satır içinde ortalar.
              spacing: 12.0, // Rozetler arası yatay boşluk.
              runSpacing: 12.0, // Satırlar arası dikey boşluk.
              children: provider.kazanilanRozetler.map((rozet) {
                // Her bir kazanılan rozet için bir Chip widget'ı oluşturur.
                return Chip(
                  avatar: Icon( // Rozet ikonu.
                    IkonDonusturucu.getIconData(rozet.rozetIconAdi),
                    color: Renkler.yardimciRenk,
                  ),
                  label: Text(rozet.rozetAdi, style: MetinStilleri.govdeMetni), // Rozet adı.
                  backgroundColor: Renkler.yardimciRenk.withAlpha((0.15 * 255).round()), // Chip arkaplanı.
                );
              }).toList(),
            ),
            const SizedBox(height: 28), // Rozet listesi ile butonlar arasına boşluk.
          ],

          // "Ana Sayfaya Dön" butonu.
          ElevatedButton.icon(
            icon: const Icon(Icons.home_outlined),
            label: const Text('Ana Sayfaya Dön'),
            onPressed: () {
               // TestProvider'daki state'i sıfırlar (mevcut test verilerini temizler).
               Provider.of<TestProvider>(context, listen: false).resetState();
               // NavigasyonProvider üzerinden ana sayfada "Kütüphane" (index 1) sekmesinin seçili olmasını sağlar.
               Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(1); // Genellikle testler eğitim sonrası olduğu için eğitim listesine yönlendirir.
               // Kullanıcıyı AnaSayfaYoneticisi'ne yönlendirir ve aradaki tüm ekranları yığından kaldırır.
               Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AnaSayfaYoneticisi()),
                  (Route<dynamic> route) => false, // Tüm önceki yolları kaldır.
                );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), // Buton stili.
          ),
          const SizedBox(height: 12), // Butonlar arasına boşluk.

          // "Profilime Git" butonu (TextButton olarak).
          TextButton.icon(
            icon: const Icon(Icons.person_outline),
            label: const Text('Profilime Git'),
            onPressed: () {
              // TestProvider'daki state'i sıfırlar.
              Provider.of<TestProvider>(context, listen: false).resetState();
              // NavigasyonProvider üzerinden ana sayfada "Profil" (index 3) sekmesinin seçili olmasını sağlar.
              Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(3);
              // Kullanıcıyı AnaSayfaYoneticisi'ne (ve dolayısıyla Profil ekranına) yönlendirir
              // ve aradaki tüm ekranları yığından kaldırır.
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AnaSayfaYoneticisi()),
                  (Route<dynamic> route) => false,
                );
            },
          ),
        ],
      ),
    );
  }
}
