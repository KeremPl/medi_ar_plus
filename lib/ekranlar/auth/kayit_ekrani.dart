import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/auth_provider.dart';
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _kullaniciAdiController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();
  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;

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

  Future<void> _kayitOl() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? mesaj = await authProvider.register(
        _adController.text.trim(),
        _soyadController.text.trim(),
        _kullaniciAdiController.text.trim(),
        _emailController.text.trim(),
        _sifreController.text,
      );

      if (mounted) {
        if (mesaj != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mesaj),
              backgroundColor: Renkler.basariRengi,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.hataMesaji ?? 'Kayıt başarısız oldu.'),
              backgroundColor: Renkler.hataRengi,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Ol', style: MetinStilleri.appBarBaslik), // Tema'dan
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Renkler.ikonRengi), // Tema'dan
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hesap Oluştur', // ar_medic'teki gibi
                  style: MetinStilleri.ekranBasligi.copyWith(color: Renkler.anaMetinRengi),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _adController,
                  decoration: InputDecoration(
                    labelText: 'Ad',
                    prefixIcon: Icon(Icons.badge_outlined), // Tema'dan renk alır
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen adınızı girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _soyadController,
                  decoration: InputDecoration(
                    labelText: 'Soyad',
                     prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen soyadınızı girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
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
                       return 'Kullanıcı adı en az 3 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'email@adresiniz.com', // ar_medic'teki gibi
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
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
                TextFormField(
                  controller: _sifreController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _sifreGizli ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                    ),
                  ),
                  obscureText: _sifreGizli,
                  validator: (value) {
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
                    if (value != _sifreController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _kayitOl,
                        // style: ElevatedButton.styleFrom( // Tema'dan gelecek
                        //   padding: const EdgeInsets.symmetric(vertical: 16.0),
                        // ),
                        child: Text('Kayıt Ol', style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi)),
                      ),
                 const SizedBox(height: 16.0), // ar_medic'te bu boşluk vardı
                 TextButton(
                   onPressed: () {
                     Navigator.pop(context); // ar_medic
                   },
                   child: Text(
                     'Zaten hesabın var mı? Giriş Yap',
                     style: MetinStilleri.linkMetni.copyWith(color: Renkler.vurguRenk), // ar_medic
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
