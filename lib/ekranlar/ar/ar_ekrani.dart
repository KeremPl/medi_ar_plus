import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher import edildi
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';

class ArEkrani extends StatelessWidget {
   ArEkrani({super.key});

  // Unity uygulamasını açmak için kullanılacak URL şeması
  final Uri _unityAppUrl = Uri.parse('mediar://');

  Future<void> _launchUnityApp(BuildContext context) async {
    // Uygulamanın açılıp açılamayacağını kontrol et
    if (await canLaunchUrl(_unityAppUrl)) {
      try {
        // Uygulamayı harici bir uygulama olarak başlat
        await launchUrl(_unityAppUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        // Bir hata oluşursa kullanıcıya bilgi ver
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AR uygulaması açılamadı: $e')),
          );
        }
        print('Hata: AR uygulaması açılamadı - $e');
      }
    } else {
      // URL başlatılamıyorsa (örneğin, Unity uygulaması yüklü değilse)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'AR uygulaması bulunamadı. Lütfen yüklü olduğundan emin olun.')),
        );
      }
      print('Hata: $_unityAppUrl başlatılamıyor. AR uygulaması yüklü olmayabilir.');
      // TODO: Kullanıcıyı Unity APK'sını indirmeye yönlendirecek bir
      // diyalog veya sayfa göstermeyi düşünebilirsiniz.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Kamera', style: MetinStilleri.appBarBaslik),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_enhance_outlined, size: 80, color: Renkler.anaRenk.withAlpha(180)),
              const SizedBox(height: 24),
              Text(
                'Artırılmış Gerçeklik Deneyimi',
                style: MetinStilleri.altBaslik.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Bu bölüm, ilk yardım senaryolarını artırılmış gerçeklik ile deneyimlemeniz için Unity ile geliştirilen uygulamayı başlatacaktır.', // Açıklama güncellendi
                style: MetinStilleri.govdeMetniIkincil,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt, size: 20),
                label: Text('AR Kamerayı Başlat', style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.anaRenk,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  // AR uygulamasını başlatma fonksiyonunu çağır
                  _launchUnityApp(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
