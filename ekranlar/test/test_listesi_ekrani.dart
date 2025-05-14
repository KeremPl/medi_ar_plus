// Flutter materyal tasarım kütüphanesini ve Provider paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Uygulama içi provider'ları, modelleri, sabitleri ve yardımcı sınıfları import eder.
import '../../providerlar/egitim_provider.dart'; // Testler eğitimlerle ilişkili olduğu için EğitimProvider kullanılır.
import '../../modeller/egitim_model.dart'; // Testi olan eğitimleri filtrelemek için.
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../utils/ikon_donusturucu.dart'; // String ikon adlarını IconData'ya çevirmek için.
import 'test_soru_ekrani.dart'; // Bir teste tıklandığında yönlendirilecek ekran.

/// [TestListesiEkrani], içerisinde test barındıran eğitimleri (veya direkt testleri)
/// bir grid (ızgara) yapısında listeleyen ve kullanıcıların bir testi seçerek
/// o teste başlamasını sağlayan arayüzü sunar.
/// Bu bir `StatefulWidget`'tır çünkü `initState` içinde veri çekme işlemi (EgitimProvider üzerinden) başlatılır.
class TestListesiEkrani extends StatefulWidget {
  /// Constructor.
  const TestListesiEkrani({super.key});

  /// Bu widget için state nesnesini oluşturur.
  @override
  State<TestListesiEkrani> createState() => _TestListesiEkraniState();
}

/// [TestListesiEkrani] için state yönetimini ve UI mantığını içeren sınıf.
class _TestListesiEkraniState extends State<TestListesiEkrani> {
  /// Widget ilk oluşturulduğunda ve ağaca eklendiğinde çağrılır.
  @override
  void initState() {
    super.initState();
    // `WidgetsBinding.instance.addPostFrameCallback` ile build metodu tamamlandıktan sonra işlem yapılır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final egitimProvider = Provider.of<EgitimProvider>(context, listen: false);
      // Eğer eğitimler (ve dolayısıyla test bilgileri) henüz yüklenmemişse veya bir hata oluşmuşsa
      // API'den eğitimleri (testleri içeren) çeker.
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
        title: Text('Test Merkezi', style: MetinStilleri.appBarBaslik), // AppBar başlığı.
      ),
      // Ekranın ana gövdesini `_buildTestListesiBody` metodu ile oluşturur.
      // TODO: Bu ekrana da RefreshIndicator eklenebilir.
      body: _buildTestListesiBody(egitimProvider, context),
    );
  }

  /// Ekranın ana gövdesini oluşturan yardımcı metot.
  /// Yükleme durumu, hata durumu ve testlerin varlığına göre farklı UI'lar gösterir.
  Widget _buildTestListesiBody(EgitimProvider egitimProvider, BuildContext context) {
    // Veri yükleniyorsa ve henüz eğitim (test) listesi boşsa yükleme göstergesi gösterir.
    if (egitimProvider.isLoading && egitimProvider.egitimler.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hata mesajı varsa ve eğitim (test) listesi boşsa hata mesajını gösterir.
    // TODO: Daha kullanıcı dostu bir hata gösterimi implemente edilebilir.
    if (egitimProvider.hataMesaji != null && egitimProvider.egitimler.isEmpty) {
      return Center(child: Text('Hata: ${egitimProvider.hataMesaji} \n Lütfen sayfayı yenileyin.', textAlign: TextAlign.center, style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi),));
    }

    // Eğitim (test) listesi boşsa ve yükleme devam etmiyorsa (veri bulunamadı durumu).
    if (egitimProvider.egitimler.isEmpty && !egitimProvider.isLoading) {
      return Center(child: Text('Gösterilecek test bulunamadı.', style: MetinStilleri.govdeMetniIkincil));
    }

    // Sadece geçerli bir `testId`'si ve `testIconAdi` olan eğitimleri filtreleyerek test listesini oluşturur.
    final List<EgitimModel> testliEgitimler =
        egitimProvider.egitimler.where((e) => e.testId != 0 && e.testIconAdi != null).toList();

    // Filtrelenmiş test listesi boşsa ve yükleme devam etmiyorsa bilgilendirme mesajı gösterir.
    if (testliEgitimler.isEmpty && !egitimProvider.isLoading) {
       return Center(
        child: Text('Uygun test bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    // Ekran genişliğine göre GridView'daki kartların boyutunu ayarlamak için hesaplamalar.
    final double ekranGenisligi = MediaQuery.of(context).size.width;
    // Her bir kartın genişliği: (Ekran genişliği / 2 sütun) - (Toplam yatay boşluklar / 2)
    // Padding (16*2) + Spacing (16) = 48. Her iki tarafta 24 piksel.
    final double kutuGenisligi = (ekranGenisligi / 2) - 24; // 16 (padding) + 8 (yarım spacing)
    // Kartların yüksekliği, genişliğin 0.85 katı olarak ayarlanmış.
    final double kutuYuksekligi = kutuGenisligi * 0.85;

    // Testleri GridView içinde listeler.
    return GridView.builder(
      padding: const EdgeInsets.all(16.0), // Grid'in etrafına dolgu.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Yatayda 2 sütun.
        crossAxisSpacing: 16.0, // Sütunlar arası yatay boşluk.
        mainAxisSpacing: 16.0, // Satırlar arası dikey boşluk.
        // Kartların en-boy oranı.
        childAspectRatio: kutuGenisligi / kutuYuksekligi,
      ),
      itemCount: testliEgitimler.length, // Toplam test sayısı.
      itemBuilder: (context, index) {
        // Her bir grid öğesi için ilgili eğitimi (testi) alır ve `TestSecimKarti` widget'ını oluşturur.
        final egitim = testliEgitimler[index];
        return TestSecimKarti(
          konu: egitim.egitimAdi, // Testin konusu olarak eğitimin adını kullanır.
          iconAdi: egitim.testIconAdi!, // Null olamaz (yukarıda filtrelendi).
          onTap: () {
            // Tıklandığında TestSoruEkrani'na yönlendirir.
            // `testId` parametresi ile hangi testin açılacağı belirtilir.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TestSoruEkrani(testId: egitim.testId),
              ),
            );
          },
        );
      },
    );
  }
}

