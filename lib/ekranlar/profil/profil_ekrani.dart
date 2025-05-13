import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/profil_provider.dart';
import '../../providerlar/auth_provider.dart';
import '../../providerlar/egitim_provider.dart';
import '../../providerlar/egitim_detay_provider.dart';
import '../../providerlar/test_provider.dart';
import '../../providerlar/navigasyon_provider.dart';
import '../../modeller/kullanici_model.dart';
import '../../modeller/rozet_model.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import '../auth/login_ekrani.dart';
import '../../utils/ikon_donusturucu.dart';

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
       // Kullanıcı ID değişmiş olabilir, her zaman profili çekmeyi deneyebiliriz.
       // Veya sadece null ise çekebiliriz. Şimdilik her zaman çeksin.
       profilProvider.kullaniciProfiliniGetir();
    });
  }

  void _cikisYapVeResetle(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    print('[ProfilEkrani] Çıkış yapılıyor ve state resetleniyor...');
    Provider.of<ProfilProvider>(context, listen: false).resetState();
    Provider.of<EgitimProvider>(context, listen: false).resetState();
    Provider.of<EgitimDetayProvider>(context, listen: false).resetState();
    Provider.of<TestProvider>(context, listen: false).resetState();
    Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(0);

    await authProvider.cikisYap();

    if (mounted) {
       navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginEkrani()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);
    print('[ProfilEkrani] build çağrıldı. isLoading: ${profilProvider.isLoading}, Profil Model: ${profilProvider.profilModel != null}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
           IconButton(
            icon: Icon(Icons.logout, color: Renkler.ikonRengi),
            tooltip: 'Çıkış Yap',
            onPressed: () => _cikisYapVeResetle(context),
          ),
        ],
      ),
      body: _buildBody(profilProvider, context),
    );
  }

  Widget _buildBody(ProfilProvider provider, BuildContext context) {
    if (provider.isLoading && provider.profilModel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.hataMesaji != null && provider.profilModel == null) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(provider.hataMesaji!, textAlign: TextAlign.center, style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi)),
          )
      );
    }
    if (provider.profilModel == null) {
      return Center(
        child: Text('Profil bilgileri yüklenemedi veya bulunamadı.', style: MetinStilleri.govdeMetniIkincil),
      );
    }
    final KullaniciModel kullanici = provider.profilModel!.kullaniciBilgileri;
    final List<RozetModel> rozetler = provider.profilModel!.kazanilanRozetler;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKullaniciBilgiKarti(kullanici, context),
          const SizedBox(height: 24),
          const Divider(), // Tema'dan stil alacak
          const SizedBox(height: 20),
          Text('Kazanılan Rozetler', style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          rozetler.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text('Henüz hiç rozet kazanmadınız.', style: MetinStilleri.govdeMetniIkincil),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: rozetler.length,
                  itemBuilder: (context, index) {
                    return BasarimKarti(rozet: rozetler[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildKullaniciBilgiKarti(KullaniciModel kullanici, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Renkler.anaRenk.withAlpha((0.15 * 255).round()),
              child: Icon(Icons.person, size: 50, color: Renkler.anaRenk),
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
                  Text('@${kullanici.kullaniciAdi}', style: MetinStilleri.govdeMetniIkincil),
                  const SizedBox(height: 2),
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

class BasarimKarti extends StatelessWidget {
  final RozetModel rozet;
  const BasarimKarti({super.key, required this.rozet});

  @override
  Widget build(BuildContext context) {
    final Color renk = Renkler.basariRengi;
    final IconData ikon = IkonDonusturucu.getIconData(rozet.rozetIconAdi);
    return Tooltip(
      message: "${rozet.rozetAdi}\n${rozet.rozetAciklama ?? ''}\nKazanma: ${rozet.kazanmaTarihi?.substring(0,10) ?? '-'}",
      padding: const EdgeInsets.all(8.0),
      textStyle: MetinStilleri.kucukMetin.copyWith(color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87.withAlpha(220), // withOpacity yerine
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: renk.withAlpha(120), width: 1.5),
          boxShadow: [ BoxShadow(color: renk.withAlpha(50), blurRadius: 5.0, offset: const Offset(0, 2)) ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 35.0, color: renk),
            const SizedBox(height: 6),
            Text(
              rozet.rozetAdi,
              style: MetinStilleri.cokKucukMetin.copyWith(color: renk, fontWeight: FontWeight.w500),
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
