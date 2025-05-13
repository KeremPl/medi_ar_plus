import 'package:flutter/material.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../providerlar/egitim_provider.dart'; // Eğitimleri listelemek için
import 'package:provider/provider.dart';
import '../../modeller/egitim_model.dart';
import 'test_soru_ekrani.dart'; // Teste gitmek için
import '../../utils/ikon_donusturucu.dart';


class TestListesiEkrani extends StatefulWidget {
  const TestListesiEkrani({super.key});

  @override
  State<TestListesiEkrani> createState() => _TestListesiEkraniState();
}

class _TestListesiEkraniState extends State<TestListesiEkrani> {
   @override
  void initState() {
    super.initState();
    // Eğer eğitimler yüklenmemişse veya hata varsa yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final egitimProvider = Provider.of<EgitimProvider>(context, listen: false);
      if (egitimProvider.egitimler.isEmpty || egitimProvider.hataMesaji != null) {
        egitimProvider.egitimleriGetir();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final egitimProvider = Provider.of<EgitimProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Testler'),
      ),
      body: _buildTestListesiBody(egitimProvider, context),
    );
  }

  Widget _buildTestListesiBody(EgitimProvider egitimProvider, BuildContext context) {
    if (egitimProvider.isLoading && egitimProvider.egitimler.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (egitimProvider.hataMesaji != null && egitimProvider.egitimler.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                egitimProvider.hataMesaji!,
                style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => egitimProvider.egitimleriGetir(),
                child: const Text('Tekrar Dene'),
              )
            ],
          ),
        ),
      );
    }

     if (egitimProvider.egitimler.isEmpty && !egitimProvider.isLoading) {
      return Center(
        child: Text('Testler için önce eğitimler yüklenmeli veya test bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    // Eğitimleri alıp her birinin testine yönlendirme yapacak bir liste gösterelim
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: egitimProvider.egitimler.length,
      itemBuilder: (context, index) {
        final egitim = egitimProvider.egitimler[index];
        // API'den testid 0 geliyorsa o eğitimin testi yok varsayalım.
        if (egitim.testId == 0 || egitim.testIconAdi == null) {
          return const SizedBox.shrink(); // Testi olmayan eğitimleri gösterme
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: ListTile(
            leading: Icon(
              IkonDonusturucu.getIconData(egitim.testIconAdi),
              color: Renkler.vurguRenk,
              size: 30,
            ),
            title: Text(egitim.egitimAdi, style: MetinStilleri.kartBasligi),
            subtitle: Text("İlgili Test", style: MetinStilleri.kucukMetin),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TestSoruEkrani(testId: egitim.testId),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
