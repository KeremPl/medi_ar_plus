# MediAR+ Flutter Uygulaması

Bu proje, ilk yardım eğitimleri ve testleri sunan bir Flutter uygulamasıdır.

## Özellikler
- Kullanıcı kaydı ve girişi
- Eğitim içeriklerini görüntüleme (adım adım)
- Eğitimlerle ilişkili testleri çözme
- Test sonuçlarına göre puan ve rozet kazanma
- Kullanıcı profili ve kazanılan rozetleri görüntüleme
- AR (Artırılmış Gerçeklik) modülü (ayrı bir ekip tarafından geliştirilecek)

## Kurulum
1. Flutter SDK'sını kurun.
2. Bu projeyi klonlayın.
3. `flutter pub get` komutunu çalıştırın.
4. Bir emülatör veya fiziksel cihazda `flutter run` komutu ile uygulamayı başlatın.

## Proje Yapısı
- `lib/`
  - `main.dart`: Uygulamanın giriş noktası.
  - `api/`: Backend API ile iletişim kuran servisler.
  - `ekranlar/`: Kullanıcı arayüzü ekranları.
    - `auth/`: Giriş, kayıt ekranları.
    - `egitim/`: Eğitim listesi, eğitim detayı, eğitim tamamlama ekranları.
    - `test/`: Test soruları, test sonuç ekranları.
    - `profil/`: Kullanıcı profili ekranı.
    - `ar/`: AR ekranı (ayrı geliştirilecek).
  - `modeller/`: API yanıtları ve uygulama içi veri yapıları için Dart sınıfları.
  - `providerlar/`: State management için Provider sınıfları.
  - `sabitler/`: Renkler, metin stilleri, asset yolları gibi sabit değerler.
  - `widgetlar/`: Tekrar kullanılabilir UI bileşenleri.
  - `utils/`: Yardımcı fonksiyonlar (ikon dönüştürücü vb.).
- `assets/`
  - `images/`: PNG, JPG gibi imaj dosyaları (API'den gelenler network üzerinden yüklenecek).
  - `svgs/`: SVG formatındaki ikonlar (API'den gelenler network üzerinden yüklenecek).
  - `fonts/`: Özel font dosyaları (gerekirse).
