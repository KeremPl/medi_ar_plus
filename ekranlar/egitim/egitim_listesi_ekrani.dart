// Flutter materyal tasarım kütüphanesini, Provider paketini ve SVG görüntüleme paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG formatındaki resimleri göstermek için.
// Uygulama içi provider'ları, modelleri, sabitleri ve yardımcı sınıfları import eder.
import '../../providerlar/egitim_provider.dart';
import '../../modeller/egitim_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../sabitler/api_sabitleri.dart'; // Resim URL'lerini oluşturmak için.
import '../../utils/ikon_donusturucu.dart'; // String ikon adlarını IconData'ya çevirmek için.
import 'egitim_detay_ekrani.dart'; // Bir eğitime tıklandığında yönlendirilecek ekran.
// Kategori ekranı için import (gelecekte eklenebilir, şimdilik yorum satırı).
// import '../kategori/kategoriler_ekrani.dart';

/// [EgitimListesiEkrani], mevcut tüm eğitimleri bir grid (ızgara) yapısında listeleyen
/// ve kullanıcıların bir eğitimi seçerek detaylarına gitmesini sağlayan arayüzü sunar.
/// Bu bir `StatefulWidget`'tır çünkü `initState` içinde veri çekme işlemi başlatılır.
class EgitimListesiEkrani extends StatefulWidget {
  /// Constructor.
  const EgitimListesiEkrani({super.key});

  /// Bu widget için state nesnesini oluşturur.
  @override
  State<EgitimListesiEkrani> createState() => _EgitimListesiEkraniState();
}

