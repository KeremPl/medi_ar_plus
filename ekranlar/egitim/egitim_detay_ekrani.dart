// Flutter materyal tasarım kütüphanesini, Provider paketini ve SVG görüntüleme paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG formatındaki resimleri göstermek için.
// Uygulama içi provider'ları, modelleri ve sabitleri import eder.
import '../../providerlar/egitim_detay_provider.dart';
import '../../modeller/egitim_detay_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../sabitler/api_sabitleri.dart'; // Resim URL'lerini oluşturmak için.
import 'egitim_tamamlama_ekrani.dart'; // Eğitimi tamamladıktan sonra yönlendirilecek ekran.

/// [EgitimDetayEkrani], seçilen bir eğitimin adımlarını (içerik ve görseller)
/// detaylı bir şekilde gösteren ve kullanıcıların bu adımlar arasında gezinmesini sağlayan
/// bir arayüz sunar.
/// Bu bir `StatefulWidget`'tır çünkü `PageController` gibi state'e bağlı nesneler ve
/// `initState` gibi yaşam döngüsü metotları kullanır.
class EgitimDetayEkrani extends StatefulWidget {
  final int egitimId; // Görüntülenecek eğitimin benzersiz ID'si.
  final String egitimAdi; // AppBar'da gösterilecek eğitimin adı.
  final int testId; // Eğitim tamamlandığında ilgili teste yönlendirmek için test ID'si.

  /// Constructor. Gerekli parametreleri alır.
  const EgitimDetayEkrani({
    super.key,
    required this.egitimId,
    required this.egitimAdi,
    required this.testId,
  });

  /// Bu widget için state nesnesini oluşturur.
  @override
  State<EgitimDetayEkrani> createState() => _EgitimDetayEkraniState();
}

/// [EgitimDetayEkrani] için state yönetimini ve UI mantığını içeren sınıf.
class _EgitimDetayEkraniState extends State<EgitimDetayEkrani> {
  // Eğitim adımları arasında sayfa sayfa geçiş yapmak için kullanılan PageController.
  final PageController _pageController = PageController();

