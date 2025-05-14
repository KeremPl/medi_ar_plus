// Flutter materyal tasarım kütüphanesini ve Provider paketini import eder.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Uygulama içi kimlik doğrulama (authentication) provider'ını import eder.
import '../../providerlar/auth_provider.dart';
// Uygulama renklerini ve metin stillerini içeren sabit dosyalarını import eder.
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';

/// [KayitEkrani], kullanıcıların yeni bir hesap oluşturabileceği arayüzü sağlar.
/// Ad, soyad, kullanıcı adı, email ve şifre gibi bilgileri alarak kayıt işlemini gerçekleştirir.
/// Bu bir `StatefulWidget`'tır çünkü form alanlarının durumunu (örn: şifre görünürlüğü) yönetir.
class KayitEkrani extends StatefulWidget {
  /// Constructor.
  const KayitEkrani({super.key});

  /// Bu widget için state nesnesini oluşturur.
  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

/// [KayitEkrani] için state yönetimini ve UI mantığını içeren sınıf.
class _KayitEkraniState extends State<KayitEkrani> {
  // Formun durumunu yönetmek için bir GlobalKey. Form validasyonu için kullanılır.
  final _formKey = GlobalKey<FormState>();
  // Form alanları için TextEditingController'lar. Alanlardaki metni okumak ve değiştirmek için kullanılır.
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _kullaniciAdiController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();

  // Şifre alanlarının görünürlük durumunu tutan boolean değişkenler.
  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;

  /// Widget ağaçtan kaldırıldığında çağrılır.
  /// Controller'ların dispose edilmesi, olası hafıza sızıntılarını önler.
  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _kullaniciAdiController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose();
  }

