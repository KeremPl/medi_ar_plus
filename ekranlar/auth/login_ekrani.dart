// Flutter materyal tasarım kütüphanesini ve Provider paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Uygulama içi kimlik doğrulama (authentication) ve navigasyon provider'larını import eder.
import '../../providerlar/auth_provider.dart';
import '../../providerlar/navigasyon_provider.dart'; // Ana sayfaya yönlendirme sonrası ilk sekme ayarı için.
// Uygulama renklerini ve metin stillerini içeren sabit dosyalarını import eder.
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
// Kayıt ekranına ve ana sayfa yöneticisine yönlendirme için ilgili ekranları import eder.
import 'kayit_ekrani.dart';
import '../ana_sayfa_yonetici.dart';

/// [LoginEkrani], kullanıcıların mevcut hesaplarıyla uygulamaya giriş yapabileceği arayüzü sağlar.
/// Kullanıcı adı ve şifre alarak giriş işlemini gerçekleştirir.
/// Bu bir `StatefulWidget`'tır çünkü şifre alanının görünürlük durumunu yönetir.
class LoginEkrani extends StatefulWidget {
  /// Constructor.
  const LoginEkrani({super.key});

  /// Bu widget için state nesnesini oluşturur.
  @override
  State<LoginEkrani> createState() => _LoginEkraniState();
}

/// [LoginEkrani] için state yönetimini ve UI mantığını içeren sınıf.
class _LoginEkraniState extends State<LoginEkrani> {
  // Formun durumunu yönetmek için bir GlobalKey. Form validasyonu için kullanılır.
  final _formKey = GlobalKey<FormState>();
  // Form alanları için TextEditingController'lar.
  final _kullaniciAdiController = TextEditingController();
  final _sifreController = TextEditingController();
  // Şifre alanının görünürlük durumunu tutan boolean değişken.
  bool _sifreGizli = true;

  /// Widget ağaçtan kaldırıldığında çağrılır.
  /// Controller'ların dispose edilmesi, olası hafıza sızıntılarını önler.
  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  /// Kullanıcı giriş işlemini başlatan asenkron metot.
  Future<void> _login() async {
    // Formun geçerli olup olmadığını kontrol eder.
    if (_formKey.currentState!.validate()) {
      // AuthProvider'a erişim sağlar (dinleme yapmadan).
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // AuthProvider üzerinden giriş işlemini çağırır.
      bool basarili = await authProvider.login(
        _kullaniciAdiController.text.trim(), // Baştaki ve sondaki boşlukları kaldırır.
        _sifreController.text,
      );
      // `mounted` kontrolü, widget hala ağaçtaysa UI güncellemesi yapılmasını sağlar.
      if (mounted) {
        if (basarili) { // Giriş başarılıysa.
          // NavigasyonProvider aracılığıyla ana sayfada ilk açılacak sekme (0. index, örn: AR) ayarlanır.
          Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(0);
          // Kullanıcıyı AnaSayfaYoneticisi'ne yönlendirir ve geri dönüş yolunu kapatır (pushReplacement).
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AnaSayfaYoneticisi()),
          );
        } else { // Giriş başarısız oldu.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.hataMesaji ?? 'Giriş bilinmeyen bir nedenle başarısız oldu.'),
              backgroundColor: Renkler.hataRengi, // Hata rengi.
            ),
          );
        }
      }
    }
  }

  /// Bu widget'ın UI'ını oluşturur.
  @override
  Widget build(BuildContext context) {
    // AuthProvider'a erişim sağlar (dinleme yaparak, isLoading durumu için).
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // SafeArea, ekranın çentik, kamera deliği gibi sistem arayüzü elemanlarının altına
      // içeriğin taşmamasını sağlar.
      body: SafeArea(
        child: Center( // İçeriği dikey ve yatay olarak ortalar.
          child: SingleChildScrollView( // İçerik ekrana sığmazsa kaydırılabilir olmasını sağlar.
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0), // Yatay ve dikey dolgu.
            child: Form( // Form widget'ı.
              key: _formKey,
              child: Column( // Form elemanlarını dikey bir sütun halinde düzenler.
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Uygulama başlığı.
                  Text(
                    'MediAR+ Hoş Geldiniz!',
                    style: MetinStilleri.ekranBasligi.copyWith(color: Renkler.anaMetinRengi),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0), // Başlık ile form alanları arasına boşluk.

                  // Kullanıcı Adı için TextFormField.
                  TextFormField(
                    controller: _kullaniciAdiController,
                    decoration: const InputDecoration( // const eklendi, çünkü içeriği statik.
                      labelText: 'Kullanıcı Adı',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) { // Alan boş bırakılamaz.
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen kullanıcı adınızı girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0), // Alanlar arasına boşluk.

                  // Şifre için TextFormField.
                  TextFormField(
                    controller: _sifreController,
                    decoration: InputDecoration( // SuffixIcon dinamik olduğu için bu const olamaz.
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline), // const eklendi.
                      suffixIcon: IconButton( // Şifreyi gösterme/gizleme ikonu.
                        icon: Icon(
                          _sifreGizli ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _sifreGizli = !_sifreGizli), // Durumu değiştirir.
                      ),
                    ),
                    obscureText: _sifreGizli, // Şifreyi gizler/gösterir.
                    validator: (value) { // Şifre boş bırakılamaz.
                      if (value == null || value.isEmpty) {
                        return 'Lütfen şifrenizi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0), // Şifre alanı ile buton arasına boşluk.

                  // Giriş butonu. AuthProvider'daki `isLoading` durumuna göre ya buton ya da yükleme göstergesi gösterilir.
                  authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator()) // Yükleniyorsa.
                      : ElevatedButton( // Yüklenmiyorsa.
                          onPressed: _login, // Tıklandığında _login metodunu çağırır.
                          child: Text('Giriş Yap', style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi)),
                        ),
                  const SizedBox(height: 16.0), // Buton ile link arasına boşluk.

                  // Kayıt ekranına yönlendirme linki.
                  TextButton(
                    onPressed: () {
                      // KayitEkrani'na yönlendirir.
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KayitEkrani()),
                      );
                    },
                    child: Text(
                      'Hesabın yok mu? Kayıt Ol',
                      style: MetinStilleri.linkMetni.copyWith(color: Renkler.vurguRenk),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
