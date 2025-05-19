import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/auth_provider.dart'; // Kimlik doğrulama işlemleri için state management.
import '../../sabitler/renkler.dart'; // Uygulama genelinde kullanılan sabit renkler.
import '../../sabitler/metin_stilleri.dart'; // Uygulama genelinde kullanılan sabit metin stilleri.

/// [KayitEkrani] StatefulWidget'ı, kullanıcıların yeni bir hesap oluşturmasını sağlayan
/// kullanıcı arayüzünü ve iş mantığını yönetir.
///
/// Neden StatefulWidget?
/// Bu ekran, form girdilerinin değerlerini ([TextEditingController]lar aracılığıyla),
/// formun geçerlilik durumunu ([_formKey]), şifre alanlarının görünürlüğünü
/// ([_sifreGizli], [_sifreTekrarGizli]) ve API isteği sırasındaki yükleme durumunu
/// ([AuthProvider.isLoading] üzerinden dolaylı olarak) yönetir.
/// Bu tür içsel, değişebilir durumlar StatefulWidget kullanımını gerektirir.
class KayitEkrani extends StatefulWidget {
  /// [KayitEkrani] için varsayılan yapıcı metot.
  ///
  /// [key] parametresi, Flutter framework'ünün widget ağacındaki bu widget'ı
  /// verimli bir şekilde güncellemesi ve tanımlaması için kullanılır.
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

/// [_KayitEkraniState], [KayitEkrani] widget'ının durumunu yöneten sınıftır.
///
/// Bu sınıf, form elemanlarının kontrolörlerini, form anahtarını, şifre
/// görünürlük durumlarını ve kayıt olma işlevselliğini içerir.
class _KayitEkraniState extends State<KayitEkrani> {
  /// [_formKey], [Form] widget'ını benzersiz şekilde tanımlar ve formun durumuna
  /// (örneğin, geçerlilik durumu) erişmek ve yönetmek için kullanılır.
  /// [FormState] metotları ([validate], [save], [reset]) bu anahtar üzerinden çağrılır.
  /// **Niyeti:** Formun bütünlüğünü ve doğruluğunu merkezi bir noktadan yönetmek.
  final _formKey = GlobalKey<FormState>();

  // TextEditingController'lar, TextFormField widget'larındaki metin girdilerini
  // yönetmek, okumak ve temizlemek için kullanılır.
  // Her bir controller, widget ağacından kaldırıldığında bellek sızıntılarını
  // önlemek için `dispose()` metodunda temizlenmelidir.
  // **Niyeti:** Kullanıcı girdilerini programatik olarak kontrol etmek ve yönetmek.
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _kullaniciAdiController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();

  /// [_sifreGizli], şifre alanındaki metnin görünür olup olmadığını kontrol eder.
  /// `true` ise şifre gizlenir, `false` ise görünür olur.
  /// **Niyeti:** Kullanıcı deneyimini iyileştirmek ve şifre girişinde kolaylık sağlamak.
  bool _sifreGizli = true;

  /// [_sifreTekrarGizli], şifre tekrar alanındaki metnin görünür olup olmadığını kontrol eder.
  /// **Niyeti:** Şifre tekrarı girişinde de aynı kullanıcı deneyimini sunmak.
  bool _sifreTekrarGizli = true;

  /// [dispose] metodu, widget ağacından kalıcı olarak kaldırıldığında çağrılır.
  /// Bu metot içinde, oluşturulan [TextEditingController] örnekleri gibi kaynakların
  /// serbest bırakılması (dispose edilmesi) hayati önem taşır.
  /// **Niyeti:** Bellek sızıntılarını önlemek ve uygulama performansını korumak.
  /// Bu, "güvenilirlik" ve "kaynak yönetimi" açısından kritik bir adımdır.
  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _kullaniciAdiController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose(); // StatefulWidget'ın kendi dispose metodunu çağırmak önemlidir.
  }

