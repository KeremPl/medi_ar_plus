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
    final shouldPop = await showDialog<bool>( /* ... (Dialog kodu aynı) ... */ );
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
        if(shouldPop && mounted){ Navigator.pop(context); }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(testProvider.testSorulariModel?.testAdi ?? 'Test'),
          leading: IconButton(
            icon: Icon(Icons.close, color: Renkler.ikonRengi),
            onPressed: () async {
               final bool shouldPop = await _onWillPop();
               if(shouldPop && mounted) { Navigator.pop(context); }
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
    if (provider.isLoading && provider.testSorulariModel == null) { // Sadece ilk yüklemede
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.hataMesaji != null && provider.testSorulariModel == null) {
      return Center( /* ... Hata mesajı ... */ );
    }
    if (provider.testSorulariModel == null || provider.testSorulariModel!.sorular.isEmpty) {
      return Center( /* ... Soru bulunamadı ... */ );
    }

    // PageView ile sorular arası kaydırmalı geçiş
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            'Soru ${provider.mevcutSoruIndex + 1}/${provider.testSorulariModel!.sorular.length}',
            style: MetinStilleri.kucukMetin.copyWith(color: Renkler.anaRenk, fontWeight: FontWeight.bold),
          ),
        ),
        LinearProgressIndicator( // Soru ilerleme barı
          value: (provider.mevcutSoruIndex + 1) / provider.testSorulariModel!.sorular.length,
          backgroundColor: Renkler.arkaPlanRengi,
          valueColor: AlwaysStoppedAnimation<Color>(Renkler.anaRenk),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: provider.testSorulariModel!.sorular.length,
            onPageChanged: (index) {
               // Provider'ı güncellemek yerine butondan yönetelim
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
                  controlAffinity: ListTileControlAffinity.trailing, // Radio butonu sağda
                ),
              );
            },
          ),
          const SizedBox(height: 60), // Buton için altta boşluk
        ],
      ),
    );
  }

  Widget _buildBottomButton(TestProvider provider, BuildContext context) {
    bool cevapVerildiMi = provider.verilenCevaplar.containsKey(provider.mevcutSoru?.soruId);
    bool sonSoruda = provider.mevcutSoruIndex == (provider.testSorulariModel!.sorular.length - 1);

    return Container(
      padding: const EdgeInsets.all(16.0),
       decoration: BoxDecoration( /* ... (Eğitim detaydaki gibi gölgeli kutu) ... */ ),
      child: ElevatedButton(
        onPressed: cevapVerildiMi ? () {
          if (sonSoruda) {
            Provider.of<TestProvider>(context, listen: false).testiSifirla(); // Eski cevapları temizle
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => TestSonucEkrani(testId: widget.testId)),
            );
          } else {
            provider.sonrakiSoruyaGec();
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut,
            );
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
