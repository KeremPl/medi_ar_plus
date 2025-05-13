import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/test_provider.dart';
import '../../providerlar/profil_provider.dart';
import '../../providerlar/navigasyon_provider.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../utils/ikon_donusturucu.dart';
import '../ana_sayfa_yonetici.dart';
// import '../profil/profil_ekrani.dart'; // ProfilEkrani'na direkt gitmek yerine AnaSayfa üzerinden

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
        title: const Text('Test Sonucu'),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(testProvider),
    );
  }

  Widget _buildBody(TestProvider provider) {
    if (provider.testSonucuYukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hataMesaji != null) {
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            basarili ? Icons.emoji_events_outlined : Icons.sentiment_dissatisfied_outlined,
            color: basarili ? Renkler.basariRengi : Renkler.uyariRengi,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            basarili ? 'Tebrikler!' : 'Daha İyi Olabilirdi',
            style: MetinStilleri.ekranBasligi.copyWith(color: basarili ? Renkler.basariRengi : Renkler.uyariRengi),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Puanınız: ${provider.sonucPuan}%',
            style: MetinStilleri.altBaslik.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          if (provider.kazanilanRozetler.isNotEmpty) ...[
            Text(
              'Kazanılan Rozetler:',
              style: MetinStilleri.altBaslik.copyWith(color: Renkler.yardimciRenk),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 24),
          ],

          ElevatedButton(
            onPressed: () {
               Provider.of<TestProvider>(context, listen: false).testiSifirla();
               // Eğitimler sekmesi artık index 1
               Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(1);
               Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AnaSayfaYoneticisi()),
                  (Route<dynamic> route) => false,
                );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Ana Sayfaya Dön'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Provider.of<TestProvider>(context, listen: false).testiSifirla();
              // Profil sekmesi artık index 3
              Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(3);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AnaSayfaYoneticisi()),
                  (Route<dynamic> route) => false,
                );
            },
            child: Text('Profilime Git', style: MetinStilleri.linkMetni),
          ),
        ],
      ),
    );
  }
}