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
      Provider.of<ProfilProvider>(context, listen: false).kullaniciProfiliniGetir();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profilProvider = Provider.of<ProfilProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Çıkış için

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
         leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Renkler.ikonRengi),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              final navigator = Navigator.of(context); // Context'i await öncesi yakala
              await authProvider.cikisYap();
              if (mounted) { // mounted kontrolü hala önemli
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
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hataMesaji != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            provider.hataMesaji!,
            style: MetinStilleri.govdeMetni.copyWith(color: Renkler.hataRengi),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (provider.profilModel == null) {
      return Center(
        child: Text('Profil bilgileri yüklenemedi.', style: MetinStilleri.govdeMetniIkincil),
      );
    }

    final KullaniciModel kullanici = provider.profilModel!.kullaniciBilgileri;
    final List<RozetModel> rozetler = provider.profilModel!.kazanilanRozetler;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKullaniciBilgiKarti(kullanici),
          const SizedBox(height: 24),
          Text('Kazanılan Rozetler', style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
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
                    childAspectRatio: 1.0, // Karemsi
                  ),
                  itemCount: rozetler.length,
                  itemBuilder: (context, index) {
                    return RozetKarti(rozet: rozetler[index]);
                  },
                ),
          // Buraya test geçmişi de eklenebilir (API hazır olduğunda)
        ],
      ),
    );
  }

  Widget _buildKullaniciBilgiKarti(KullaniciModel kullanici) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Renkler.anaRenk.withAlpha((0.15 * 255).round()), // Düzeltildi
              child: Icon(Icons.person, size: 50, color: Renkler.anaRenk),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${kullanici.ad} ${kullanici.soyad}',
                    style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
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
          ],
        ),
      ),
    );
  }
}

class RozetKarti extends StatelessWidget {
  final RozetModel rozet;
  const RozetKarti({super.key, required this.rozet});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "${rozet.rozetAdi}\n${rozet.rozetAciklama ?? ''}\nKazanma: ${rozet.kazanmaTarihi?.substring(0,10) ?? '-'}", // Düzeltildi: rozetAciklama
      child: Card(
        elevation: 2,
        color: Renkler.yardimciRenk.withAlpha((0.1 * 255).round()), // Düzeltildi
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Renkler.yardimciRenk.withAlpha((0.5 * 255).round())) // Düzeltildi
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IkonDonusturucu.getIconData(rozet.rozetIconAdi),
                size: 35,
                color: Renkler.yardimciRenk,
              ),
              const SizedBox(height: 8),
              Text(
                rozet.rozetAdi,
                style: MetinStilleri.kucukMetin.copyWith(color: Renkler.yardimciRenk, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}