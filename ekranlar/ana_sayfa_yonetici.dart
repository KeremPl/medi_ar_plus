// Flutter materyal tasarım kütüphanesini ve Provider paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Uygulama içi navigasyon durumunu yöneten provider'ı import eder.
import '../providerlar/navigasyon_provider.dart';
// Kullanılmayan importlar yorum satırı haline getirilmiş.
// import '../sabitler/renkler.dart';
// import '../sabitler/metin_stilleri.dart';
// Alt navigasyon barındaki her bir sekme için ilgili ekranları import eder.
import 'ar/ar_ekrani.dart';
import 'egitim/egitim_listesi_ekrani.dart';
import 'test/test_listesi_ekrani.dart';
import 'profil/profil_ekrani.dart';

/// [AnaSayfaYoneticisi], uygulamanın ana navigasyon yapısını yöneten bir widget'tır.
/// Giriş yapıldıktan sonra kullanıcıyı karşılar ve alt navigasyon çubuğu (BottomNavigationBar)
/// aracılığıyla farklı ekranlara (AR, Kütüphane, Test, Profil) geçişi sağlar.
class AnaSayfaYoneticisi extends StatelessWidget {
  /// Constructor. `key` parametresi widget ağacında bu widget'ı benzersiz şekilde tanımlamak için kullanılır.
  const AnaSayfaYoneticisi({super.key});

  /// Alt navigasyon çubuğundaki her bir sekme tıklandığında gösterilecek widget'ların listesi.
  /// Bu widget'lar `IndexedStack` içinde kullanılır.
  static const List<Widget> _ekranSecenekleri = <Widget>[
    ArEkrani(), // AR sekmesi için ekran.
    EgitimListesiEkrani(), // Kütüphane (Eğitimler) sekmesi için ekran.
    TestListesiEkrani(), // Test sekmesi için ekran.
    ProfilEkrani(), // Profil sekmesi için ekran.
  ];

  /// Alt navigasyon çubuğunda gösterilecek öğelerin (ikon ve etiket) listesi.
  final List<BottomNavigationBarItem> _navBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt_outlined), // Seçili olmayan durumdaki ikon.
      activeIcon: Icon(Icons.camera_alt), // Seçili durumdaki ikon.
      label: 'AR', // Sekmenin etiketi.
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school_outlined),
      activeIcon: Icon(Icons.school),
      label: 'Kütüphane',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.quiz_outlined),
      activeIcon: Icon(Icons.quiz),
      label: 'Test',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    // NavigasyonProvider'a erişim sağlar. Provider, seçili olan sekmenin index'ini tutar.
    // `context` üzerinden dinleme (listen: true) yapılır, böylece index değiştiğinde UI güncellenir.
    final navigasyonProvider = Provider.of<NavigasyonProvider>(context);

    return Scaffold(
      // `IndexedStack`, `_ekranSecenekleri` listesindeki widget'lardan sadece
      // `navigasyonProvider.seciliIndex` ile belirtilen index'teki widget'ı gösterir.
      // Bu, sekmeler arası geçişte ekranların state'lerinin korunmasını sağlar.
      body: IndexedStack(
        index: navigasyonProvider.seciliIndex,
        children: _ekranSecenekleri,
      ),
      // Alt navigasyon çubuğu.
      bottomNavigationBar: BottomNavigationBar(
        items: _navBarItems, // Gösterilecek navigasyon öğeleri.
        currentIndex: navigasyonProvider.seciliIndex, // Aktif olan sekmenin index'i.
        onTap: (index) => navigasyonProvider.seciliIndexAta(index), // Bir sekme tıklandığında Provider'daki index'i günceller.
        // Diğer stil özellikleri (seçili renk, seçilmemiş renk, arkaplan rengi vb.)
        // `AppTema.acikTema` içindeki `bottomNavigationBarTheme` ayarlarından gelir.
      ),
    );
  }
}
