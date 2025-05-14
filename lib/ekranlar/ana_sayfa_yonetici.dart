import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providerlar/navigasyon_provider.dart';
// import '../sabitler/renkler.dart'; // Kullanılmıyor
// import '../sabitler/metin_stilleri.dart'; // Kullanılmıyor
import 'ar/ar_ekrani.dart';
import 'egitim/egitim_listesi_ekrani.dart';
import 'test/test_listesi_ekrani.dart';
import 'profil/profil_ekrani.dart';

class AnaSayfaYoneticisi extends StatelessWidget {
  const AnaSayfaYoneticisi({super.key});

  static const List<Widget> _ekranSecenekleri = <Widget>[
    ArEkrani(),
    EgitimListesiEkrani(),
    TestListesiEkrani(),
    ProfilEkrani(),
  ];

  final List<BottomNavigationBarItem> _navBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt_outlined),
      activeIcon: Icon(Icons.camera_alt),
      label: 'AR',
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

  @override
  Widget build(BuildContext context) {
    final navigasyonProvider = Provider.of<NavigasyonProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: navigasyonProvider.seciliIndex,
        children: _ekranSecenekleri,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navBarItems,
        currentIndex: navigasyonProvider.seciliIndex,
        onTap: (index) => navigasyonProvider.seciliIndexAta(index),
        // Diğer stil özellikleri tema dosyasından (bottomNavigationBarTheme) gelecek
      ),
    );
  }
}
