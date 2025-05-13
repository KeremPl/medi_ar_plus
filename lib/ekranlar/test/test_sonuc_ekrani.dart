import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/test_provider.dart';
import '../../providerlar/profil_provider.dart';
import '../../providerlar/navigasyon_provider.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
// import '../../utils/ikon_donusturucu.dart'; // Kullanılmıyorsa kaldırılabilir (Rozet Chip'i için kullanılıyordu)
import '../ana_sayfa_yonetici.dart';
import '../../modeller/rozet_model.dart'; // RozetModel için eklendi (Chip'te kullanılıyor)
import '../../utils/ikon_donusturucu.dart'; // Chip içindeki ikon için

class TestSonucEkrani extends StatefulWidget {
  final int testId;
  const TestSonucEkrani({super.key, required this.testId});

  @override
  State<TestSonucEkrani> createState() => _TestSonucEkraniState();
}

class _TestSonucEkraniState extends State<TestSonucEkrani> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final testProvider = Provider.of<TestProvider>(context, listen: false);
       await testProvider.testiBitir(widget.testId);
       if (testProvider.kazanilanRozetler.isNotEmpty && mounted) {
          Provider.of<ProfilProvider>(context, listen: false).kullaniciProfiliniGetir();
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    final testProvider = Provider.of<TestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucunuz'), // const eklendi
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(testProvider),
    );
  }

  Widget _buildBody(TestProvider provider) {
    if (provider.testSonucuYukleniyor && provider.sonucPuan == null) {
      return const Center(child: CircularProgressIndicator());
    }
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
    if (provider.sonucPuan == null) {
      return Center(
        child: Text('Test sonucu hesaplanamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    double puan = double.tryParse(provider.sonucPuan!) ?? 0.0;
    bool basarili = puan >= 80;
    int dogruSayisi = 0;
    int yanlisSayisi = 0;
    int toplamSoru = provider.testSorulariModel?.sorular.length ?? 0;

    if (provider.testSorulariModel != null) {
       for (var soru in provider.testSorulariModel!.sorular) {
          int? kullaniciCevapId = provider.verilenCevaplar[soru.soruId];
          if (kullaniciCevapId != null) {
            bool soruDogruMu = false;
            for (var cevap in soru.cevaplar) {
              if (cevap.cevapId == kullaniciCevapId && cevap.dogruMu) {
                soruDogruMu = true;
                break;
              }
            }
            if (soruDogruMu) {dogruSayisi++;} else {yanlisSayisi++;} // Düzeltildi: curly braces
          } else {
            yanlisSayisi++;
          }
        }
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            basarili ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied_rounded,
            color: basarili ? Renkler.basariRengi : Renkler.hataRengi,
            size: 90,
          ),
          const SizedBox(height: 20),
          Text(
            basarili ? 'Harika İş Çıkardın!' : 'Biraz Daha Çalışmalısın',
            style: MetinStilleri.ekranBasligi.copyWith(color: basarili ? Renkler.basariRengi : Renkler.hataRengi),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Puanınız: ${provider.sonucPuan}%',
            style: MetinStilleri.ekranBasligi.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if(toplamSoru > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '$toplamSoru sorudan $dogruSayisi doğru, $yanlisSayisi yanlış.',
              style: MetinStilleri.govdeMetniIkincil,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),

          if (provider.kazanilanRozetler.isNotEmpty) ...[
            Text(
              'Yeni Rozetler Kazandın!',
              style: MetinStilleri.altBaslik.copyWith(color: Renkler.yardimciRenk, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0,
              runSpacing: 12.0,
              children: provider.kazanilanRozetler.map((rozet) {
                return Chip(
                  avatar: Icon(
                    IkonDonusturucu.getIconData(rozet.rozetIconAdi),
                    color: Renkler.yardimciRenk,
                  ),
                  label: Text(rozet.rozetAdi, style: MetinStilleri.govdeMetni),
                  backgroundColor: Renkler.yardimciRenk.withAlpha((0.15 * 255).round()),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
          ],

          ElevatedButton.icon(
            icon: const Icon(Icons.home_outlined),
            label: const Text('Ana Sayfaya Dön'),
            onPressed: () {
               Provider.of<TestProvider>(context, listen: false).testiSifirla();
               Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(1);
               Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AnaSayfaYoneticisi()),
                  (Route<dynamic> route) => false,
                );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.person_outline),
            label: const Text('Profilime Git'),
            onPressed: () {
              Provider.of<TestProvider>(context, listen: false).testiSifirla();
              Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(3);
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