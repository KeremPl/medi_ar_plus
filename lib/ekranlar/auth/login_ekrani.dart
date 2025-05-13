import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providerlar/auth_provider.dart';
import '../../providerlar/navigasyon_provider.dart'; // Eklendi
import '../../sabitler/renkler.dart';
import '../../sabitler/metin_stilleri.dart';
import 'kayit_ekrani.dart';
import '../ana_sayfa_yonetici.dart';

class LoginEkrani extends StatefulWidget {
  const LoginEkrani({super.key});

  @override
  State<LoginEkrani> createState() => _LoginEkraniState();
}

class _LoginEkraniState extends State<LoginEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _kullaniciAdiController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _sifreGizli = true;

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool basarili = await authProvider.login(
        _kullaniciAdiController.text.trim(),
        _sifreController.text,
      );
      if (mounted) {
        if (basarili) {
          Provider.of<NavigasyonProvider>(context, listen: false).seciliIndexAta(0);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AnaSayfaYoneticisi()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.hataMesaji ?? 'Giriş başarısız oldu.'),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'MediAR+ Hoş Geldiniz!',
                    style: MetinStilleri.ekranBasligi.copyWith(color: Renkler.anaMetinRengi),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0),
                  TextFormField(
                    controller: _kullaniciAdiController,
                    decoration: const InputDecoration( // const eklendi
                      labelText: 'Kullanıcı Adı',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen kullanıcı adınızı girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _sifreController,
                    decoration: InputDecoration( // suffixIcon dinamik olduğu için burası const olamaz
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline), // const eklendi
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
                        return 'Lütfen şifrenizi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          child: Text('Giriş Yap', style: MetinStilleri.butonYazisi.copyWith(color: Renkler.butonYaziRengi)),
                        ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
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