  /// Widget ilk oluşturulduğunda ve ağaca eklendiğinde çağrılır.
  @override
  void initState() {
    super.initState();
    // `WidgetsBinding.instance.addPostFrameCallback` ile build metodu tamamlandıktan sonra
    // (yani widget ağacı oluşturulduktan sonra) işlem yapılması sağlanır.
    // Bu, `initState` içinde context'e bağlı işlemler (Provider gibi) yapmak için güvenli bir yoldur.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // EgitimDetayProvider üzerinden ilgili eğitimin detaylarını API'den çeker.
      // `listen: false` ile bu işlem sırasında provider'ı dinlemeyiz, sadece metot çağırırız.
      Provider.of<EgitimDetayProvider>(context, listen: false)
          .egitimDetayiniGetir(widget.egitimId);
    });
  }

  /// Widget ağaçtan kaldırıldığında çağrılır.
  /// `PageController`'ın dispose edilmesi, olası hafıza sızıntılarını önler.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    // EgitimDetayProvider'a erişim sağlar (dinleme yaparak, UI güncellemeleri için).
    final egitimDetayProvider = Provider.of<EgitimDetayProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.egitimAdi, style: MetinStilleri.appBarBaslik), // AppBar başlığı olarak eğitim adını gösterir.
        leading: IconButton( // Geri butonu.
          icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi),
          onPressed: () {
            // Geri dönmeden önce EgitimDetayProvider'daki state'i sıfırlar.
            // Bu, aynı eğitime tekrar girildiğinde eski verilerin gösterilmesini engeller.
            Provider.of<EgitimDetayProvider>(context, listen: false).resetState();
            Navigator.of(context).pop(); // Bir önceki ekrana döner.
          },
        ),
      ),
      // Ekranın ana gövdesini `_buildBody` metodu ile oluşturur.
      body: _buildBody(egitimDetayProvider, context),
      // Alt navigasyon butonu (Sonraki Adım / Eğitimi Bitir).
      // Sadece eğitim detayı yüklendiyse, yükleme devam etmiyorsa ve en az bir adım varsa gösterilir.
      bottomNavigationBar: egitimDetayProvider.egitimDetay != null &&
                             !egitimDetayProvider.isLoading &&
                             egitimDetayProvider.egitimDetay!.adimlar.isNotEmpty
          ? _buildBottomButton(egitimDetayProvider, context)
          : null, // Koşul sağlanmazsa alt buton gösterilmez.
    );
  }

  /// Ekranın ana gövdesini oluşturan yardımcı metot.
  /// Yükleme durumu, hata durumu ve eğitim adımlarının varlığına göre farklı UI'lar gösterir.
  Widget _buildBody(EgitimDetayProvider provider, BuildContext context) {
    // Veri yükleniyorsa ve henüz eğitim detayı yoksa yükleme göstergesi (CircularProgressIndicator) gösterir.
    if (provider.isLoading && provider.egitimDetay == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hata mesajı varsa ve eğitim detayı yoksa hata mesajını gösterir.
    if (provider.hataMesaji != null && provider.egitimDetay == null) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              provider.hataMesaji!,
              textAlign: TextAlign.center,
              style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi)
            ),
          )
      );
    }

    // Eğitim detayı yüklenememişse veya hiç adım yoksa bilgilendirme mesajı gösterir.
    if (provider.egitimDetay == null || provider.egitimDetay!.adimlar.isEmpty) {
      return Center(
        child: Text(
          'Eğitim adımları yükleniyor veya bulunamadı.',
          style: MetinStilleri.govdeMetniIkincil
        ),
      );
    }

    // PageController'ın mevcut sayfasını provider'daki `mevcutAdimIndex` ile senkronize tutar.
    // Bu, programatik olarak adım değiştirildiğinde PageView'ın da güncellenmesini sağlar.
    // `_pageController.hasClients` kontrolü, PageController'ın bir PageView'a bağlı olup olmadığını kontrol eder.
    if (_pageController.hasClients && _pageController.page?.round() != provider.mevcutAdimIndex) {
      // `addPostFrameCallback` ile bu işlem build döngüsü tamamlandıktan sonra yapılır.
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if(_pageController.hasClients) { // Tekrar kontrol, callback çalıştığında durum değişmiş olabilir.
               _pageController.jumpToPage(provider.mevcutAdimIndex); // Animasyonsuz geçiş.
          }
      });
    }

    // Eğitim adımlarını gösteren ana yapı.
    return Column(
      children: [
        // Eğer birden fazla adım varsa, başlık ve adım sayısını gösteren bir satır ekler.
        if (provider.egitimDetay!.adimlar.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Elemanları satırın iki ucuna yaslar.
              children: [
                Flexible( // Uzun eğitim adlarının taşmasını engellemek için Flexible kullanılır.
                  child: Text(
                    widget.egitimAdi, // Eğitim adı.
                    style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis, // Sığmazsa sonuna "..." ekler.
                  ),
                ),
                Text( // "Adım X/Y" formatında mevcut adım bilgisini gösterir.
                  'Adım ${provider.mevcutAdimIndex + 1}/${provider.egitimDetay!.adimlar.length}',
                  style: MetinStilleri.kucukMetin.copyWith(color: Renkler.vurguRenk),
                ),
              ],
            ),
          ),
        // Eğitim adımlarını sayfa sayfa göstermek için PageView kullanılır.
        Expanded(
          child: PageView.builder(
            controller: _pageController, // Sayfa geçişlerini yönetir.
            itemCount: provider.egitimDetay!.adimlar.length, // Toplam adım sayısı.
            onPageChanged: (index) {
              // Kullanıcı parmağıyla sayfa değiştirdiğinde provider'daki `mevcutAdimIndex`'i günceller.
              provider.setMevcutAdimIndexFromPageView(index);
            },
            itemBuilder: (context, index) {
              // Her bir sayfa için ilgili eğitim adımını alır ve `_buildAdimSayfasi` ile UI'ını oluşturur.
              final EgitimAdimModel adim = provider.egitimDetay!.adimlar[index];
              return _buildAdimSayfasi(adim, context);
            },
          ),
        ),
      ],
    );
  }

  /// Tek bir eğitim adımının sayfasını oluşturan yardımcı metot.
  /// Adımın fotoğrafını (varsa) ve açıklamasını gösterir.
  Widget _buildAdimSayfasi(EgitimAdimModel adim, BuildContext context) {
    String tamFotografPath = ''; // Fotoğrafın tam URL'si için.
    // API kök URL'sinden '/api/' kısmını çıkararak base URL elde edilir (örn: http://workwatchpro.xyz).
    String baseUrl = ApiSabitleri.kokUrl.replaceAll('/api/', '');

    // Adım fotoğrafı varsa ve boş değilse tam URL'sini oluşturur.
    if (adim.adimFotograf != null && adim.adimFotograf!.isNotEmpty) {
      String gelenYol = adim.adimFotograf!; // API'den gelen göreli yol.

      // Gelen yolun başında '/' yoksa ekler.
      if (!gelenYol.startsWith('/')) {
        gelenYol = '/$gelenYol';
      }

      // Gelen yolun formatına göre tam yolu oluşturur. API'den gelen yollar farklılık gösterebilir.
      // Bu kısım, API'nin resim yollarını nasıl döndürdüğüne bağlı olarak ayarlanmıştır.
      if (gelenYol.startsWith('/images/egitim_adimlari/')) {
        tamFotografPath = baseUrl + gelenYol;
      } else if (gelenYol.startsWith('/images/')) { // Eğer sadece '/images/konu/resim.jpg' gibi geliyorsa.
        String konuVeResim = gelenYol.substring('/images/'.length);
        tamFotografPath = '$baseUrl/images/egitim_adimlari/$konuVeResim';
      } else { // Direkt resim adı geliyorsa, varsayılan klasöre eklenir.
        tamFotografPath = '$baseUrl/images/egitim_adimlari$gelenYol';
      }
      // print("DEBUG: Oluşturulan Resim Yolu: $tamFotografPath"); // Geliştirme sırasında resim yolunu kontrol etmek için.
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Sayfa içi dolgu.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // İçeriği yatayda genişletir.
        children: [
          // Fotoğraf varsa gösterilir.
          if (tamFotografPath.isNotEmpty)
            Expanded( // Fotoğrafın kaplayacağı alan (esneklik değeri 5).
              flex: 5,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0), // Fotoğrafın altına boşluk.
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Fotoğraf yüklenirken veya yokken hafif bir arkaplan.
                  borderRadius: BorderRadius.circular(12.0), // Köşeleri yuvarlatılmış.
                ),
                child: ClipRRect( // İçeriği (resmi) belirlenen köşelere göre kırpar.
                  borderRadius: BorderRadius.circular(12.0),
                  // Resim yolu .svg ile bitiyorsa SvgPicture.network, değilse Image.network kullanılır.
                  child: tamFotografPath.toLowerCase().endsWith('.svg')
                      ? SvgPicture.network(
                          tamFotografPath,
                          fit: BoxFit.contain, // Resmi orantılı olarak sığdırır.
                          placeholderBuilder: (_) => const Center(child: CircularProgressIndicator(strokeWidth: 2.0)), // Yüklenirken gösterilecek.
                        )
                      : Image.network(
                          tamFotografPath,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) { // Yükleme sırasında.
                            if (loadingProgress == null) return child; // Yüklendiyse resmi göster.
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                          },
                          errorBuilder: (context, error, stackTrace) { // Resim yüklenemezse.
                            // print('[EgitimDetayEkrani] Adım ${adim.adimSira} Image.network Yükleme Hatası: $error URL: $tamFotografPath'); // Hata ayıklama için.
                            return Center(child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey[350])); // Kırık resim ikonu.
                          },
                        ),
                ),
              ),
            )
          // Fotoğraf yolu belirtilmiş ama tamFotografPath oluşturulamamışsa (beklenmedik bir durum).
          else if (adim.adimFotograf != null && adim.adimFotograf!.isNotEmpty)
            Expanded(flex: 5, child: Center(child: Text("Resim yüklenemedi.", style: MetinStilleri.kucukMetin.copyWith(color: Renkler.hataRengi))))
          // Fotoğraf yoksa bu alan boş bırakılır.
          else
            const SizedBox.shrink(), // Hiç yer kaplamayan bir widget.

          // Eğitim adımının açıklama metnini gösteren kısım.
          Expanded(
            flex: 4, // Açıklamanın kaplayacağı alan (esneklik değeri 4).
            child: SingleChildScrollView( // Açıklama uzunsa kaydırılabilir olmasını sağlar.
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0), // Açıklamanın üstüne hafif boşluk.
                // Açıklama metni varsa ve boş değilse gösterilir.
                (adim.adimAciklama != null && adim.adimAciklama!.isNotEmpty)
                    ? Text(
                        adim.adimAciklama!,
                        style: MetinStilleri.govdeMetni.copyWith(fontSize: 17, height: 1.65, color: Renkler.anaMetinRengi), // Metin stili.
                        textAlign: TextAlign.left, // Metni sola yaslar.
                      )
                    // Açıklama yoksa bilgilendirme mesajı.
                    : Center(child: Text("Bu adım için açıklama bulunmamaktadır.", style: MetinStilleri.govdeMetniIkincil)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Alt navigasyon butonunu ("Sonraki Adım" veya "Eğitimi Bitir") oluşturan yardımcı metot.
  Widget _buildBottomButton(EgitimDetayProvider provider, BuildContext context) {
    // Mevcut adımın son adım olup olmadığını kontrol eder.
    bool sonAdim = provider.sonAdimdaMi;

    return Container(
      padding: const EdgeInsets.all(16.0), // Butonun etrafına dolgu.
      decoration: BoxDecoration( // Butonun arkaplanı ve gölgesi için dekorasyon.
        color: Renkler.kartArkaPlanRengi, // Arkaplan rengi (genellikle beyaz).
        boxShadow: [ // Hafif bir üst gölge efekti.
          BoxShadow(
            color: Colors.black.withAlpha(20), // Gölge rengi ve şeffaflığı.
            blurRadius: 8, // Gölge bulanıklığı.
            offset: const Offset(0, -2), // Gölgenin konumu (yukarı doğru).
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: () {
          if (sonAdim) { // Eğer son adımdaysa.
            // Provider'daki state'i sıfırlar.
            Provider.of<EgitimDetayProvider>(context, listen: false).resetState();
            // EgitimTamamlamaEkrani'na yönlendirir ve geri dönüş yolunu kapatır.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => EgitimTamamlamaEkrani( // BU ÇAĞRI HATA VERİYOR OLABİLİR
                  egitimAdi: widget.egitimAdi, // Tamamlama ekranına eğitim adını ve test ID'sini geçirir.
                  testId: widget.testId,
                ),
              ),
            );
          } else { // Son adımda değilse.
            provider.sonrakiAdimaGec(); // Provider üzerinden bir sonraki adıma geçer.
            // PageController üzerinden de PageView'ı bir sonraki sayfaya animasyonlu olarak kaydırır.
            if (_pageController.hasClients) { // PageController bir PageView'a bağlıysa.
               _pageController.animateToPage(
                 provider.mevcutAdimIndex, // Hedef sayfa indeksi.
                 duration: const Duration(milliseconds: 350), // Animasyon süresi.
                 curve: Curves.easeOutCubic, // Animasyon eğrisi (yumuşak bir geçiş).
               );
             }
          }
        },
        style: ElevatedButton.styleFrom( // Buton stili.
          minimumSize: const Size(double.infinity, 50), // Butonun minimum genişliği ekran boyu, yüksekliği 50.
          backgroundColor: sonAdim ? Renkler.yardimciRenk : Renkler.vurguRenk, // Son adımdaysa farklı, değilse farklı renk.
        ),
        child: Text( // Buton üzerindeki yazı.
          sonAdim ? 'Eğitimi Bitir' : 'Sonraki Adım',
          style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi),
        ),
      ),
    );
  }
}