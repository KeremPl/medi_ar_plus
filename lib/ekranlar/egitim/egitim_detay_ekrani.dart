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
    // Provider'ı burada resetlemeye gerek yok, initState'te zaten egitimDetayiniGetir ile sıfırlanıyor.
    // Eğer ekran pop edildiğinde resetlemek isteniyorsa, appBar'daki onPressed içinde yapılıyor.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final egitimDetayProvider = Provider.of<EgitimDetayProvider>(context);
    print('[EgitimDetayEkrani] build çağrıldı. isLoading: ${egitimDetayProvider.isLoading}, Adım Sayısı: ${egitimDetayProvider.egitimDetay?.adimlar.length ?? "Detay Yok"}, Mevcut Adım Index: ${egitimDetayProvider.mevcutAdimIndex}');

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
    if (provider.isLoading && provider.egitimDetay == null) {
      print('[EgitimDetayEkrani] _buildBody: Yükleniyor...');
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hataMesaji != null && provider.egitimDetay == null) {
      print('[EgitimDetayEkrani] _buildBody: Hata Mesajı: ${provider.hataMesaji}');
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(provider.hataMesaji!, textAlign: TextAlign.center, style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi)),
          )
      );
    }

    if (provider.egitimDetay == null || provider.egitimDetay!.adimlar.isEmpty) {
      print('[EgitimDetayEkrani] _buildBody: Eğitim adımları bulunamadı veya detay null.');
      return Center(
        child: Text('Eğitim adımları yükleniyor veya bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    print('[EgitimDetayEkrani] _buildBody: PageView oluşturuluyor. Adım sayısı: ${provider.egitimDetay!.adimlar.length}. Mevcut Index: ${provider.mevcutAdimIndex}');
    if (_pageController.hasClients &&_pageController.page?.round() != provider.mevcutAdimIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if(_pageController.hasClients) {
               _pageController.jumpToPage(provider.mevcutAdimIndex);
          }
      });
    }

    return Column(
      children: [
        if (provider.egitimDetay!.adimlar.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
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
              print('[EgitimDetayEkrani] PageView onPageChanged: index $index');
              provider.setMevcutAdimIndexFromPageView(index);
            },
            itemBuilder: (context, index) {
              final EgitimAdimModel adim = provider.egitimDetay!.adimlar[index];
              print('[EgitimDetayEkrani] PageView itemBuilder: Adım $index (${adim.adimSira}) oluşturuluyor.');
              return _buildAdimSayfasi(adim, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdimSayfasi(EgitimAdimModel adim, BuildContext context) {
    String tamFotografPath = ApiSabitleri.kokUrl.replaceAll('/api/', ''); // "http://workwatchpro.xyz"

    if (adim.adimFotograf != null && adim.adimFotograf!.isNotEmpty) {
      String gelenYol = adim.adimFotograf!;
      
      if (gelenYol.startsWith('/images/egitim_adimlari/')) {
        tamFotografPath += gelenYol;
      } else if (gelenYol.startsWith('/images/')) {
        String konuKlasoruVeResim = gelenYol.substring('/images/'.length);
        tamFotografPath += '/images/egitim_adimlari/' + konuKlasoruVeResim;
      } else if (gelenYol.startsWith('/')) { 
          tamFotografPath += gelenYol; 
      } else { 
          tamFotografPath += '/images/egitim_adimlari/' + gelenYol;
      }
    } else {
      tamFotografPath = '';
    }
    print('[EgitimDetayEkrani] _buildAdimSayfasi - Adım: ${adim.adimSira}, Oluşturulan Foto URL: $tamFotografPath');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tamFotografPath.isNotEmpty)
            Expanded(
              flex: 5, // Resim için daha fazla alan
              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: tamFotografPath.toLowerCase().endsWith('.svg')
                      ? SvgPicture.network(
                          tamFotografPath,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) => const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                        )
                      : Image.network(
                          tamFotografPath,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('[EgitimDetayEkrani] Adım ${adim.adimSira} Image.network Yükleme Hatası: $error URL: $tamFotografPath');
                            return Center(child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey[350]));
                          },
                        ),
                ),
              ),
            )
          else if (adim.adimFotograf != null && adim.adimFotograf!.isNotEmpty) // Yol vardı ama tamFotografPath oluşturulamadı
            Expanded(flex: 5, child: Center(child: Text("Resim yüklenemedi.", style: MetinStilleri.kucukMetin.copyWith(color: Renkler.hataRengi))))
          else
            const SizedBox.shrink(), // Fotoğraf yoksa boşluk bırakma, metin yukarı kaysın

          Expanded(
            flex: 4, // Metin için ayrılan alan
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: (adim.adimAciklama != null && adim.adimAciklama!.isNotEmpty)
                    ? Text(
                        adim.adimAciklama!,
                        style: MetinStilleri.govdeMetni.copyWith(fontSize: 17, height: 1.65, color: Renkler.anaMetinRengi),
                        textAlign: TextAlign.left,
                      )
                    : Center(child: Text("Bu adım için açıklama bulunmamaktadır.", style: MetinStilleri.govdeMetniIkincil)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(EgitimDetayProvider provider, BuildContext context) {
    bool sonAdim = provider.sonAdimdaMi;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Renkler.kartArkaPlanRengi,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: () {
          if (sonAdim) {
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
            provider.sonrakiAdimaGec();
            if (_pageController.hasClients) {
               _pageController.animateToPage(
                 provider.mevcutAdimIndex,
                 duration: const Duration(milliseconds: 350),
                 curve: Curves.easeOutCubic, // Daha yumuşak bir geçiş
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