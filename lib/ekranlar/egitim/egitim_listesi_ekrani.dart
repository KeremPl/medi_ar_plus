import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providerlar/egitim_provider.dart';
import '../../modeller/egitim_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../sabitler/api_sabitleri.dart';
import '../../utils/ikon_donusturucu.dart';
import 'egitim_detay_ekrani.dart';
// Kategori ekranı için import (ar_medic'teki gibi)
// import '../kategori/kategoriler_ekrani.dart'; // Henüz bu ekran yok, sonra eklenebilir

class EgitimListesiEkrani extends StatefulWidget {
  const EgitimListesiEkrani({super.key});

  @override
  State<EgitimListesiEkrani> createState() => _EgitimListesiEkraniState();
}

class _EgitimListesiEkraniState extends State<EgitimListesiEkrani> {
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
        title: Text('Eğitim Kütüphanesi', style: MetinStilleri.appBarBaslik), // ar_medic
        // actions: [ // ar_medic'te kategori butonu vardı, sonra eklenebilir
        //   Padding(
        //     padding: const EdgeInsets.only(right: 8.0),
        //     child: IconButton(
        //       icon: Icon(Icons.category_outlined, color: Renkler.ikonRengi),
        //       tooltip: 'Kategoriler',
        //       onPressed: () {
        //         // Navigator.push(context, MaterialPageRoute(builder: (context) => const KategorilerEkrani()));
        //       },
        //     ),
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<EgitimProvider>(context, listen: false).egitimleriGetir(),
        color: Renkler.anaRenk, // Refresh indicator rengi
        child: _buildBody(egitimProvider, context), // context eklendi
      ),
    );
  }

  Widget _buildBody(EgitimProvider egitimProvider, BuildContext context) { // context eklendi
    if (egitimProvider.isLoading && egitimProvider.egitimler.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (egitimProvider.hataMesaji != null && egitimProvider.egitimler.isEmpty) {
      return Center( /* ... Hata mesajı ... */ );
    }

    if (egitimProvider.egitimler.isEmpty && !egitimProvider.isLoading) {
      return Center( /* ... Eğitim bulunamadı ... */ );
    }

    // ar_medic'teki gibi ekran genişliğine göre GridView ayarları
    final double ekranGenisligi = MediaQuery.of(context).size.width;
    final double kutuGenisligi = (ekranGenisligi / 2) - 24; // 16 padding her iki taraf + 16 spacing/2

    return GridView.builder(
      padding: const EdgeInsets.all(16.0), // ar_medic
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // ar_medic
        crossAxisSpacing: 16.0, // ar_medic
        mainAxisSpacing: 16.0, // ar_medic
        childAspectRatio: kutuGenisligi / (kutuGenisligi * 1.15), // ar_medic'e benzer (oran ayarlanabilir)
      ),
      itemCount: egitimProvider.egitimler.length,
      itemBuilder: (context, index) {
        final egitim = egitimProvider.egitimler[index];
        return EgitimKarti(egitim: egitim); // Aşağıda güncellenecek
      },
    );
  }
}

// EgitimKarti widget'ı "ar_medic" projesindeki "EgitimKutusu"na benzetilecek
class EgitimKarti extends StatelessWidget {
  final EgitimModel egitim;

  const EgitimKarti({super.key, required this.egitim});

  @override
  Widget build(BuildContext context) {
    String tamKapakPath = ApiSabitleri.kokUrl.replaceAll('/api/', '');
    if (egitim.egitimKapakVector != null && egitim.egitimKapakVector!.startsWith('/')) {
       tamKapakPath += egitim.egitimKapakVector!;
    } else if (egitim.egitimKapakVector != null && egitim.egitimKapakVector!.isNotEmpty) {
       tamKapakPath += '/${egitim.egitimKapakVector!}';
    } else {
      tamKapakPath = '';
    }

    // "ar_medic" EgitimKutusu stili
    return Material( // Card yerine Material + elevation + shadowColor
      color: Colors.white, // Tema'dan Renkler.kartArkaPlanRengi
      borderRadius: BorderRadius.circular(12.0),
      elevation: 3.0,
      shadowColor: Colors.grey.withAlpha(70), // Hafif gölge
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EgitimDetayEkrani(egitimId: egitim.egitimId, egitimAdi: egitim.egitimAdi, testId: egitim.testId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        splashColor: Renkler.anaRenk.withAlpha(30),
        highlightColor: Renkler.anaRenk.withAlpha(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Daha az padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded( // Resmi esnek yap
                child: Container(
                  // color: Colors.grey[100], // SVG yoksa placeholder için hafif arkaplan
                  padding: const EdgeInsets.all(8.0), // SVG için iç boşluk
                  child: tamKapakPath.isNotEmpty
                      ? SvgPicture.network(
                          tamKapakPath,
                          fit: BoxFit.contain, // contain daha iyi olabilir
                          placeholderBuilder: (BuildContext context) =>
                              const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                          // colorFilter: ColorFilter.mode(Renkler.anaRenk.withAlpha((0.05 * 255).round()), BlendMode.dstATop),
                        )
                      : Icon(IkonDonusturucu.getIconData('school_outline'), size: 70, color: Colors.grey[300]),
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                egitim.egitimAdi,
                style: MetinStilleri.kartBasligi, // ar_medic'teki kutuBaslik
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              if (egitim.testId != 0 && egitim.testIconAdi != null)
                Row(
                  mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlan
                  children: [
                    Icon(
                      IkonDonusturucu.getIconData(egitim.testIconAdi),
                      size: 15, // Daha küçük ikon
                      color: Renkler.vurguRenk,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Test Mevcut', // "ar_medic"te sadece ikon ve konu adı vardı, bu daha iyi
                      style: MetinStilleri.kucukMetin.copyWith(color: Renkler.vurguRenk),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}