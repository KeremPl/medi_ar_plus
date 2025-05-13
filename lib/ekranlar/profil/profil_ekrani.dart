import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/profil_provider.dart';
import '../../providerlar/auth_provider.dart';
import '../../modeller/kullanici_model.dart';
import '../../modeller/rozet_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../../utils/ikon_donusturucu.dart';
import '../auth/login_ekrani.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final profilProvider = Provider.of<ProfilProvider>(context, listen: false);
       // Sadece profil modeli null ise veya hata varsa yükle
       if (profilProvider.profilModel == null || profilProvider.hataMesaji != null) {
          profilProvider.kullaniciProfiliniGetir();
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profilim', style: MetinStilleri.appBarBaslik), // ar_medic
        // leading: IconButton( // BottomNavBar'dan gelindiği için geri butonu olmamalı
        //   icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        actions: [ // ar_medic'teki gibi
          // TextButton( // Ayarlar butonu örneği, sonra eklenebilir
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Ayarlar sayfası henüz yok.')),
          //     );
          //   },
          //   child: Text(
          //     'Ayarlar',
          //     style: TextStyle(color: Renkler.ikonRengi, fontSize: 16),
          //   ),
          // ),
          // const SizedBox(width: 8),
           IconButton( // Çıkış butonu AppBar'da daha uygun olabilir
            icon: Icon(Icons.logout, color: Renkler.ikonRengi),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              final navigator = Navigator.of(context);
              await authProvider.cikisYap();
              if (mounted) {
                 navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginEkrani()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(profilProvider, context),
    );
  }

  Widget _buildBody(ProfilProvider provider, BuildContext context) {
    if (provider.isLoading && provider.profilModel == null) { // Sadece ilk yüklemede
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hataMesaji != null && provider.profilModel == null) {
      return Center( /* ... Hata mesajı ... */ );
    }

    if (provider.profilModel == null) {
      return Center( /* ... Profil yüklenemedi ... */ );
    }

    final KullaniciModel kullanici = provider.profilModel!.kullaniciBilgileri;
    final List<RozetModel> rozetler = provider.profilModel!.kazanilanRozetler;

    // "ar_medic" ProfilEkrani'na benzer yapı
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKullaniciBilgiKarti(kullanici, context), // context eklendi (login'e yönlendirme için)
          const SizedBox(height: 20), // Biraz daha fazla boşluk
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Başarımlar', // ar_medic'teki gibi
            style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          rozetler.isEmpty
              ? Center( /* ... Rozet yok mesajı ... */ )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // ar_medic
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.0, // Kare
                  ),
                  itemCount: rozetler.length,
                  itemBuilder: (context, index) {
                    // "ar_medic" BasarimKutusu'na benzer bir widget kullanılacak
                    return BasarimKarti(rozet: rozetler[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildKullaniciBilgiKarti(KullaniciModel kullanici, BuildContext context) {
    // "ar_medic" stiline benzer bir kart
    return InkWell( // ar_medic'teki gibi tıklanabilir (giriş yapılmamışsa login'e atmak için ama burada zaten girişli)
      onTap: () {
        // Belki profil düzenleme ekranına gidilebilir (sonraki özellik)
        // print("Kullanıcı bilgi kartı tıklandı.");
      },
      borderRadius: BorderRadius.circular(12.0), // Tema'daki Card borderRadius
      child: Card( // InkWell'i Card ile sarmala
        // elevation: 0, // InkWell zaten Card içinde olduğu için Card'ın elevation'ı yeterli
        // margin: EdgeInsets.zero, // Card'ın kendi margin'i var, InkWell için ek margin gerekmez
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Daha ferah padding
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Renkler.anaRenk.withAlpha((0.2 * 255).round()), // ar_medic
                child: Icon(
                  Icons.person, // Giriş yapılmış, her zaman person ikonu
                  size: 50, color: Renkler.anaRenk),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${kullanici.ad} ${kullanici.soyad}',
                      style: MetinStilleri.altBaslik.copyWith(fontSize: 19, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${kullanici.kullaniciAdi}',
                      style: MetinStilleri.govdeMetniIkincil,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kullanici.email,
                      style: MetinStilleri.govdeMetniIkincil,
                    ),
                  ],
                ),
              ),
              // if (kullanici == null) // Bu ekran sadece giriş yapmışken görünür
              //   Icon(Icons.login, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// "ar_medic" BasarimKutusu'na benzer widget
class BasarimKarti extends StatelessWidget {
  final RozetModel rozet;
  const BasarimKarti({super.key, required this.rozet});

  @override
  Widget build(BuildContext context) {
    // "ar_medic" BasarimKutusu'ndaki gibi, kazanılma durumu bizde her zaman true olacak
    // (sadece kazanılanlar listeleniyor)
    final Color renk = Renkler.basariRengi; // ar_medic'teki kazanildi durumu
    final IconData ikon = IkonDonusturucu.getIconData(rozet.rozetIconAdi);

    return Tooltip( // ar_medic
      message: "${rozet.rozetAdi}\n${rozet.rozetAciklama ?? ''}\nKazanma: ${rozet.kazanmaTarihi?.substring(0,10) ?? '-'}",
      padding: const EdgeInsets.all(8.0),
      textStyle: MetinStilleri.kucukMetin.copyWith(color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Container( // ar_medic'teki gibi Container
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white, // ar_medic
          borderRadius: BorderRadius.circular(10.0), // ar_medic
          border: Border.all( // ar_medic
              color: renk.withAlpha(120), // Daha belirgin border
              width: 1.5),
          boxShadow: [ // ar_medic
            BoxShadow(
              color: renk.withAlpha(50),
              blurRadius: 5.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ikon,
              size: 35.0, // Biraz daha büyük
              color: renk,
            ),
            const SizedBox(height: 6),
            Text(
              rozet.rozetAdi,
              style: MetinStilleri.cokKucukMetin.copyWith(color: renk, fontWeight: FontWeight.w500), // ar_medic
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
