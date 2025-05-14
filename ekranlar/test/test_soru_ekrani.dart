// Flutter materyal tasarım kütüphanesini ve Provider paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Uygulama içi provider'ları, modelleri ve sabitleri import eder.
import '../../providerlar/test_provider.dart';
import '../../modeller/soru_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import 'test_sonuc_ekrani.dart'; // Test bittiğinde yönlendirilecek ekran.

/// [TestSoruEkrani], seçilen bir testin sorularını kullanıcıya sayfa sayfa sunan,
/// cevaplarını alan ve testin sonunda sonuç ekranına yönlendiren arayüzü sağlar.
/// Bu bir `StatefulWidget`'tır çünkü `PageController` gibi state'e bağlı nesneler,
/// `initState` ve `dispose` gibi yaşam döngüsü metotları ve `_onWillPop` gibi
/// kullanıcı etkileşimine bağlı state değişiklikleri içerir.
class TestSoruEkrani extends StatefulWidget {
  final int testId; // Soruları gösterilecek testin ID'si.

  /// Constructor. Gerekli `testId` parametresini alır.
  const TestSoruEkrani({super.key, required this.testId});

  /// Bu widget için state nesnesini oluşturur.
  @override
  State<TestSoruEkrani> createState() => _TestSoruEkraniState();
}

/// [TestSoruEkrani] için state yönetimini ve UI mantığını içeren sınıf.
class _TestSoruEkraniState extends State<TestSoruEkrani> {
  // Sorular arasında sayfa sayfa geçiş yapmak için kullanılan PageController.
  final PageController _pageController = PageController();

