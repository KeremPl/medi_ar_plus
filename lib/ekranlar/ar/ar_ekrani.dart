import 'package:flutter/material.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';

class ArEkrani extends StatelessWidget {
  const ArEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Kamera', style: MetinStilleri.appBarBaslik), // ar_medic
        // leading: IconButton( // BottomNavBar'dan gelindiği için geri butonu olmamalı
        //   icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: Center( // ar_medic
        child: Padding(
          padding: const EdgeInsets.all(32.0), // ar_medic
          child: Column( // Ortada buton ve açıklama için
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
                'Bu bölüm, ilk yardım senaryolarını artırılmış gerçeklik ile deneyimlemeniz için geliştirilmektedir.',
                style: MetinStilleri.govdeMetniIkincil,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon( // ar_medic
                icon: const Icon(Icons.camera_alt, size: 20), // Biraz daha küçük ikon
                label: Text('AR Kamerayı Başlat', style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi)), // Stil tema'dan ama yazı rengi override
                style: ElevatedButton.styleFrom( // ar_medic
                  backgroundColor: Renkler.anaRenk,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Tam yuvarlak buton
                  ),
                  // elevation: 5.0, // Tema'dan
                ),
                onPressed: () {
                  // TODO: AR kamera işlevselliği eklenecek (arkadaşın tarafından)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AR özelliği henüz aktif değil.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
