import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/test_provider.dart';
import '../../modeller/soru_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import 'test_sonuc_ekrani.dart';

class TestSoruEkrani extends StatefulWidget {
  final int testId;

  const TestSoruEkrani({super.key, required this.testId});

  @override
  State<TestSoruEkrani> createState() => _TestSoruEkraniState();
}

class _TestSoruEkraniState extends State<TestSoruEkrani> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final testProvider = Provider.of<TestProvider>(context, listen: false);
      testProvider.testiSifirla();
      testProvider.testSorulariniGetir(widget.testId);
    });
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Testten Çıkmak İstiyor Musunuz?'),
        content: const Text('Cevaplarınız kaydedilmeyecek ve testten çıkılacaktır.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Çık', style: TextStyle(color: Renkler.hataRengi)), // Düzeltildi: const kaldırıldı
          ),
        ],
      ),
    );
    if (shouldPop ?? false) {
      Provider.of<TestProvider>(context, listen: false).testiSifirla();
      return true; // Geri gitmeye izin ver
    }
    return false; // Geri gitmeyi engelle
  }

  @override
  Widget build(BuildContext context) {
    final testProvider = Provider.of<TestProvider>(context);

    return PopScope(
      canPop: false, // _onWillPop ile manuel yönetilecek
      onPopInvokedWithResult: (bool didPop, dynamic result) async { // Düzeltildi
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if(shouldPop && mounted){
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(testProvider.testSorulariModel?.testAdi ?? 'Test Yükleniyor...'),
          leading: IconButton(
            icon: Icon(Icons.close, color: Renkler.ikonRengi),
            onPressed: () async {
               final bool shouldPop = await _onWillPop();
               if(shouldPop && mounted) {
                  Navigator.pop(context);
               }
            }
          ),
        ),
        body: _buildBody(testProvider, context),
        bottomNavigationBar: testProvider.testSorulariModel != null && !testProvider.isLoading
            ? _buildBottomButton(testProvider, context)
            : null,
      ),
    );
  }

  Widget _buildBody(TestProvider provider, BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hataMesaji != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.hataMesaji!,
                style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.testSorulariniGetir(widget.testId),
                child: const Text('Tekrar Dene'),
              )
            ],
          ),
        ),
      );
    }

    if (provider.testSorulariModel == null || provider.testSorulariModel!.sorular.isEmpty) {
      return Center(
        child: Text('Test soruları bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    final SoruModel? mevcutSoru = provider.mevcutSoru;
    if (mevcutSoru == null) {
      return Center(child: Text('Mevcut soru yüklenemedi.', style: MetinStilleri.govdeMetniIkincil));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Soru ${provider.mevcutSoruIndex + 1} / ${provider.testSorulariModel!.sorular.length}',
                style: MetinStilleri.kucukMetin.copyWith(color: Renkler.vurguRenk, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                mevcutSoru.soru,
                style: MetinStilleri.altBaslik.copyWith(height: 1.4),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mevcutSoru.cevaplar.length,
              itemBuilder: (context, index) {
                final cevap = mevcutSoru.cevaplar[index];
                final seciliMi = provider.verilenCevaplar[mevcutSoru.soruId] == cevap.cevapId;
                return Card(
                  color: seciliMi ? Renkler.vurguRenk.withAlpha((0.1 * 255).round()) : Renkler.kartArkaPlanRengi, // Düzeltildi
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: RadioListTile<int>(
                    title: Text(cevap.cevapMetni, style: MetinStilleri.govdeMetni),
                    value: cevap.cevapId,
                    groupValue: provider.verilenCevaplar[mevcutSoru.soruId],
                    onChanged: (value) {
                      if (value != null) {
                        provider.cevapVer(mevcutSoru.soruId, value);
                      }
                    },
                    activeColor: Renkler.vurguRenk,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(TestProvider provider, BuildContext context) {
    bool cevapVerildiMi = provider.verilenCevaplar.containsKey(provider.mevcutSoru?.soruId);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: cevapVerildiMi ? () {
          if (provider.sonSorudaMi) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TestSonucEkrani(testId: widget.testId),
              ),
            );
          } else {
            provider.sonrakiSoruyaGec();
          }
        } : null, // Cevap verilmediyse buton pasif
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Renkler.vurguRenk,
        ),
        child: Text(
          provider.sonSorudaMi ? 'Testi Bitir' : 'Sonraki Soru',
        ),
      ),
    );
  }
}