  /// Kullanıcı kayıt işlemini başlatan asenkron metot.
  Future<void> _kayitOl() async {
    // Formun geçerli olup olmadığını kontrol eder (tüm validator'lar başarılı mı?).
    if (_formKey.currentState!.validate()) {
      // AuthProvider'a erişim sağlar (dinleme yapmadan, sadece metot çağırmak için).
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // AuthProvider üzerinden kayıt işlemini çağırır.
      String? mesaj = await authProvider.register(
        _adController.text.trim(), // Baştaki ve sondaki boşlukları kaldırır.
        _soyadController.text.trim(),
        _kullaniciAdiController.text.trim(),
        _emailController.text.trim(),
        _sifreController.text, // Şifreler genellikle trim edilmez.
      );

      // `mounted` kontrolü, widget hala ağaçtaysa UI güncellemesi yapılmasını sağlar.
      // Asenkron işlemden sonra widget kaldırılmış olabilir.
      if (mounted) {
        if (mesaj != null) { // Kayıt başarılı ve API'den mesaj döndü.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mesaj),
              backgroundColor: Renkler.basariRengi, // Başarı rengi.
            ),
          );
          Navigator.pop(context); // Kayıt başarılıysa bir önceki ekrana (muhtemelen LoginEkranı) döner.
        } else { // Kayıt başarısız oldu.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.hataMesaji ?? 'Kayıt bilinmeyen bir nedenle başarısız oldu.'),
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
      appBar: AppBar(
        title: Text('Kayıt Ol', style: MetinStilleri.appBarBaslik), // AppBar başlığı. Tema'dan stil alır.
        leading: IconButton( // Geri butonu.
          icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi), // Tema'dan ikon rengi alır.
          onPressed: () => Navigator.of(context).pop(), // Bir önceki ekrana döner.
        ),
      ),
      body: Center( // İçeriği dikey ve yatay olarak ortalar.
        child: SingleChildScrollView( // İçerik ekrana sığmazsa kaydırılabilir olmasını sağlar.
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0), // Yatay ve dikey dolgu.
          child: Form( // Form widget'ı, TextFormField'ları gruplar ve validasyonu yönetir.
            key: _formKey, // Formun anahtarı.
            child: Column( // Form elemanlarını dikey bir sütun halinde düzenler.
              mainAxisAlignment: MainAxisAlignment.center, // Sütun içindeki elemanları dikeyde ortalar.
              crossAxisAlignment: CrossAxisAlignment.stretch, // Elemanları yatayda ekran genişliğine yayar.
              children: [
                // Ekran başlığı.
                Text(
                  'Hesap Oluştur',
                  style: MetinStilleri.ekranBasligi.copyWith(color: Renkler.anaMetinRengi),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0), // Başlık ile form alanları arasına boşluk.

                // Ad için TextFormField.
                TextFormField(
                  controller: _adController,
                  decoration: InputDecoration(
                    labelText: 'Ad',
                    prefixIcon: Icon(Icons.badge_outlined), // İkon, tema rengini alır.
                  ),
                  validator: (value) { // Alan boş bırakılamaz.
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen adınızı girin.';
                    }
                    return null; // Geçerli ise null döndürür.
                  },
                ),
                const SizedBox(height: 16.0), // Alanlar arasına boşluk.

                // Soyad için TextFormField.
                TextFormField(
                  controller: _soyadController,
                  decoration: InputDecoration(
                    labelText: 'Soyad',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) { // Alan boş bırakılamaz.
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen soyadınızı girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Kullanıcı Adı için TextFormField.
                TextFormField(
                  controller: _kullaniciAdiController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) { // Alan boş bırakılamaz ve minimum 3 karakter olmalı.
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir kullanıcı adı seçin.';
                    }
                    if (value.trim().length < 3) {
                      return 'Kullanıcı adı en az 3 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Email için TextFormField.
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'email@adresiniz.com', // Kullanıcıya yol gösterici metin.
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress, // Klavye tipini email için ayarlar.
                  validator: (value) { // Alan boş bırakılamaz ve geçerli bir email formatında olmalı.
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen email adresinizi girin.';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Lütfen geçerli bir email adresi girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Şifre için TextFormField.
                TextFormField(
                  controller: _sifreController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton( // Şifreyi gösterme/gizleme ikonu.
                      icon: Icon(
                        _sifreGizli ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey[600], // İkon rengi.
                      ),
                      onPressed: () => setState(() => _sifreGizli = !_sifreGizli), // Durumu değiştirir.
                    ),
                  ),
                  obscureText: _sifreGizli, // Şifreyi gizler/gösterir.
                  validator: (value) { // Şifre boş bırakılamaz ve minimum 6 karakter olmalı.
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir şifre belirleyin.';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Şifre Tekrar için TextFormField.
                TextFormField(
                  controller: _sifreTekrarController,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton( // Şifreyi gösterme/gizleme ikonu.
                      icon: Icon(
                        _sifreTekrarGizli ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () => setState(() => _sifreTekrarGizli = !_sifreTekrarGizli),
                    ),
                  ),
                  obscureText: _sifreTekrarGizli, // Şifreyi gizler/gösterir.
                  validator: (value) { // Şifre boş bırakılamaz ve ilk şifreyle eşleşmeli.
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi tekrar girin.';
                    }
                    if (value != _sifreController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0), // Şifre alanı ile buton arasına boşluk.

                // Kayıt butonu. AuthProvider'daki `isLoading` durumuna göre ya buton ya da yükleme göstergesi gösterilir.
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator()) // Yükleniyorsa.
                    : ElevatedButton( // Yüklenmiyorsa.
                        onPressed: _kayitOl, // Tıklandığında _kayitOl metodunu çağırır.
                        // Buton stili tema'dan gelir (ElevatedButtonThemeData).
                        // style: ElevatedButton.styleFrom(
                        //   padding: const EdgeInsets.symmetric(vertical: 16.0),
                        // ),
                        child: Text('Kayıt Ol', style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi)),
                      ),
                const SizedBox(height: 16.0), // Buton ile link arasına boşluk.

                // Giriş yap ekranına yönlendirme linki.
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Login ekranına geri döner.
                  },
                  child: Text(
                    'Zaten hesabın var mı? Giriş Yap',
                    style: MetinStilleri.linkMetni.copyWith(color: Renkler.vurguRenk),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