  /// Widget ilk oluşturulduğunda ve ağaca eklendiğinde çağrılır.
  @override
  void initState() {
    super.initState();
    // `WidgetsBinding.instance.addPostFrameCallback` ile build metodu tamamlandıktan sonra işlem yapılır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final testProvider = Provider.of<TestProvider>(context, listen: false);
      // Teste başlarken TestProvider'daki önceki test verilerini sıfırlar.
      testProvider.resetState(); // Önceki testten kalan verileri temizler.
      // TestProvider üzerinden ilgili testin sorularını API'den çeker.
      testProvider.testSorulariniGetir(widget.testId);
    });
  }

  /// Widget ağaçtan kaldırıldığında çağrılır.
  /// `PageController`'ın dispose edilmesi, olası hafıza sızıntılarını önler.
  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  /// Kullanıcı geri tuşuna bastığında veya AppBar'daki kapatma butonuna tıkladığında
  /// testten çıkmak isteyip istemediğini soran bir onay dialogu gösterir.
  ///
  /// Dönüş Değeri:
  ///   Kullanıcı çıkmayı onaylarsa `true`, iptal ederse `false` döndürür.
  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) { // Dialogun içeriğini oluşturan builder fonksiyonu.
        return AlertDialog(
          title: const Text('Testten Çıkmak İstiyor Musunuz?'),
          content: const Text('Cevaplarınız kaydedilmeyecek ve testten çıkılacaktır. Emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Dialogu kapatır ve 'false' döndürür (çıkma).
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Dialogu kapatır ve 'true' döndürür (çık).
              child: Text('Çık', style: TextStyle(color: Renkler.hataRengi)), // 'Çık' butonu farklı renkte.
            ),
          ],
        );
      },
    );
    // Eğer kullanıcı çıkmayı onayladıysa (`shouldPop == true`), TestProvider'daki state'i sıfırlar.
    if (shouldPop ?? false) { // `shouldPop` null ise (dialog bir şekilde kapanırsa) false kabul edilir.
      Provider.of<TestProvider>(context, listen: false).resetState();
      return true; // Geri gitmeye izin ver.
    }
    return false; // Geri gitmeye izin verme.
  }

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    // TestProvider'a erişim sağlar (dinleme yaparak, UI güncellemeleri için).
    final testProvider = Provider.of<TestProvider>(context);

    // `PopScope`, Android'deki geri tuşu davranışını ve AppBar'daki geri butonunun
    // (eğer `leading` ile özel olarak ayarlanmamışsa) davranışını kontrol etmeyi sağlar.
    return PopScope(
      canPop: false, // Geri tuşunun direkt olarak ekranı kapatmasını engeller.
      // `onPopInvokedWithResult` (veya eski Flutter versiyonlarında `onWillPop`), geri gitme denemesi olduğunda çağrılır.
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return; // Eğer zaten pop edilmişse (örneğin programatik olarak) bir şey yapma.
        final bool shouldPop = await _onWillPop(); // Onay dialogunu göster.
        if(shouldPop && mounted){ Navigator.of(context).pop(); } // Onaylanırsa ekranı kapat.
      },
      child: Scaffold(
        appBar: AppBar(
          // AppBar başlığı olarak TestProvider'dan gelen test adını veya varsayılan bir metni gösterir.
          title: Text(testProvider.testSorulariModel?.testAdi ?? 'Test Yükleniyor...'),
          // AppBar'ın soluna özel bir kapatma (X) butonu ekler.
          leading: IconButton(
            icon: Icon(Icons.close, color: Renkler.ikonRengi),
            onPressed: () async {
               final bool shouldPop = await _onWillPop(); // Onay dialogunu göster.
               if(shouldPop && mounted) { Navigator.of(context).pop(); } // Onaylanırsa ekranı kapat.
            }
          ),
        ),
        // Ekranın ana gövdesini `_buildBody` metodu ile oluşturur.
        body: _buildBody(testProvider, context),
        // Alt navigasyon butonu (Sonraki Soru / Testi Bitir).
        // Sadece test soruları yüklendiyse, yükleme devam etmiyorsa ve en az bir soru varsa gösterilir.
        bottomNavigationBar: testProvider.testSorulariModel != null &&
                             !testProvider.isLoading &&
                             testProvider.testSorulariModel!.sorular.isNotEmpty
            ? _buildBottomButton(testProvider, context)
            : null, // Koşul sağlanmazsa alt buton gösterilmez.
      ),
    );
  }

  /// Ekranın ana gövdesini oluşturan yardımcı metot.
  /// Yükleme durumu, hata durumu ve soruların varlığına göre farklı UI'lar gösterir.
  Widget _buildBody(TestProvider provider, BuildContext context) {
    // Sorular yükleniyorsa ve henüz soru modeli yoksa yükleme göstergesi gösterir.
    if (provider.isLoading && provider.testSorulariModel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Hata mesajı varsa ve soru modeli yoksa hata mesajını ve tekrar deneme butonunu gösterir.
    if (provider.hataMesaji != null && provider.testSorulariModel == null) {
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
                onPressed: () => provider.testSorulariniGetir(widget.testId), // Soruları tekrar çekmeyi dener.
                child: const Text('Tekrar Dene'),
              )
            ],
          ),
        ),
      );
    }
    // Soru modeli yüklenememişse veya hiç soru yoksa bilgilendirme mesajı gösterir.
    if (provider.testSorulariModel == null || provider.testSorulariModel!.sorular.isEmpty) {
      return Center(
        child: Text('Bu test için soru bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    // Test sorularını gösteren ana yapı.
    return Column(
      children: [
        // Mevcut soru numarasını ve toplam soru sayısını gösterir ("Soru X/Y").
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            'Soru ${provider.mevcutSoruIndex + 1}/${provider.testSorulariModel!.sorular.length}',
            style: MetinStilleri.kucukMetin.copyWith(color: Renkler.anaRenk, fontWeight: FontWeight.bold),
          ),
        ),
        // Testteki ilerlemeyi gösteren bir ilerleme çubuğu (LinearProgressIndicator).
        LinearProgressIndicator(
          value: (provider.mevcutSoruIndex + 1) / provider.testSorulariModel!.sorular.length,
          backgroundColor: Renkler.arkaPlanRengi, // İlerleme çubuğunun arkaplan rengi.
          valueColor: AlwaysStoppedAnimation<Color>(Renkler.anaRenk), // İlerleme rengi.
        ),
        // Soruları sayfa sayfa göstermek için PageView kullanılır.
        Expanded(
          child: PageView.builder(
            controller: _pageController, // Sayfa geçişlerini yönetir.
            itemCount: provider.testSorulariModel!.sorular.length, // Toplam soru sayısı.
            // Kullanıcı parmağıyla sayfa değiştirdiğinde provider'daki `mevcutSoruIndex`'i günceller.
            // Bu, PageController ve provider state'inin senkronize kalmasını sağlar.
            onPageChanged: (index) {
               provider.setMevcutSoruIndex(index);
            },
            itemBuilder: (context, index) {
              // Her bir sayfa için ilgili soruyu alır ve `_buildSoruSayfasi` ile UI'ını oluşturur.
              final SoruModel soru = provider.testSorulariModel!.sorular[index];
              return _buildSoruSayfasi(soru, provider);
            },
          ),
        ),
      ],
    );
  }

  /// Tek bir sorunun sayfasını oluşturan yardımcı metot.
  /// Sorunun metnini ve cevap seçeneklerini (RadioListTile olarak) gösterir.
  Widget _buildSoruSayfasi(SoruModel soru, TestProvider provider) {
    return SingleChildScrollView( // Soru ve cevaplar uzunsa kaydırılabilir olmasını sağlar.
      padding: const EdgeInsets.all(20.0), // Sayfa içi dolgu.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // İçeriği sola yaslar.
        children: [
          // Soru metnini gösterir.
          Text(
            soru.soru,
            style: MetinStilleri.altBaslik.copyWith(fontSize: 19, height: 1.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24.0), // Soru metni ile cevaplar arasına boşluk.
          // Cevap seçeneklerini ListView.builder ile listeler.
          ListView.builder(
            shrinkWrap: true, // ListView'ı içeriği kadar küçültür.
            physics: const NeverScrollableScrollPhysics(), // ListView'ın kendi kaydırmasını engeller.
            itemCount: soru.cevaplar.length, // Toplam cevap seçeneği sayısı.
            itemBuilder: (context, index) {
              final cevap = soru.cevaplar[index];
              // Bu cevap seçeneğinin kullanıcı tarafından seçilip seçilmediğini kontrol eder.
              final seciliMi = provider.verilenCevaplar[soru.soruId] == cevap.cevapId;
              return Card( // Her bir cevap seçeneği için bir kart.
                elevation: seciliMi ? 3 : 1.5, // Seçiliyse daha belirgin bir gölge.
                margin: const EdgeInsets.symmetric(vertical: 7.0), // Kartlar arası dikey boşluk.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Köşeleri yuvarlatılmış.
                  // Seçiliyse farklı bir kenarlık stili.
                  side: BorderSide(
                    color: seciliMi ? Renkler.vurguRenk : Colors.grey[300]!,
                    width: seciliMi ? 2 : 1,
                  ),
                ),
                child: RadioListTile<int>( // Radyo butonu ile cevap seçeneği.
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // İç dolgu.
                  title: Text(cevap.cevapMetni, style: MetinStilleri.govdeMetni.copyWith(fontSize: 15.5)),
                  value: cevap.cevapId, // Bu radyo butonunun değeri (cevap ID'si).
                  groupValue: provider.verilenCevaplar[soru.soruId], // Bu soru için seçilmiş olan cevap ID'si.
                  onChanged: (value) { // Bir seçenek tıklandığında.
                    if (value != null) {
                      provider.cevapVer(soru.soruId, value); // Provider üzerinden cevabı kaydeder.
                    }
                  },
                  activeColor: Renkler.vurguRenk, // Seçili radyo butonunun rengi.
                  controlAffinity: ListTileControlAffinity.trailing, // Radyo butonunu sağa yaslar.
                ),
              );
            },
          ),
          const SizedBox(height: 60), // Cevapların altına boşluk (alt butonun üzerine gelmemesi için).
        ],
      ),
    );
  }

  /// Alt navigasyon butonunu ("Sonraki Soru" veya "Testi Bitir") oluşturan yardımcı metot.
  Widget _buildBottomButton(TestProvider provider, BuildContext context) {
    // Eğer soru modeli henüz yüklenmemişse veya hiç soru yoksa boş bir widget döndürür.
    if (provider.testSorulariModel == null || provider.testSorulariModel!.sorular.isEmpty) {
      return const SizedBox.shrink();
    }
    // Mevcut soruya cevap verilip verilmediğini kontrol eder.
    // `mevcutSoru` null olabileceğinden `?.` (null-safe operator) kullanılır.
    bool cevapVerildiMi = provider.verilenCevaplar.containsKey(provider.mevcutSoru?.soruId);
    // Mevcut sorunun testteki son soru olup olmadığını kontrol eder.
    bool sonSoruda = provider.sonSorudaMi;

    return Container(
      padding: const EdgeInsets.all(16.0), // Butonun etrafına dolgu.
      decoration: BoxDecoration( // Butonun arkaplanı ve gölgesi için dekorasyon.
        color: Renkler.kartArkaPlanRengi, // Arkaplan rengi.
        boxShadow: [ // Hafif bir üst gölge efekti.
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ]
      ),
      child: ElevatedButton(
        // Butona sadece mevcut soruya cevap verildiyse basılabilir.
        onPressed: cevapVerildiMi ? () {
          if (sonSoruda) { // Eğer son sorudaysa.
            // TestSonucEkrani'na yönlendirir ve mevcut ekranı yığından kaldırır.
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => TestSonucEkrani(testId: widget.testId)),
            );
          } else { // Son soruda değilse.
            provider.sonrakiSoruyaGec(); // Provider üzerinden bir sonraki soruya geçer.
            // PageController üzerinden de PageView'ı bir sonraki sayfaya animasyonlu olarak kaydırır.
            // `_pageController.page?.round()` ile provider'daki index'in senkronize olup olmadığı kontrol edilir.
            // Bu, programatik olarak soru değiştirildiğinde PageView'ın da güncellenmesini sağlar.
            if (_pageController.hasClients && _pageController.page?.round() != provider.mevcutSoruIndex) {
              _pageController.animateToPage(
                provider.mevcutSoruIndex, // Hedef sayfa indeksi.
                duration: const Duration(milliseconds: 300), // Animasyon süresi.
                curve: Curves.easeInOut, // Animasyon eğrisi.
              );
            }
          }
        } : null, // Cevap verilmediyse buton pasif (onPressed: null).
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50), // Butonun minimum boyutu.
          // Cevap verildiyse vurgu rengi, verilmediyse gri bir renk.
          backgroundColor: cevapVerildiMi ? Renkler.vurguRenk : Colors.grey[400],
        ),
        child: Text( // Buton üzerindeki yazı.
          sonSoruda ? 'Testi Bitir' : 'Sonraki Soru',
           style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi),
        ),
      ),
    );
  }
}
