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
  final PageController _pageController = PageController(); // Adımlar arası geçiş için

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EgitimDetayProvider>(context, listen: false)
          .egitimDetayiniGetir(widget.egitimId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final egitimDetayProvider = Provider.of<EgitimDetayProvider>(context);

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
      // PageView kullanıyorsak, butonları body içine veya sabit bir alta alabiliriz.
      // Şimdilik mevcut buton yapısını koruyalım, gerekirse PageView'a göre düzenleriz.
      bottomNavigationBar: egitimDetayProvider.egitimDetay != null && !egitimDetayProvider.isLoading
          ? _buildBottomButton(egitimDetayProvider, context)
          : null,
    );
  }

  Widget _buildBody(EgitimDetayProvider provider, BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hataMesaji != null) {
      return Center( /* ... Hata mesajı ... */ );
    }

    if (provider.egitimDetay == null || provider.egitimDetay!.adimlar.isEmpty) {
      return Center( /* ... Adım bulunamadı ... */ );
    }

    // PageView ile adımlar arasında kaydırmalı geçiş
    return Column(
      children: [
        if (provider.egitimDetay!.adimlar.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.egitimAdi,
                  style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.w600),
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
              // Provider'daki mevcut adımı güncellemek yerine doğrudan index'i kullanabiliriz
              // veya provider'da bir `setMevcutAdimIndex(index)` metodu oluşturabiliriz.
              // Şimdilik butonlarla senkronize olması için provider'ı güncelleyelim.
              // Ancak bu, butonlara basınca PageView'ı da hareket ettirmemizi gerektirir.
              // Daha basit bir yaklaşım için, _pageController.jumpToPage kullanmak.
              // Şimdilik provider'ı güncellemeyelim, butonlar _pageController'ı yönetsin.
            },
            itemBuilder: (context, index) {
              final EgitimAdimModel adim = provider.egitimDetay!.adimlar[index];
              return _buildAdimSayfasi(adim, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdimSayfasi(EgitimAdimModel adim, BuildContext context) {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0), // Daha ferah padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tamFotografPath.isNotEmpty)
            AspectRatio( // Resim için sabit en-boy oranı
              aspectRatio: 16 / 10, // veya 4/3
              child: Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Placeholder arkaplanı
                  borderRadius: BorderRadius.circular(12.0), // Yumuşak köşeler
                  // border: Border.all(color: Colors.grey[300]!) // İsteğe bağlı çerçeve
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
                          fit: BoxFit.contain, // Veya cover, içeriğe göre
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey[350]));
                          }
                        ),
                ),
              ),
            )
          else if (adim.adimFotograf != null && adim.adimFotograf!.isNotEmpty)
            Container( /* ... Resim yüklenemedi mesajı ... */ )
          else
            const SizedBox(height: 20), // Fotoğraf yoksa boşluk

          if (adim.adimAciklama != null && adim.adimAciklama!.isNotEmpty)
            Text(
              adim.adimAciklama!,
              style: MetinStilleri.govdeMetni.copyWith(fontSize: 16.5, height: 1.6, color: Renkler.anaMetinRengi), // Daha okunaklı
              textAlign: TextAlign.left, // Sola dayalı daha iyi okunur
            )
          else
             Text("Bu adım için açıklama bulunmamaktadır.", style: MetinStilleri.govdeMetniIkincil),
          const SizedBox(height: 60), // Buton için altta boşluk
        ],
      ),
    );
  }

  Widget _buildBottomButton(EgitimDetayProvider provider, BuildContext context) {
    bool sonAdim = provider.mevcutAdimIndex == (provider.egitimDetay!.adimlar.length - 1);

    return Container( // Butonu daha belirgin yapmak için Container
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Renkler.kartArkaPlanRengi, // Tema'dan
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: () {
          if (sonAdim) {
            Provider.of<EgitimDetayProvider>(context, listen: false).resetAdim(); // Provider'ı sıfırla
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
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
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
