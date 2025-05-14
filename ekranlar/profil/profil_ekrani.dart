// Flutter materyal tasarım kütüphanesini ve Provider paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Uygulama içi provider'ları, modelleri, sabitleri ve yardımcı sınıfları import eder.
import '../../providerlar/profil_provider.dart';
import '../../providerlar/auth_provider.dart';
import '../../providerlar/egitim_provider.dart'; // Çıkış yaparken state resetlemek için.
import '../../providerlar/egitim_detay_provider.dart'; // Çıkış yaparken state resetlemek için.
import '../../providerlar/test_provider.dart'; // Çıkış yaparken state resetlemek için.
import '../../providerlar/navigasyon_provider.dart'; // Çıkış yaparken state resetlemek için.
import '../../modeller/kullanici_model.dart';
import '../../modeller/rozet_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../auth/login_ekrani.dart'; // Çıkış yapıldıktan sonra yönlendirilecek ekran.
import '../../utils/ikon_donusturucu.dart'; // String ikon adlarını IconData'ya çevirmek için.

/// [ProfilEkrani], kullanıcının kişisel bilgilerini (ad, soyad, e-posta vb.)
/// ve kazandığı başarı rozetlerini görüntülediği arayüzü sunar.
/// Ayrıca, kullanıcıya uygulamadan çıkış yapma (logout) imkanı tanır.
/// Bu bir `StatefulWidget`'tır çünkü `initState` içinde profil verilerini çekme işlemi başlatılır.
class ProfilEkrani extends StatefulWidget {
  /// Constructor.
  const ProfilEkrani({super.key});

