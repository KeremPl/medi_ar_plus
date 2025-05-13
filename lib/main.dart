import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ekranlar/auth/login_ekrani.dart';
import 'ekranlar/ana_sayfa_yonetici.dart'; // Yeni ana ekran
import 'providerlar/auth_provider.dart';  
import 'providerlar/egitim_provider.dart';
import 'providerlar/egitim_detay_provider.dart';
import 'providerlar/test_provider.dart';
import 'providerlar/profil_provider.dart';
import 'providerlar/navigasyon_provider.dart'; // Eklendi
import 'sabitler/tema.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NavigasyonProvider()), // Eklendi
        ChangeNotifierProvider(create: (_) => EgitimProvider()),
        ChangeNotifierProvider(create: (_) => EgitimDetayProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ProfilProvider(prefs)),
      ],
      child: const MediARPlusApp(),
    ),
  );
}

class MediARPlusApp extends StatelessWidget {
  const MediARPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediAR+',
      theme: AppTema.acikTema,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading && !authProvider.initialAuthCheckDone) { // Sadece ilk yüklemede göster
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (authProvider.mevcutKullaniciId != null) {
            // Giriş yapılmışsa NavigasyonProvider'ı sıfırla (isteğe bağlı)
            // Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(0);
            return const AnaSayfaYoneticisi(); // Değiştirildi
          } else {
            return const LoginEkrani();
          }
        },
      ),
    );
  }
}
