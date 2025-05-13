import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providerlar/egitim_detay_provider.dart';
import '../../modeller/egitim_detay_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../sabitler/api_sabitleri.dart';
import 'egitim_tamamlama_ekrani.dart';

class EgitimDetayEkrani extends StatefulWidget {
  final int egitimId;
  final String egitimAdi;
  final int testId;

  const EgitimDetayEkrani({
    super.key,
    required this.egitimId,
    required this.egitimAdi,
    required this.testId,
  });

  @override
  State<EgitimDetayEkrani> createState() => _EgitimDetayEkraniState();
}

class _EgitimDetayEkraniState extends State<EgitimDetayEkrani> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    print('[EgitimDetayEkrani] initState çağrıldı. Egitim ID: ${widget.egitimId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EgitimDetayProvider>(context, listen: false)
          .egitimDetayiniGetir(widget.egitimId);
    });
  }

  @override
  void dispose() {
    print('[EgitimDetayEkrani] dispose çağrıldı.');
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final egitimDetayProvider = Provider.of<EgitimDetayProvider>(context);
    print('[EgitimDetayEkrani] build çağrıldı. isLoading: ${egitimDetayProvider.isLoading}, Adım Sayısı: ${egitimDetayProvider.egitimDetay?.adimlar.length ?? "Detay Yok"}');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.egitimAdi, style: MetinStilleri.appBarBaslik),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi),
          onPressed: () {
            Provider.of<EgitimDetayProvider>(context, listen: false).resetAdim();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildBody(egitimDetayProvider, context),
      bottomNavigationBar: egitimDetayProvider.egitimDetay != null &&
                             !egitimDetayProvider.isLoading &&
                             egitimDetayProvider.egitimDetay!.adimlar.isNotEmpty
          ? _buildBottomButton(egitimDetayProvider, context)
          : null,
    );
  }

  Widget _buildBody(EgitimDetayProvider provider, BuildContext context) {
    if (provider.isLoading && provider.egitimDetay == null) { // Sadece ilk yüklemede ve detay yokken
      print('[EgitimDetayEkrani] _buildBody: Yükleniyor...');
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hataMesaji != null && provider.egitimDetay == null) {
      print('[EgitimDetayEkrani] _buildBody: Hata Mesajı: ${provider.hataMesaji}');
      return Center( /* ... Hata mesajı ... */ );
    }

    if (provider.egitimDetay == null || provider.egitimDetay!.adimlar.isEmpty) {
      print('[EgitimDetayEkrani] _buildBody: Eğitim adımları bulunamadı veya detay null.');
      return Center(
        child: Text('Eğitim adımları yükleniyor veya bulunamadı...', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    print('[EgitimDetayEkrani] _buildBody: PageView oluşturuluyor. Adım sayısı: ${provider.egitimDetay!.adimlar.length}');
    return Column(
      children: [
        if (provider.egitimDetay!.adimlar.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible( // Uzun eğitim adları için
                  child: Text(
                    widget.egitimAdi,
                    style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Adım ${provider.mevcutAdimIndex + 1}/${provider.egitimDetay!.adimlar.length}',
                  style: MetinStilleri.kucukMetin.copyWith(color: Renkler.vurguRenk),
                ),
              ],
            ),
          ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: provider.egitimDetay!.adimlar.length,
            onPageChanged: (index) {
              provider.setMevcutAdimIndexFromPageView(index);
            },
            itemBuilder: (context, index) {
              final EgitimAdimModel adim = provider.egitimDetay!.adimlar[index];
              print('[EgitimDetayEkrani] PageView itemBuilder: Adım $index oluşturuluyor.');
              return _buildAdimSayfasi(adim, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdimSayfasi(EgitimAdimModel adim, BuildContext context) {
    // ... (Bu metodun içeriği önceki YAML'daki gibi kalabilir, loglar eklenmişti)
    // Sadece emin olmak için:
    String tamFotografPath = ApiSabitleri.kokUrl.replaceAll('/api/', '');
    if (adim.adimFotograf != null && adim.adimFotograf!.isNotEmpty) {
      String gelenYol = adim.adimFotograf!;
      if (gelenYol.startsWith('/images/')) {
        String duzeltilmisYol = gelenYol.replaceFirst('/images/', '/images/egitim_adimlari/');
        tamFotografPath += duzeltilmisYol;
      } else if (gelenYol.startsWith('/')) {
          tamFotografPath += gelenYol;
      } else {
          tamFotografPath += '/images/egitim_adimlari/$gelenYol';
      }
    } else {
      tamFotografPath = '';
    }

    return SingleChildScrollView( /* ... (içerik aynı) ... */ );
  }

  Widget _buildBottomButton(EgitimDetayProvider provider, BuildContext context) {
    // Bu metodun içeriği de önceki YAML'daki gibi, sadece provider.sonAdimdaMi getter'ını kullanacak
    // bool sonAdim = provider.sonAdimdaMi; // getter ile
    // ... (içerik aynı)
    // Sadece PageView senkronizasyonu için sonrakiAdimaGec() çağrısından sonra:
    // if (!provider.sonAdimdaMi && _pageController.hasClients) { // Artık provider.sonAdimdaMi getter
    //    _pageController.animateToPage(
    //       provider.mevcutAdimIndex, // Provider zaten güncellendi
    //       duration: const Duration(milliseconds: 300),
    //       curve: Curves.easeInOut,
    //    );
    // }
    // --- Yukarıdaki PageController güncellemesi EgitimDetayProvider'daki sonrakiAdimaGec içinden
    // --- veya buradaki PageView onPageChanged ile zaten hallediliyor.
    // --- Tekrar kontrol: Buton provider'daki index'i, PageView provider'daki index'i güncelliyor.
    // --- Butona basıldığında provider'daki index değişir, UI yeniden çizilir, PageView yeni index'e atlar.
    // --- PageView kaydırıldığında provider'daki index değişir, UI yeniden çizilir, buton metni güncellenir.
    // --- Bu yüzden _pageController.animateToPage burada gerekli değil.
    // --- Sadece EgitimDetayProvider'daki sonrakiAdimaGec metodunda _mevcutAdimIndex güncellenmeli
    // --- ve PageView onPageChanged'de provider'daki setMevcutAdimIndexFromPageView çağrılmalı.

    // Önceki kod doğruydu, sadece sonAdimdaMi getter'ını kullanacak şekilde teyit:
    bool sonAdim = provider.sonAdimdaMi;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration( /* ... */ ),
      child: ElevatedButton(
        onPressed: () {
          if (sonAdim) { // provider.sonAdimdaMi getter'ı kullanılacak
            Provider.of<EgitimDetayProvider>(context, listen: false).resetAdim();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => EgitimTamamlamaEkrani(
                  egitimAdi: widget.egitimAdi,
                  testId: widget.testId,
                ),
              ),
            );
          } else {
            provider.sonrakiAdimaGec(); // Bu _mevcutAdimIndex'i artırır
            // PageView'in bu değişikliğe tepki vermesi için _pageController'ı da hareket ettirmemiz gerekebilir.
            // Eğer PageView onPageChanged provider'ı güncelliyorsa, ve buton provider'ı güncelliyorsa,
            // _pageController'ı burada manuel hareket ettirmek çift güncellemeye yol açabilir.
            // En iyisi: Buton provider'ı güncellesin. PageView onPageChanged de provider'ı güncellesin.
            // _pageController.animateToPage provider.mevcutAdimIndex'e gitmeli.
             if (_pageController.hasClients) {
               _pageController.animateToPage(
                 provider.mevcutAdimIndex, // provider.sonrakiAdimaGec() ile güncellenen index
                 duration: const Duration(milliseconds: 400),
                 curve: Curves.easeOutQuad,
               );
             }
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: sonAdim ? Renkler.yardimciRenk : Renkler.vurguRenk,
        ),
        child: Text(
          sonAdim ? 'Eğitimi Bitir' : 'Sonraki Adım',
          style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi),
        ),
      ),
    );
  }
}