/// [EgitimListesiEkrani] için state yönetimini ve UI mantığını içeren sınıf.
class _EgitimListesiEkraniState extends State<EgitimListesiEkrani> {
  /// Widget ilk oluşturulduğunda ve ağaca eklendiğinde çağrılır.
  @override
  void initState() {
    super.initState();
    // `WidgetsBinding.instance.addPostFrameCallback` ile build metodu tamamlandıktan sonra işlem yapılır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final egitimProvider = Provider.of<EgitimProvider>(context, listen: false);
      // Eğer eğitimler henüz yüklenmemişse veya bir hata oluşmuşsa API'den eğitimleri çeker.
      // Bu, ekran her açıldığında gereksiz API çağrılarını engeller, sadece ihtiyaç duyulduğunda veri çekilir.
      if (egitimProvider.egitimler.isEmpty || egitimProvider.hataMesaji != null) {
         egitimProvider.egitimleriGetir();
      }
    });
  }

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    // EgitimProvider'a erişim sağlar (dinleme yaparak, UI güncellemeleri için).
    final egitimProvider = Provider.of<EgitimProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Eğitim Kütüphanesi', style: MetinStilleri.appBarBaslik), // AppBar başlığı.
        // Gelecekte eklenebilecek kategori filtresi veya benzeri bir eylem butonu için yer.
        // actions: [
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
      // Ekranın ana gövdesi. `RefreshIndicator` ile aşağı çekerek yenileme özelliği eklenmiştir.
      body: RefreshIndicator(
        // Yenileme işlemi tetiklendiğinde EgitimProvider üzerinden eğitimleri tekrar çeker.
        onRefresh: () => Provider.of<EgitimProvider>(context, listen: false).egitimleriGetir(),
        color: Renkler.anaRenk, // Yenileme göstergesinin rengi.
        // Gövde içeriğini `_buildBody` metodu ile oluşturur.
        child: _buildBody(egitimProvider, context),
      ),
    );
  }

  /// Ekranın ana gövdesini oluşturan yardımcı metot.
  /// Yükleme durumu, hata durumu ve eğitimlerin varlığına göre farklı UI'lar gösterir.
  Widget _buildBody(EgitimProvider egitimProvider, BuildContext context) {
    // Veri yükleniyorsa ve henüz eğitim listesi boşsa yükleme göstergesi gösterir.
    if (egitimProvider.isLoading && egitimProvider.egitimler.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hata mesajı varsa ve eğitim listesi boşsa hata mesajını gösterir.
    // TODO: Daha kullanıcı dostu bir hata gösterimi implemente edilebilir.
    if (egitimProvider.hataMesaji != null && egitimProvider.egitimler.isEmpty) {
      return Center(child: Text('Hata: ${egitimProvider.hataMesaji} \n Lütfen sayfayı yenileyin.', textAlign: TextAlign.center, style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi),));
    }

    // Eğitim listesi boşsa ve yükleme devam etmiyorsa (veri bulunamadı durumu).
    // TODO: Kullanıcıya "Eğitim bulunamadı." gibi bir mesaj gösterilebilir.
    if (egitimProvider.egitimler.isEmpty && !egitimProvider.isLoading) {
      return Center(child: Text('Gösterilecek eğitim bulunamadı.', style: MetinStilleri.govdeMetniIkincil));
    }

    // Ekran genişliğine göre GridView'daki kartların boyutunu ayarlamak için hesaplamalar.
    final double ekranGenisligi = MediaQuery.of(context).size.width;
    // Her bir kartın genişliği: (Ekran genişliği / 2 sütun) - (Toplam yatay boşluklar / 2)
    // Padding (16*2) + Spacing (16) = 48. Her iki tarafta 24 piksel.
    final double kutuGenisligi = (ekranGenisligi / 2) - 24; // 16 (padding) + 8 (yarım spacing) = 24

    // Eğitimleri GridView içinde listeler.
    return GridView.builder(
      padding: const EdgeInsets.all(16.0), // Grid'in etrafına dolgu.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Yatayda 2 sütun.
        crossAxisSpacing: 16.0, // Sütunlar arası yatay boşluk.
        mainAxisSpacing: 16.0, // Satırlar arası dikey boşluk.
        // Kartların en-boy oranı. Kutu genişliğine göre yüksekliği ayarlar.
        // Yükseklik, genişliğin 1.15 katı olarak ayarlanmış.
        childAspectRatio: kutuGenisligi / (kutuGenisligi * 1.15),
      ),
      itemCount: egitimProvider.egitimler.length, // Toplam eğitim sayısı.
      itemBuilder: (context, index) {
        // Her bir grid öğesi için ilgili eğitimi alır ve `EgitimKarti` widget'ını oluşturur.
        final egitim = egitimProvider.egitimler[index];
        return EgitimKarti(egitim: egitim);
      },
    );
  }
}

/// Tek bir eğitim kartını temsil eden `StatelessWidget`.
/// Eğitimin kapak resmini (SVG), adını ve testinin olup olmadığını gösterir.
/// Tıklandığında eğitim detay ekranına yönlendirir.
class EgitimKarti extends StatelessWidget {
  final EgitimModel egitim; // Bu kartın göstereceği eğitim modeli.

  /// Constructor. Gerekli `egitim` parametresini alır.
  const EgitimKarti({super.key, required this.egitim});