  /// Bu widget için state nesnesini oluşturur.
  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

/// [ProfilEkrani] için state yönetimini ve UI mantığını içeren sınıf.
class _ProfilEkraniState extends State<ProfilEkrani> {
  /// Widget ilk oluşturulduğunda ve ağaca eklendiğinde çağrılır.
  @override
  void initState() {
    super.initState();
    // `WidgetsBinding.instance.addPostFrameCallback` ile build metodu tamamlandıktan sonra işlem yapılır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final profilProvider = Provider.of<ProfilProvider>(context, listen: false);
       // Kullanıcı ID'si değişmiş olabileceği veya ilk yükleme olabileceği için,
       // her zaman profil bilgilerini API'den çekmeyi dener.
       // Alternatif olarak, sadece `profilProvider.profilModel == null` ise çekme işlemi yapılabilirdi.
       // Ancak mevcut implementasyon, olası senkronizasyon sorunlarını engellemek için daha güvenlidir.
       profilProvider.kullaniciProfiliniGetir();
    });
  }

  /// Kullanıcının oturumunu sonlandırır, ilgili provider'ların state'lerini sıfırlar
  /// ve kullanıcıyı giriş ekranına yönlendirir.
  void _cikisYapVeResetle(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Navigator.of(context) asenkron işlem öncesinde değişkene atanır,
    // çünkü `await` sonrasında `context`'in geçerliliği değişebilir (widget ağaçtan kaldırılmış olabilir).
    final navigator = Navigator.of(context);

    print('[ProfilEkrani] Çıkış yapılıyor ve tüm ilgili provider state\'leri resetleniyor...');
    // İlgili tüm provider'ların state'lerini sıfırlayarak uygulamanın temiz bir duruma dönmesini sağlar.
    Provider.of<ProfilProvider>(context, listen: false).resetState();
    Provider.of<EgitimProvider>(context, listen: false).resetState();
    Provider.of<EgitimDetayProvider>(context, listen: false).resetState();
    Provider.of<TestProvider>(context, listen: false).resetState();
    // Ana sayfadaki navigasyon barını varsayılan ilk sekmeye (index 0) ayarlar.
    Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(0);

    // AuthProvider üzerinden çıkış işlemini gerçekleştirir (SharedPreferences'tan kullanıcı bilgilerini siler).
    await authProvider.cikisYap();

    // Eğer widget hala ağaçtaysa (mounted), kullanıcıyı LoginEkrani'na yönlendirir.
    // `pushAndRemoveUntil` ile mevcut tüm ekranlar yığından kaldırılır, böylece geri tuşuyla
    // profil ekranına dönülemez.
    if (mounted) {
       navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginEkrani()),
        (Route<dynamic> route) => false, // Tüm önceki yolları kaldır.
      );
    }
  }

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    // ProfilProvider'a erişim sağlar (dinleme yaparak, UI güncellemeleri için).
    final profilProvider = Provider.of<ProfilProvider>(context);
    // Geliştirme için loglama: build metodunun çağrılma durumu ve provider'daki veriler.
    print('[ProfilEkrani] build çağrıldı. isLoading: ${profilProvider.isLoading}, Profil Model: ${profilProvider.profilModel != null}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'), // AppBar başlığı (Tema'dan stil alır).
        actions: [ // AppBar'ın sağ tarafındaki eylem butonları.
           IconButton(
            icon: Icon(Icons.logout, color: Renkler.ikonRengi), // Çıkış ikonu.
            tooltip: 'Çıkış Yap', // İkon üzerine gelindiğinde gösterilecek ipucu.
            onPressed: () => _cikisYapVeResetle(context), // Tıklandığında çıkış işlemini başlatır.
          ),
        ],
      ),
      // Ekranın ana gövdesini `_buildBody` metodu ile oluşturur.
      body: _buildBody(profilProvider, context),
    );
  }

  /// Ekranın ana gövdesini oluşturan yardımcı metot.
  /// Yükleme durumu, hata durumu ve profil bilgilerinin varlığına göre farklı UI'lar gösterir.
  Widget _buildBody(ProfilProvider provider, BuildContext context) {
    // Veri yükleniyorsa ve henüz profil modeli yoksa yükleme göstergesi gösterir.
    if (provider.isLoading && provider.profilModel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Hata mesajı varsa ve profil modeli yoksa hata mesajını gösterir.
    if (provider.hataMesaji != null && provider.profilModel == null) {
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
    // Profil modeli yüklenememişse veya boşsa bilgilendirme mesajı gösterir.
    if (provider.profilModel == null) {
      return Center(
        child: Text(
          'Profil bilgileri yüklenemedi veya bulunamadı.',
          style: MetinStilleri.govdeMetniIkincil
        ),
      );
    }
    // Profil modelinden kullanıcı bilgilerini ve kazanılan rozetleri alır.
    final KullaniciModel kullanici = provider.profilModel!.kullaniciBilgileri;
    final List<RozetModel> rozetler = provider.profilModel!.kazanilanRozetler;

    // Profil içeriğini kaydırılabilir bir alanda gösterir.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // İçeriğin etrafına dolgu.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // İçeriği sola yaslar.
        children: [
          // Kullanıcı bilgilerini gösteren kartı oluşturur.
          _buildKullaniciBilgiKarti(kullanici, context),
          const SizedBox(height: 24), // Kart ile ayırıcı arasına boşluk.
          const Divider(), // Tema'dan stil alacak bir ayırıcı çizgi.
          const SizedBox(height: 20), // Ayırıcı ile rozet başlığı arasına boşluk.

          // "Kazanılan Rozetler" başlığı.
          Text(
            'Kazanılan Rozetler',
            style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 16), // Başlık ile rozet listesi arasına boşluk.

          // Kazanılan rozet yoksa bilgilendirme mesajı, varsa rozetleri GridView içinde gösterir.
          rozetler.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Henüz hiç rozet kazanmadınız.',
                      style: MetinStilleri.govdeMetniIkincil
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true, // GridView'ı içeriği kadar küçültür (SingleChildScrollView içinde olduğu için).
                  physics: const NeverScrollableScrollPhysics(), // GridView'ın kendi kaydırmasını engeller.
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Yatayda 3 sütun.
                    crossAxisSpacing: 12.0, // Sütunlar arası yatay boşluk.
                    mainAxisSpacing: 12.0, // Satırlar arası dikey boşluk.
                    childAspectRatio: 1.0, // Kare şeklinde rozet kartları (genişlik = yükseklik).
                  ),
                  itemCount: rozetler.length, // Toplam rozet sayısı.
                  itemBuilder: (context, index) {
                    // Her bir rozet için `BasarimKarti` widget'ını oluşturur.
                    return BasarimKarti(rozet: rozetler[index]);
                  },
                ),
        ],
      ),
    );
  }

  /// Kullanıcının temel bilgilerini (avatar, ad-soyad, kullanıcı adı, e-posta)
  /// içeren bir kart oluşturan yardımcı metot.
  Widget _buildKullaniciBilgiKarti(KullaniciModel kullanici, BuildContext context) {
    return Card( // Tema'dan stil alır.
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Kart içi dolgu.
        child: Row( // Avatar ve bilgileri yan yana dizer.
          children: [
            // Kullanıcı avatarı (varsayılan bir kişi ikonu).
            CircleAvatar(
              radius: 40, // Avatarın yarıçapı.
              backgroundColor: Renkler.anaRenk.withAlpha((0.15 * 255).round()), // Ana rengin hafif şeffaf bir tonu.
              child: Icon(Icons.person, size: 50, color: Renkler.anaRenk), // Avatar ikonu.
            ),
            const SizedBox(width: 16), // Avatar ile bilgiler arasına boşluk.
            Expanded( // Bilgi kısmının kalan alanı kaplamasını sağlar.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Bilgileri sola yaslar.
                children: [
                  // Kullanıcının adı ve soyadı.
                  Text(
                    '${kullanici.ad} ${kullanici.soyad}',
                    style: MetinStilleri.altBaslik.copyWith(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4), // Ad-soyad ile kullanıcı adı arasına boşluk.
                  // Kullanıcı adı.
                  Text('@${kullanici.kullaniciAdi}', style: MetinStilleri.govdeMetniIkincil),
                  const SizedBox(height: 2), // Kullanıcı adı ile e-posta arasına boşluk.
                  // E-posta adresi.
                  Text(kullanici.email, style: MetinStilleri.govdeMetniIkincil),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir başarı rozetini temsil eden `StatelessWidget`.
/// Rozetin ikonunu ve adını gösterir. Üzerine gelindiğinde Tooltip ile detaylarını gösterir.
class BasarimKarti extends StatelessWidget {
  final RozetModel rozet; // Bu kartın göstereceği rozet modeli.

  /// Constructor. Gerekli `rozet` parametresini alır.
  const BasarimKarti({super.key, required this.rozet});

  @override
  Widget build(BuildContext context) {
    // Rozet için varsayılan renk ve ikon.
    final Color renk = Renkler.basariRengi; // Rozetler için genel başarı rengi.
    final IconData ikon = IkonDonusturucu.getIconData(rozet.rozetIconAdi); // İkon adını IconData'ya çevirir.

    // Tooltip, üzerine gelindiğinde (veya uzun basıldığında) ek bilgi gösterir.
    return Tooltip(
      message: "${rozet.rozetAdi}\n${rozet.rozetAciklama ?? ''}\nKazanma Tarihi: ${rozet.kazanmaTarihi?.substring(0,10) ?? '-'}",
      padding: const EdgeInsets.all(8.0), // Tooltip içi dolgu.
      textStyle: MetinStilleri.kucukMetin.copyWith(color: Colors.white), // Tooltip metin stili.
      decoration: BoxDecoration( // Tooltip arkaplanı.
        color: Colors.black87.withAlpha(220), // Yarı şeffaf siyah.
        borderRadius: BorderRadius.circular(6.0), // Köşeleri yuvarlatılmış.
      ),
      child: Container( // Rozet kartının ana container'ı.
        padding: const EdgeInsets.all(8.0), // İçerik için dolgu.
        decoration: BoxDecoration(
          color: Colors.white, // Kart arkaplanı.
          borderRadius: BorderRadius.circular(10.0), // Köşeleri yuvarlatılmış.
          border: Border.all(color: renk.withAlpha(120), width: 1.5), // Kenarlık.
          boxShadow: [ // Hafif bir gölge.
            BoxShadow(color: renk.withAlpha(50), blurRadius: 5.0, offset: const Offset(0, 2))
          ],
        ),
        child: Column( // İkon ve rozet adını dikey olarak dizer.
          mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortalar.
          children: [
            Icon(ikon, size: 35.0, color: renk), // Rozet ikonu.
            const SizedBox(height: 6), // İkon ile ad arasına boşluk.
            // Rozet adı.
            Text(
              rozet.rozetAdi,
              style: MetinStilleri.cokKucukMetin.copyWith(color: renk, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center, // Metni ortalar.
              maxLines: 2, // Maksimum 2 satır.
              overflow: TextOverflow.ellipsis, // Sığmazsa sonuna "..." ekler.
            ),
          ],
        ),
      ),
    );
  }
}
