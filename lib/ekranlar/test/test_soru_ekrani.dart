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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final testProvider = Provider.of<TestProvider>(context, listen: false);
      testProvider.testiSifirla();
      testProvider.testSorulariniGetir(widget.testId);
    });
  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Testten Çıkmak İstiyor Musunuz?'),
          content: const Text('Cevaplarınız kaydedilmeyecek ve testten çıkılacaktır.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Çık', style: TextStyle(color: Renkler.hataRengi)),
            ),
          ],
        );
      },
    );
    if (shouldPop ?? false) {
      Provider.of<TestProvider>(context, listen: false).testiSifirla();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final testProvider = Provider.of<TestProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if(shouldPop && mounted){ Navigator.of(context).pop(); }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(testProvider.testSorulariModel?.testAdi ?? 'Test'),
          leading: IconButton(
            icon: Icon(Icons.close, color: Renkler.ikonRengi),
            onPressed: () async {
               final bool shouldPop = await _onWillPop();
               if(shouldPop && mounted) { Navigator.of(context).pop(); }
            }
          ),
        ),
        body: _buildBody(testProvider, context),
        bottomNavigationBar: testProvider.testSorulariModel != null &&
                             !testProvider.isLoading &&
                             testProvider.testSorulariModel!.sorular.isNotEmpty // Düzeltildi: provider -> testProvider
            ? _buildBottomButton(testProvider, context)
            : null,
      ),
    );
  }

  Widget _buildBody(TestProvider provider, BuildContext context) {
    if (provider.isLoading && provider.testSorulariModel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.hataMesaji != null && provider.testSorulariModel == null) {
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
        child: Text('Bu test için soru bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            'Soru ${provider.mevcutSoruIndex + 1}/${provider.testSorulariModel!.sorular.length}',
            style: MetinStilleri.kucukMetin.copyWith(color: Renkler.anaRenk, fontWeight: FontWeight.bold),
          ),
        ),
        LinearProgressIndicator(
          value: (provider.mevcutSoruIndex + 1) / provider.testSorulariModel!.sorular.length,
          backgroundColor: Renkler.arkaPlanRengi,
          valueColor: AlwaysStoppedAnimation<Color>(Renkler.anaRenk),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: provider.testSorulariModel!.sorular.length,
            onPageChanged: (index) {
               provider.setMevcutSoruIndex(index); // Düzeltildi: provider metodu kullanıldı
            },
            itemBuilder: (context, index) {
              final SoruModel soru = provider.testSorulariModel!.sorular[index];
              return _buildSoruSayfasi(soru, provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSoruSayfasi(SoruModel soru, TestProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            soru.soru,
            style: MetinStilleri.altBaslik.copyWith(fontSize: 19, height: 1.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: soru.cevaplar.length,
            itemBuilder: (context, index) {
              final cevap = soru.cevaplar[index];
              final seciliMi = provider.verilenCevaplar[soru.soruId] == cevap.cevapId;
              return Card(
                elevation: seciliMi ? 3 : 1.5,
                margin: const EdgeInsets.symmetric(vertical: 7.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: seciliMi ? Renkler.vurguRenk : Colors.grey[300]!,
                    width: seciliMi ? 2 : 1,
                  ),
                ),
                child: RadioListTile<int>(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(cevap.cevapMetni, style: MetinStilleri.govdeMetni.copyWith(fontSize: 15.5)),
                  value: cevap.cevapId,
                  groupValue: provider.verilenCevaplar[soru.soruId],
                  onChanged: (value) {
                    if (value != null) {
                      provider.cevapVer(soru.soruId, value);
                    }
                  },
                  activeColor: Renkler.vurguRenk,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              );
            },
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildBottomButton(TestProvider provider, BuildContext context) {
    if (provider.testSorulariModel == null || provider.testSorulariModel!.sorular.isEmpty) {
      return const SizedBox.shrink();
    }

    bool cevapVerildiMi = provider.verilenCevaplar.containsKey(provider.mevcutSoru?.soruId);
    bool sonSoruda = provider.mevcutSoruIndex == (provider.testSorulariModel!.sorular.length - 1);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Renkler.kartArkaPlanRengi,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // withOpacity yerine withAlpha
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: cevapVerildiMi ? () {
          if (sonSoruda) {
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => TestSonucEkrani(testId: widget.testId)),
            );
          } else {
            provider.sonrakiSoruyaGec();
            if (_pageController.hasClients && _pageController.page?.round() != provider.mevcutSoruIndex) {
              _pageController.animateToPage(
                provider.mevcutSoruIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        } : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: cevapVerildiMi ? Renkler.vurguRenk : Colors.grey[400],
        ),
        child: Text(
          sonSoruda ? 'Testi Bitir' : 'Sonraki Soru',
           style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi),
        ),
      ),
    );
  }
}
