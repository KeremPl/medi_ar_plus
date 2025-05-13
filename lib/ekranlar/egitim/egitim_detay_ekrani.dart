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
    print('[EgitimDetayEkrani] build çağrıldı. isLoading: ${egitimDetayProvider.isLoading}, Adım Sayısı: ${egitimDetayProvider.egitimDetay?.adimlar.length ?? "Detay Yok"}, Mevcut Adım Index: ${egitimDetayProvider.mevcutAdimIndex}');

    return Scaffold(
      appBar: AppBar( /* ... AppBar kodu aynı ... */ ),
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
      return Center( /* ... Hata mesajı ... */ );
    }
    if (provider.egitimDetay == null || provider.egitimDetay!.adimlar.isEmpty) {
      print('[EgitimDetayEkrani] _buildBody: Eğitim adımları bulunamadı veya detay null.');
      return Center( /* ... Eğitim adımları bulunamadı ... */ );
    }
    print('[EgitimDetayEkrani] _buildBody: PageView oluşturuluyor. Adım sayısı: ${provider.egitimDetay!.adimlar.length}. Mevcut Index: ${provider.mevcutAdimIndex}');
    if (_pageController.hasClients && _pageController.page?.round() != provider.mevcutAdimIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if(_pageController.hasClients) {
               _pageController.jumpToPage(provider.mevcutAdimIndex);
          }
      });
    }
    return Column( /* ... Column içeriği aynı ... */ );
  }

  Widget _buildAdimSayfasi(EgitimAdimModel adim, BuildContext context) {
    String tamFotografPath = ApiSabitleri.kokUrl.replaceAll('/api/', ''); // "http://workwatchpro.xyz"

    if (adim.adimFotograf != null && adim.adimFotograf!.isNotEmpty) {
      String gelenYol = adim.adimFotograf!;
      
      if (gelenYol.startsWith('/images/egitim_adimlari/')) {
        // Eğer zaten doğru formatta geliyorsa (örn: /images/egitim_adimlari/kalp_masaji/1.png)
        tamFotografPath += gelenYol;
      } else if (gelenYol.startsWith('/images/')) {
        // Eğer sadece "/images/KONU/resim.png" formatında geliyorsa (örn: /images/yanik/1.png)
        String duzeltilmisYol = gelenYol.replaceFirst('/images/', '/images/egitim_adimlari/');
        tamFotografPath += duzeltilmisYol;
      } else if (gelenYol.startsWith('/')) { 
          // Başka bir / ile başlayan yol (beklenmedik ama genel fallback)
          tamFotografPath += gelenYol; 
      } else { 
          // Hiç / ile başlamıyorsa, tam yolu oluşturmaya çalış (en kötü senaryo)
          // Bu durumda API'den gelen yolun sadece "konu_klasoru/resim.png" gibi olduğunu varsayıyoruz.
          tamFotografPath += '/images/egitim_adimlari/$gelenYol';
      }
    } else {
      tamFotografPath = '';
    }
    print('[EgitimDetayEkrani] _buildAdimSayfasi - Adım: ${adim.adimSira}, Oluşturulan Foto URL: $tamFotografPath');

    return Padding( /* ... Padding ve içindeki Column yapısı aynı ... */ );
  }

  Widget _buildBottomButton(EgitimDetayProvider provider, BuildContext context) {
    // ... (Bu metodun içeriği önceki YAML'daki gibi kalabilir) ...
    // Sadece Flutter formatına uygun olması için içeriği tekrar ekliyorum.
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
                 curve: Curves.easeOutCubic,
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