  @override
  Widget build(BuildContext context) {
    // Eğitim kapağının tam URL'sini oluşturur.
    String tamKapakPath = ApiSabitleri.kokUrl.replaceAll('/api/', ''); // Base URL.
    if (egitim.egitimKapakVector != null && egitim.egitimKapakVector!.startsWith('/')) {
       tamKapakPath += egitim.egitimKapakVector!; // '/images/...' şeklinde geliyorsa direkt ekle.
    } else if (egitim.egitimKapakVector != null && egitim.egitimKapakVector!.isNotEmpty) {
       tamKapakPath += '/${egitim.egitimKapakVector!}'; // 'images/...' şeklinde geliyorsa '/' ekleyerek birleştir.
    } else {
      tamKapakPath = ''; // Kapak resmi yoksa boş string.
    }

    // Kartın genel yapısı için Material widget'ı kullanılır.
    // Bu, elevation (gölge) ve borderRadius gibi özellikleri daha iyi kontrol etmeyi sağlar.
    return Material(
      color: Renkler.kartArkaPlanRengi, // Kartın arkaplan rengi (genellikle beyaz).
      borderRadius: BorderRadius.circular(12.0), // Köşeleri yuvarlatılmış.
      elevation: 3.0, // Kartın gölge yüksekliği.
      shadowColor: Colors.grey.withAlpha(70), // Gölge rengi ve şeffaflığı.
      child: InkWell( // Tıklanma efekti (splash) ekler.
        onTap: () {
          // Tıklandığında EgitimDetayEkrani'na yönlendirir.
          // Eğitim ID'si, adı ve test ID'si parametre olarak geçirilir.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EgitimDetayEkrani(
                egitimId: egitim.egitimId,
                egitimAdi: egitim.egitimAdi,
                testId: egitim.testId
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0), // Tıklama efektinin yayılacağı alanın sınırları.
        splashColor: Renkler.anaRenk.withAlpha(30), // Tıklama sırasındaki dalga efekti rengi.
        highlightColor: Renkler.anaRenk.withAlpha(15), // Basılı tutarkenki vurgu rengi.
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Kart içeriğinin etrafına dolgu.
          child: Column( // İçeriği dikey bir sütun halinde düzenler.
            mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortalar.
            crossAxisAlignment: CrossAxisAlignment.center, // Yatayda ortalar.
            children: [
              Expanded( // Resmin esnek bir şekilde yer kaplamasını sağlar.
                child: Container(
                  // SVG resmi yoksa veya yüklenemezse hafif bir arkaplan.
                  // color: Colors.grey[100],
                  padding: const EdgeInsets.all(8.0), // SVG için iç boşluk.
                  child: tamKapakPath.isNotEmpty
                      ? SvgPicture.network( // SVG resmini ağdan yükler.
                          tamKapakPath,
                          fit: BoxFit.contain, // Resmi orantılı olarak sığdırır.
                          placeholderBuilder: (BuildContext context) =>
                              const Center(child: CircularProgressIndicator(strokeWidth: 2.0)), // Yüklenirken gösterilecek.
                          // SVG'ye renk filtresi uygulamak istenirse (örneğin hafif bir renk tonu vermek için):
                          // colorFilter: ColorFilter.mode(Renkler.anaRenk.withAlpha((0.05 * 255).round()), BlendMode.dstATop),
                        )
                      // Kapak resmi yoksa varsayılan bir ikon gösterir.
                      : Icon(IkonDonusturucu.getIconData('school_outline'), size: 70, color: Colors.grey[300]),
                ),
              ),
              const SizedBox(height: 10.0), // Resim ile eğitim adı arasına boşluk.
              // Eğitim adını gösterir.
              Text(
                egitim.egitimAdi,
                style: MetinStilleri.kartBasligi, // Kart başlığı stili.
                textAlign: TextAlign.center, // Metni ortalar.
                maxLines: 2, // Maksimum 2 satır.
                overflow: TextOverflow.ellipsis, // Sığmazsa sonuna "..." ekler.
              ),
              const SizedBox(height: 4.0), // Eğitim adı ile test bilgisi arasına boşluk.
              // Eğer eğitimin bir testi varsa (testId != 0 ve testIconAdi doluysa), test bilgisini gösterir.
              if (egitim.testId != 0 && egitim.testIconAdi != null)
                Row( // Test ikonu ve "Test Mevcut" yazısını yan yana gösterir.
                  mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlanır.
                  mainAxisAlignment: MainAxisAlignment.center, // Yatayda ortalar.
                  children: [
                    Icon( // Test ikonu.
                      IkonDonusturucu.getIconData(egitim.testIconAdi), // İkon adını IconData'ya çevirir.
                      size: 15, // İkon boyutu (daha küçük).
                      color: Renkler.vurguRenk, // Vurgu rengi.
                    ),
                    const SizedBox(width: 4), // İkon ile yazı arasına boşluk.
                    Text(
                      'Test Mevcut',
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
