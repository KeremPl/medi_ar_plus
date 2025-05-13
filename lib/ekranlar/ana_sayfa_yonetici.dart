import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providerlar/navigasyon_provider.dart';
import '../sabitler/renkler.dart';
import '../sabitler/metin_stilleri.dart'; // Eklendi
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

  // ar_medic'teki BottomNavBar ikonları ve labelları
  final List<BottomNavigationBarItem> _navBarItems = const [
     BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt_outlined),
      activeIcon: Icon(Icons.camera_alt), // Tema'dan seçili renk alacak
      label: 'AR',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_books_outlined),
      activeIcon: Icon(Icons.library_books),
      label: 'Kütüphane', // "Eğitimler" yerine "Kütüphane"
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.quiz_outlined),
      activeIcon: Icon(Icons.quiz),
      label: 'Test', // "Testler" yerine "Test"
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
      body: IndexedStack( // Ekran state'lerini korumak için iyi
        index: navigasyonProvider.seciliIndex,
        children: _ekranSecenekleri,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navBarItems,
        currentIndex: navigasyonProvider.seciliIndex,
        // Diğer stil özellikleri tema dosyasından (bottomNavigationBarTheme) gelecek
        // selectedItemColor: Renkler.anaRenk, // Tema'dan
        // unselectedItemColor: Colors.grey[600], // Tema'dan
        // showUnselectedLabels: true, // Tema'dan
        // type: BottomNavigationBarType.fixed, // Tema'dan
        // backgroundColor: Colors.white, // Tema'dan
        // elevation: 8.0, // Tema'dan
        onTap: (index) => navigasyonProvider.seciliIndexAta(index),
      ),
    );
  }
}
