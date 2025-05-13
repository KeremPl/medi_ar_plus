import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/egitim_provider.dart';
import '../../modeller/egitim_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../utils/ikon_donusturucu.dart';
import 'test_soru_ekrani.dart';

class TestListesiEkrani extends StatefulWidget {
  const TestListesiEkrani({super.key});

  @override
  State<TestListesiEkrani> createState() => _TestListesiEkraniState();
}

class _TestListesiEkraniState extends State<TestListesiEkrani> {
  @override
  void initState() {
    super.initState();
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
        title: Text('Test Merkezi', style: MetinStilleri.appBarBaslik), // ar_medic
      ),
      body: _buildTestListesiBody(egitimProvider, context),
    );
  }

  Widget _buildTestListesiBody(EgitimProvider egitimProvider, BuildContext context) {
    if (egitimProvider.isLoading && egitimProvider.egitimler.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (egitimProvider.hataMesaji != null && egitimProvider.egitimler.isEmpty) {
      return Center( /* ... Hata mesajı ... */ );
    }

    if (egitimProvider.egitimler.isEmpty && !egitimProvider.isLoading) {
      return Center( /* ... Test bulunamadı ... */ );
    }

    // Sadece testi olan eğitimleri filtrele
    final List<EgitimModel> testliEgitimler =
        egitimProvider.egitimler.where((e) => e.testId != 0 && e.testIconAdi != null).toList();

    if (testliEgitimler.isEmpty && !egitimProvider.isLoading) {
       return Center(
        child: Text('Uygun test bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    // ar_medic'teki gibi ekran genişliğine göre GridView ayarları
    final double ekranGenisligi = MediaQuery.of(context).size.width;
    final double kutuGenisligi = (ekranGenisligi / 2) - 24; // 16 padding + 16/2 spacing
    final double kutuYuksekligi = kutuGenisligi * 0.85; // ar_medic TestSecimKutusu'na benzer oran

    return GridView.builder(
      padding: const EdgeInsets.all(16.0), // ar_medic
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // ar_medic
        crossAxisSpacing: 16.0, // ar_medic
        mainAxisSpacing: 16.0, // ar_medic
        childAspectRatio: kutuGenisligi / kutuYuksekligi, // ar_medic
      ),
      itemCount: testliEgitimler.length,
      itemBuilder: (context, index) {
        final egitim = testliEgitimler[index];
        return TestSecimKarti( // Yeni widget
          konu: egitim.egitimAdi, // Test adı yerine eğitim adı
          iconAdi: egitim.testIconAdi!, // Null olamaz (yukarıda filtrelendi)
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TestSoruEkrani(testId: egitim.testId),
              ),
            );
          },
        );
      },
    );
  }
}

// "ar_medic" projesindeki TestSecimKutusu'na benzer bir widget
class TestSecimKarti extends StatelessWidget {
  final String konu;
  final String iconAdi;
  final VoidCallback onTap;

  const TestSecimKarti({
    super.key,
    required this.konu,
    required this.iconAdi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final IconData ikon = IkonDonusturucu.getIconData(iconAdi);
    final Color ikonRengi = Renkler.anaRenk; // Testler için ana renk

    return Card( // ar_medic stili
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Renkler.anaRenk.withAlpha(70), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        splashColor: Renkler.anaRenk.withAlpha(30),
        highlightColor: Renkler.anaRenk.withAlpha(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ikon,
                size: 35.0, // ar_medic'teki gibi
                color: ikonRengi,
              ),
              const SizedBox(height: 10.0), // Biraz daha fazla boşluk
              Text(
                konu,
                style: MetinStilleri.govdeMetni.copyWith(fontWeight: FontWeight.w500), // ar_medic
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
