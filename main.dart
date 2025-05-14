// Flutter materyal tasarım kütüphanesini, Provider paketini ve SharedPreferences paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Yerel depolama için.

// Uygulamanın ana ekranlarını ve provider'larını import eder.
import 'ekranlar/auth/login_ekrani.dart'; // Giriş ekranı.
import 'ekranlar/ana_sayfa_yonetici.dart'; // Giriş yapıldıktan sonraki ana ekran yöneticisi.
import 'providerlar/auth_provider.dart'; // Kimlik doğrulama state yönetimi.
import 'providerlar/egitim_provider.dart'; // Eğitim listesi state yönetimi.
import 'providerlar/egitim_detay_provider.dart'; // Eğitim detayları state yönetimi.
import 'providerlar/test_provider.dart'; // Testler ve soruları state yönetimi.
import 'providerlar/profil_provider.dart'; // Kullanıcı profili state yönetimi.
import 'providerlar/navigasyon_provider.dart'; // Alt navigasyon barı state yönetimi.
import 'sabitler/tema.dart'; // Uygulamanın genel tema ayarları.

/// Uygulamanın ana giriş noktası.
void main() async {
  // Flutter binding'lerinin başlatıldığından emin olunur. Bu, özellikle `async main`
  // ve platform kanallarıyla etkileşim öncesinde gereklidir.
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences örneği asenkron olarak alınır. Bu, uygulama başlatılmadan önce
  // yerel depolamaya erişimi hazırlar (örn: kayıtlı kullanıcı oturumu).
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Uygulamayı çalıştırır. `MultiProvider` ile tüm uygulama genelindeki provider'lar
  // widget ağacının en üstüne yerleştirilir, böylece alt widget'lar bunlara erişebilir.
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider, SharedPreferences'ı kullanarak kullanıcı oturumunu yönetir.
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        // NavigasyonProvider, alt navigasyon barındaki seçili sekmeyi yönetir.
        ChangeNotifierProvider(create: (_) => NavigasyonProvider()),
        // Diğer provider'lar ilgili modüllerin state'lerini yönetir.
        ChangeNotifierProvider(create: (_) => EgitimProvider()),
        ChangeNotifierProvider(create: (_) => EgitimDetayProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider(prefs)), // TestProvider da SharedPreferences kullanabilir (örn: kaydedilmiş cevaplar için).
        ChangeNotifierProvider(create: (_) => ProfilProvider(prefs)), // ProfilProvider da SharedPreferences kullanır (kullanıcı ID'si için).
      ],
      child: const MediARPlusApp(), // Uygulamanın kök widget'ı.
    ),
  );
}

/// [MediARPlusApp], uygulamanın kök widget'ıdır. MaterialApp'ı yapılandırır
/// ve başlangıç ekranını (giriş yapılmışsa ana sayfa, değilse login ekranı) belirler.
class MediARPlusApp extends StatelessWidget {
  /// Constructor.
  const MediARPlusApp({super.key});

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Geliştirme sırasında sağ üstte çıkan "DEBUG" banner'ını kaldırır.
      debugShowCheckedModeBanner: false,
      title: 'MediAR+', // Uygulamanın başlığı (örn: görev yöneticisinde görünür).
      theme: AppTema.acikTema, // Uygulamanın genel tema ayarlarını uygular.

      // Başlangıç ekranını belirlemek için AuthProvider'ı dinler.
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // AuthProvider hala ilk kimlik doğrulama kontrolünü yapıyorsa
          // (SharedPreferences'tan kullanıcı bilgisini okuyorsa) bir yükleme göstergesi gösterir.
          // `!authProvider.initialAuthCheckDone` kontrolü, sadece ilk yüklemede bu ekranın görünmesini sağlar.
          if (authProvider.isLoading && !authProvider.initialAuthCheckDone) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Eğer geçerli bir kullanıcı ID'si varsa (kullanıcı giriş yapmışsa).
          else if (authProvider.mevcutKullaniciId != null) {
            // İsteğe bağlı: Giriş yapıldığında NavigasyonProvider'ı sıfırlayarak
            // ana sayfanın her zaman ilk sekmeden başlaması sağlanabilir.
            // Ancak bu, kullanıcının kaldığı sekmeyi hatırlamasını engeller.
            // Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(0);
            return const AnaSayfaYoneticisi(); // Ana ekran yöneticisini göster.
          }
          // Kullanıcı giriş yapmamışsa.
          else {
            return const LoginEkrani(); // Login ekranını göster.
          }
        },
      ),
    );
  }
}