/// Tek bir test seçim kartını temsil eden `StatelessWidget`.
/// Testin konusunu (eğitim adını) ve ikonunu gösterir.
/// Tıklandığında ilgili testin soru ekranına yönlendirir.
class TestSecimKarti extends StatelessWidget {
  final String konu; // Testin konusu (genellikle eğitim adı).
  final String iconAdi; // Testin ikonunun string adı.
  final VoidCallback onTap; // Kart tıklandığında çağrılacak fonksiyon.

  /// Constructor. Gerekli parametreleri alır.
  const TestSecimKarti({
    super.key,
    required this.konu,
    required this.iconAdi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // İkon adını Flutter IconData nesnesine çevirir.
    final IconData ikon = IkonDonusturucu.getIconData(iconAdi);
    // Test kartları için varsayılan ikon rengi.
    final Color ikonRengi = Renkler.anaRenk;

    // Kartın genel yapısı için Card widget'ı kullanılır.
    return Card(
      elevation: 2.0, // Kartın gölge yüksekliği.
      shape: RoundedRectangleBorder( // Kartın şekli.
        borderRadius: BorderRadius.circular(10.0), // Köşeleri yuvarlatılmış.
        // Hafif bir kenarlık.
        side: BorderSide(color: Renkler.anaRenk.withAlpha(70), width: 1),
      ),
      clipBehavior: Clip.antiAlias, // İçeriğin kart sınırlarının dışına taşmasını engeller.
      child: InkWell( // Tıklanma efekti ekler.
        onTap: onTap, // Tıklandığında `onTap` callback'ini çağırır.
        borderRadius: BorderRadius.circular(10.0), // Tıklama efektinin yayılacağı alan.
        splashColor: Renkler.anaRenk.withAlpha(30), // Tıklama sırasındaki dalga efekti rengi.
        highlightColor: Renkler.anaRenk.withAlpha(15), // Basılı tutarkenki vurgu rengi.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Kart içeriğinin dolgusu.
          child: Column( // İkon ve konuyu dikey olarak dizer.
            mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortalar.
            children: [
              Icon( // Test ikonu.
                ikon,
                size: 35.0, // İkon boyutu.
                color: ikonRengi,
              ),
              const SizedBox(height: 10.0), // İkon ile konu arasına boşluk.
              // Test konusunu (eğitim adını) gösterir.
              Text(
                konu,
                style: MetinStilleri.govdeMetni.copyWith(fontWeight: FontWeight.w500), // Metin stili.
                textAlign: TextAlign.center, // Metni ortalar.
                maxLines: 2, // Maksimum 2 satır.
                overflow: TextOverflow.ellipsis, // Sığmazsa sonuna "..." ekler.
              ),
            ],
          ),
        ),
      ),
    );
  }
}