  /// [_kayitOl] asenkron metodu, kullanıcının girdiği bilgilerle kayıt olma işlemini başlatır.
  ///
  /// İşlem adımları:
  /// 1. Formun geçerliliğini kontrol eder ([_formKey.currentState!.validate()]).
  /// 2. Geçerliyse, [AuthProvider] üzerinden kayıt API'sine istek gönderir.
  /// 3. API yanıtına göre kullanıcıya [SnackBar] ile geri bildirimde bulunur.
  /// 4. Başarılı kayıt durumunda bir önceki ekrana (genellikle Giriş Ekranı) döner.
  /// **Niyeti:** Kullanıcı girdilerini güvenli bir şekilde toplamak, doğrulamak ve
  /// kimlik doğrulama sistemi üzerinden yeni bir kullanıcı hesabı oluşturmak.
  Future<void> _kayitOl() async {
    // Formun geçerli olup olmadığını kontrol et. `validate()` metodu, tüm
    // TextFormField'lardaki `validator` fonksiyonlarını çalıştırır.
    // Eğer tüm validator'lar null dönerse (hata yoksa), `validate()` true döner.
    if (_formKey.currentState!.validate()) {
      // AuthProvider'a erişim. `listen: false` kullanılır çünkü bu metot içinde
      // AuthProvider'daki değişikliklere göre UI'ın yeniden build edilmesi beklenmez;
      // sadece bir eylem (kayıt metodu çağırma) gerçekleştirilir.
      // **Niyeti:** State management prensiplerine uygun şekilde eylemleri tetiklemek.
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // AuthProvider üzerinden kayıt işlemini başlat.
      // Controller'lardan alınan metinler `.trim()` ile başındaki ve sonundaki
      // olası boşluklardan arındırılır.
      // **Niyeti:** Veri temizliği ve tutarlılığı sağlamak, gereksiz boşlukların
      // API'ye gönderilmesini veya veritabanına kaydedilmesini engellemek.
      String? mesaj = await authProvider.register(
        _adController.text.trim(),
        _soyadController.text.trim(),
        _kullaniciAdiController.text.trim(),
        _emailController.text.trim(),
        _sifreController.text, // Şifrelerde trim() genellikle güvenlik nedeniyle önerilmez.
      );

      // Asenkron işlem (API çağrısı) tamamlandıktan sonra, widget'ın hala
      // widget ağacında olup olmadığını kontrol et (`mounted`). Eğer widget tree'den
      // kaldırılmışsa (örneğin kullanıcı ekranı terk etmişse) state güncellemesi
      // yapmak hataya yol açar.
      // **Niyeti:** Asenkron işlemler sonrası state güncellemelerinde "güvenilirlik" sağlamak.
      if (mounted) {
        if (mesaj != null) {
          // Kayıt başarılı mesajı alındıysa.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mesaj), // API'den gelen başarılı mesajı göster.
              backgroundColor: Renkler.basariRengi, // Başarı rengi tema'dan.
            ),
          );
          // Kayıt başarılı olduğunda, mevcut kayıt ekranını kapat ve
          // bir önceki ekrana (muhtemelen giriş ekranı) dön.
          // **Niyeti:** Kullanıcı akışını yönlendirmek.
          Navigator.pop(context);
        } else {
          // Kayıt başarısız olduysa veya API'den mesaj gelmediyse.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // AuthProvider'da bir hata mesajı varsa onu, yoksa genel bir hata mesajı göster.
              // `??` operatörü burada bir "fallback mekanizması" sağlar.
              // **Niyeti:** Kullanıcıya her durumda anlamlı bir hata geri bildirimi sunmak (hata toleransı).
              content: Text(authProvider.hataMesaji ?? 'Kayıt başarısız oldu.'),
              backgroundColor: Renkler.hataRengi, // Hata rengi tema'dan.
            ),
          );
        }
      }
    }
  }

  /// [build] metodu, widget'ın kullanıcı arayüzünü (UI) oluşturur.
  ///
  /// Bu metot, widget ilk oluşturulduğunda ve state'i her değiştiğinde
  /// (örneğin, `setState` çağrıldığında veya bağlı olduğu Provider güncellendiğinde)
  /// tekrar çalışır.
  @override
  Widget build(BuildContext context) {
    // AuthProvider'a erişim. `build` metodu içinde `listen: true` (varsayılan)
    // kullanılırsa, AuthProvider'daki değişiklikler (örn: `isLoading` durumu)
    // bu widget'ın yeniden çizilmesini tetikler.
    // Burada `authProvider.isLoading` kullanıldığı için `listen: true` olması uygundur.
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        // AppBar başlığı ve stili sabitlerden alınır.
        // **Niyeti:** Uygulama genelinde tutarlı bir görünüm sağlamak.
        title: Text('Kayıt Ol', style: MetinStilleri.appBarBaslik),
        // Geri butonu ve rengi sabitlerden.
        // **Niyeti:** Kullanıcının kolayca önceki ekrana dönebilmesini sağlamak (kullanıcı deneyimi).
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // `body` kısmını ortalamak için `Center` widget'ı.
      body: Center(
        // `SingleChildScrollView`, içeriğin ekran boyutundan taşması durumunda
        // (özellikle klavye açıldığında) kaydırılabilir bir alan sağlar.
        // **Niyeti:** Kullanıcı arayüzünün farklı ekran boyutlarında ve durumlarda
        // kullanılabilirliğini (usability) artırmak.
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          // Form widget'ı, içindeki TextFormField'ları gruplar ve yönetir.
          // `key` parametresine `_formKey` atanarak formun state'ine erişim sağlanır.
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // İçeriği dikeyde ortala.
              crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları yatayda genişlet.
              children: [
                // Ekran başlığı.
                Text(
                  'Hesap Oluştur',
                  style: MetinStilleri.ekranBasligi.copyWith(color: Renkler.anaMetinRengi),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0), // Boşluk için.

                // Ad Giriş Alanı
                TextFormField(
                  controller: _adController, // Metin girdisini yönetir.
                  decoration: InputDecoration(
                    labelText: 'Ad', // Alan etiketi.
                    prefixIcon: Icon(Icons.badge_outlined), // Alanın başında ikon.
                    // Diğer stil özellikleri (border, fillColor vb.) tema dosyasından gelir.
                  ),
                  // `validator`, girdi doğrulama kurallarını tanımlar.
                  // **Niyeti:** Kullanıcıdan geçerli ve beklenen formatta veri alınmasını sağlamak (girdi doğrulama).
                  // Bu, "veri bütünlüğü" ve "güvenlik" için önemlidir.
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen adınızı girin.'; // Boş olamaz.
                    }
                    return null; // `null` dönmesi, girdinin geçerli olduğu anlamına gelir.
                  },
                ),
                const SizedBox(height: 16.0),

                // Soyad Giriş Alanı
                TextFormField(
                  controller: _soyadController,
                  decoration: InputDecoration(
                    labelText: 'Soyad',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen soyadınızı girin.'; // Boş olamaz.
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Kullanıcı Adı Giriş Alanı
                TextFormField(
                  controller: _kullaniciAdiController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir kullanıcı adı seçin.';
                    }
                    if (value.trim().length < 3) {
                      // Ek bir kural: minimum karakter sayısı.
                      // **Niyeti:** Belirli iş kurallarına uygun veri toplamak.
                      return 'Kullanıcı adı en az 3 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Email Giriş Alanı
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'email@adresiniz.com', // Kullanıcıya format hakkında ipucu.
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress, // Klavye tipini email için optimize et.
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen email adresinizi girin.';
                    }
                    // Basit email format kontrolü. Daha kapsamlı bir regex kullanılabilir.
                    // **Niyeti:** Geçerli bir email formatı beklemek.
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Lütfen geçerli bir email adresi girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Şifre Giriş Alanı
                TextFormField(
                  controller: _sifreController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                    // Şifre görünürlüğünü değiştirmek için buton.
                    // **Niyeti:** Kullanıcı deneyimini iyileştirmek.
                    suffixIcon: IconButton(
                      icon: Icon(
                        _sifreGizli ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey[600], // İkon rengi.
                      ),
                      // Butona basıldığında `_sifreGizli` durumunu tersine çevir
                      // ve `setState` ile UI'ın güncellenmesini sağla.
                      onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                    ),
                  ),
                  obscureText: _sifreGizli, // `_sifreGizli` durumuna göre metni gizle/göster.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir şifre belirleyin.';
                    }
                    if (value.length < 6) {
                      // Şifre için minimum uzunluk kuralı.
                      // **Niyeti:** Güvenlik standartlarını uygulamak.
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Şifre Tekrar Giriş Alanı
                TextFormField(
                  controller: _sifreTekrarController,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _sifreTekrarGizli ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () => setState(() => _sifreTekrarGizli = !_sifreTekrarGizli),
                    ),
                  ),
                  obscureText: _sifreTekrarGizli,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi tekrar girin.';
                    }
                    // Girilen şifre tekrarının, ilk şifre alanındaki değerle
                    // eşleşip eşleşmediğini kontrol et.
                    // **Niyeti:** Kullanıcının şifresini doğru yazdığından emin olmak.
                    if (value != _sifreController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Yükleme Durumu ve Kayıt Butonu
                // `authProvider.isLoading` true ise `CircularProgressIndicator` göster,
                // değilse `ElevatedButton`'ı göster.
                // **Niyeti:** Kullanıcıya API isteği sırasında görsel geri bildirimde bulunmak.
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _kayitOl, // Butona basıldığında `_kayitOl` metodunu çağır.
                        // Buton stili tema dosyasından veya doğrudan burada özelleştirilebilir.
                        // Yazı stili ve rengi sabitlerden.
                        child: Text('Kayıt Ol', style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi)),
                      ),
                const SizedBox(height: 16.0),

                // Giriş Ekranına Yönlendirme Butonu
                TextButton(
                  onPressed: () {
                    // Kayıt ekranını kapat ve giriş ekranına dön.
                    Navigator.pop(context);
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