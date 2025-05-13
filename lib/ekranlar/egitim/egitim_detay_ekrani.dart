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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EgitimDetayProvider>(context, listen: false)
          .egitimDetayiniGetir(widget.egitimId);
    });
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
                onPressed: () => provider.egitimDetayiniGetir(widget.egitimId),
                child: const Text('Tekrar Dene'),
              )
            ],
          ),
        ),
      );
    }

    if (provider.egitimDetay == null || provider.egitimDetay!.adimlar.isEmpty) {
      return Center(
        child: Text('Eğitim adımları bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    final EgitimAdimModel? mevcutAdim = provider.mevcutAdim;
    if (mevcutAdim == null) {
      return Center(child: Text('Mevcut adım yüklenemedi.', style: MetinStilleri.govdeMetniIkincil));
    }

    String tamFotografPath = ApiSabitleri.kokUrl.replaceAll('/api/', ''); // "http://workwatchpro.xyz"
    if (mevcutAdim.adimFotograf != null && mevcutAdim.adimFotograf!.isNotEmpty) {
      String gelenYol = mevcutAdim.adimFotograf!; // Örn: "/images/burkulma/1.png"
      
      if (gelenYol.startsWith('/images/')) {
        // "/images/" kısmını "/images/egitim_adimlari/" ile değiştiriyoruz.
        String duzeltilmisYol = gelenYol.replaceFirst('/images/', '/images/egitim_adimlari/');
        tamFotografPath += duzeltilmisYol;
      } else if (gelenYol.startsWith('/')) { 
          // Zaten doğru formatta veya beklenmedik bir / ile başlayan yol
          tamFotografPath += gelenYol; 
      } else { 
          // / ile başlamıyorsa, varsayılan yapıyı oluştur
          tamFotografPath += '/images/egitim_adimlari/$gelenYol';
      }
       print('Oluşturulan Resim URL: $tamFotografPath'); // Kontrol için log
    } else {
      tamFotografPath = '';
       print('Resim yolu boş veya null.'); // Kontrol için log
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (provider.egitimDetay!.adimlar.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Adım ${provider.mevcutAdimIndex + 1} / ${provider.egitimDetay!.adimlar.length}',
                style: MetinStilleri.kucukMetin.copyWith(color: Renkler.vurguRenk, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

          if (tamFotografPath.isNotEmpty)
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[300]!)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.0),
                child: tamFotografPath.toLowerCase().endsWith('.svg')
                    ? SvgPicture.network(
                        tamFotografPath,
                        fit: BoxFit.contain,
                        placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                        // ignore: deprecated_member_use
                        // colorFilter: ColorFilter.mode(Renkler.anaRenk.withAlpha((0.05 * 255).round()), BlendMode.dstATop),
                      )
                    : Image.network(
                        tamFotografPath,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Image.network Yükleme Hatası: $error');
                          print('URL: $tamFotografPath');
                          return Center(child: Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey[400]));
                        }
                      ),
              ),
            )
          else if (mevcutAdim.adimFotograf != null && mevcutAdim.adimFotograf!.isNotEmpty) // Path boş ama API'de yol vardıysa, bu bir placeholder gösterir
            Container( // Fotoğraf yolu vardı ama tamFotografPath oluşturulamadıysa (beklenmedik durum)
               height: MediaQuery.of(context).size.height * 0.1,
               alignment: Alignment.center,
               child: Text("Resim yüklenemedi (hatalı yol formatı olabilir).", style: MetinStilleri.kucukMetin.copyWith(color: Renkler.hataRengi)),
            )
          else // Fotoğraf yoksa boşluk
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),


          if (mevcutAdim.adimAciklama != null && mevcutAdim.adimAciklama!.isNotEmpty)
            Text(
              mevcutAdim.adimAciklama!,
              style: MetinStilleri.govdeMetni.copyWith(fontSize: 16),
              textAlign: TextAlign.justify,
            )
          else
             Text("Bu adım için açıklama bulunmamaktadır.", style: MetinStilleri.govdeMetniIkincil),
        ],
      ),
    );
  }

  Widget _buildBottomButton(EgitimDetayProvider provider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (provider.sonAdimdaMi) {
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
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: provider.sonAdimdaMi ? Renkler.yardimciRenk : Renkler.vurguRenk,
        ),
        child: Text(
          provider.sonAdimdaMi ? 'Eğitimi Bitir' : 'Sonraki Adım',
        ),
      ),
    );
  }
}