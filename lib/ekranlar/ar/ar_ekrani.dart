import 'package:flutter/material.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';

class ArEkrani extends StatelessWidget {
  const ArEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Kamera', style: MetinStilleri.appBarBaslik),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_enhance_outlined, size: 100, color: Renkler.vurguRenk.withAlpha((0.7 * 255).round())), // Düzeltildi
              const SizedBox(height: 20),
              Text(
                'AR Modülü Entegrasyonu Bekleniyor',
                style: MetinStilleri.altBaslik,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Bu özellik yakında eklenecektir. Lütfen daha sonra tekrar kontrol edin.',
                style: MetinStilleri.govdeMetniIkincil,
                textAlign: TextAlign.center,
              ),
               const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('AR Deneyimi Başlat (Demo)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.vurguRenk,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AR özelliği henüz aktif değil.')),
                  );
                  // TODO: AR kamera işlevselliği eklenecek (arkadaşın tarafından)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
