// Flutter foundation kütüphanesini (ChangeNotifier için) ve SharedPreferences paketini import eder.
import 'package:flutter/foundation.dart'; // ChangeNotifier sınıfı için.
import 'package:shared_preferences/shared_preferences.dart'; // Kullanıcı ID'sini okumak ve belki test state'ini kaydetmek için.
// Uygulama içi API servisini ve ilgili modelleri import eder.
import '../api/api_servisi.dart';
import '../modeller/soru_model.dart';
import '../modeller/rozet_model.dart';

/// [TestProvider], bir testin sorularını, kullanıcının cevaplarını, test ilerlemesini
/// ve test sonucunu yöneten bir `ChangeNotifier` sınıfıdır.
/// API'den test sorularını çeker, kullanıcı cevaplarını kaydeder, testi bitirir
/// ve sonucu (puan, kazanılan rozetler) API'ye gönderip alır.
class TestProvider with ChangeNotifier {
  // API isteklerini yapmak için ApiServisi örneği.
  final ApiServisi _apiServisi = ApiServisi();
  // SharedPreferences örneği, constructor ile enjekte edilir (örn: kullanıcı ID'sini almak için).
  final SharedPreferences _prefs;

  // State değişkenleri:
  TestSorularModel? _testSorulariModel; // Yüklenen testin sorularını ve adını tutar. Null olabilir.
  bool _isLoading = false; // Test soruları yüklenirken true olur.
  String? _hataMesaji; // İşlemler sırasında bir hata oluştuysa hata mesajını tutar. Null olabilir.
  int _mevcutSoruIndex = 0; // Gösterilmekte olan sorunun indeksi (0'dan başlar).
  Map<int, int> _verilenCevaplar = {}; // Kullanıcının sorulara verdiği cevapları tutar (soruId -> cevapId).
  String? _sonucPuan; // Test bittikten sonra API'den alınan puanı tutar. Null olabilir.
  List<RozetModel> _kazanilanRozetler = []; // Test sonucu kazanılan yeni rozetleri tutar.
  bool _testSonucuYukleniyor = false; // Test sonucu API'ye gönderilirken/alınırken true olur.

  /// [TestProvider] constructor'ı.
  /// SharedPreferences örneğini alır.
  TestProvider(this._prefs);

  // Getter'lar (UI'ın state'e erişmesi için):
  TestSorularModel? get testSorulariModel => _testSorulariModel;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;
  int get mevcutSoruIndex => _mevcutSoruIndex;
  Map<int, int> get verilenCevaplar => _verilenCevaplar;

  /// Mevcut gösterilen soruyu döndürür.
  /// Eğer test soruları yüklenmemişse ya da index geçersizse null döner.
  SoruModel? get mevcutSoru {
    if (_testSorulariModel != null &&
        _testSorulariModel!.sorular.isNotEmpty &&
        _mevcutSoruIndex >= 0 && // Güvenlik kontrolü: index negatif olmamalı.
        _mevcutSoruIndex < _testSorulariModel!.sorular.length) { // Güvenlik kontrolü: index sınırlar içinde olmalı.
      return _testSorulariModel!.sorular[_mevcutSoruIndex];
    }
    return null; // Geçerli bir soru bulunamazsa.
  }

  /// Mevcut sorunun testteki son soru olup olmadığını kontrol eder.
  bool get sonSorudaMi {
    if (_testSorulariModel == null || _testSorulariModel!.sorular.isEmpty) {
      return false; // Soru yoksa veya yüklenmemişse son soruda olamaz.
    }
    return _mevcutSoruIndex == _testSorulariModel!.sorular.length - 1;
  }

  String? get sonucPuan => _sonucPuan;
  List<RozetModel> get kazanilanRozetler => _kazanilanRozetler;
  bool get testSonucuYukleniyor => _testSonucuYukleniyor;

  /// `PageView` gibi bir widget'tan gelen sayfa (soru) değişikliği olayını işler.
  /// `_mevcutSoruIndex`'i yeni indekse ayarlar, eğer gerçekten değişmişse UI'ı günceller.
  void setMevcutSoruIndex(int newIndex) {
    if (_testSorulariModel != null && newIndex >= 0 && newIndex < _testSorulariModel!.sorular.length) {
      // Sadece index gerçekten değiştiyse notifyListeners çağrılır, gereksiz rebuild'leri önler.
      if (_mevcutSoruIndex != newIndex) {
        _mevcutSoruIndex = newIndex;
        notifyListeners();
      }
    }
  }

  /// Belirli bir `testId`'ye sahip testin sorularını API'den asenkron olarak çeker.
  /// Bu işlem öncesinde mevcut test state'ini (sorular, cevaplar, puan vb.) sıfırlar.
  Future<void> testSorulariniGetir(int testId) async {
    // Geliştirme için loglama: Metodun hangi test ID'si için çağrıldığını gösterir.
    // print('[TestProvider] testSorulariniGetir çağrıldı. ID: $testId');
    _isLoading = true;
    _hataMesaji = null;
    // Yeni bir test yüklenirken önceki testle ilgili tüm state'i temizle.
    _testSorulariModel = null;
    _mevcutSoruIndex = 0;
    _verilenCevaplar = {};
    _sonucPuan = null;
    _kazanilanRozetler = [];
    notifyListeners(); // Yükleme başladığını ve state'in sıfırlandığını UI'a bildirir.

    try {
      // ApiServisi üzerinden test sorularını çeker.
      _testSorulariModel = await _apiServisi.getTestSorular(testId);
    } catch (e) {
      // Hata oluşursa, hata mesajını ayıklar ve kaydeder.
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false; // Yükleme bitti.
    notifyListeners(); // Yükleme bittiğini ve verinin geldiğini/hata olduğunu UI'a bildirir.
  }

  /// Kullanıcının bir soruya verdiği cevabı kaydeder.
  /// `_verilenCevaplar` map'ini günceller ve UI'ı bilgilendirir.
  void cevapVer(int soruId, int cevapId) {
    _verilenCevaplar[soruId] = cevapId;
    notifyListeners(); // Cevap değişikliğini UI'a bildirir (örn: seçili radyo butonunu güncellemek için).
  }

  /// Mevcut sorudan bir sonraki soruya geçer.
  /// Eğer son soruda değilse `_mevcutSoruIndex`'i artırır ve UI'ı günceller.
  void sonrakiSoruyaGec() {
    if (_testSorulariModel != null &&
        _mevcutSoruIndex < _testSorulariModel!.sorular.length - 1) {
      _mevcutSoruIndex++;
      notifyListeners(); // Soru değişikliğini UI'a bildirir.
    }
  }

  /// Testi bitirir, kullanıcının cevaplarına göre doğru/yanlış sayısını hesaplar,
  /// sonucu API'ye gönderir ve API'den dönen puanı ve kazanılan rozetleri alır.
  Future<void> testiBitir(int testId) async {
    // Eğer test soruları yüklenmemişse işlem yapma.
    if (_testSorulariModel == null) return;

    _testSonucuYukleniyor = true;
    _hataMesaji = null;
    _sonucPuan = null; // Önceki sonuçları temizle.
    _kazanilanRozetler = []; // Önceki kazanılan rozetleri temizle.
    // `notifyListeners()` burada çağrılabilir, ancak hemen aşağıda zaten çağrılacak.

    // Doğru ve yanlış cevap sayılarını hesapla.
    int dogruSayisi = 0;
    int yanlisSayisi = 0;
    for (var soru in _testSorulariModel!.sorular) {
      int? kullaniciCevapId = _verilenCevaplar[soru.soruId];
      if (kullaniciCevapId != null) {
        // Cevap modelindeki `dogruMu` alanına göre kontrol et.
        bool dogruMu = soru.cevaplar.any((c) => c.cevapId == kullaniciCevapId && c.dogruMu);
        if (dogruMu) {dogruSayisi++;} else {yanlisSayisi++;}
      } else {
        // Cevaplanmamış sorular yanlış kabul edilir.
        yanlisSayisi++;
      }
    }

    // SharedPreferences'tan mevcut kullanıcı ID'sini al.
    final int? kullaniciId = _prefs.getInt('mevcutKullaniciId');
    if (kullaniciId == null) {
      _hataMesaji = "Kullanıcı oturumu bulunamadı. Sonuç kaydedilemedi.";
      _testSonucuYukleniyor = false;
      notifyListeners();
      return; // Kullanıcı ID'si yoksa işlemi sonlandır.
    }

    try {
      // ApiServisi üzerinden test sonucunu API'ye gönderir.
      final sonuc = await _apiServisi.submitTestSonuc(kullaniciId, testId, dogruSayisi, yanlisSayisi);
      _sonucPuan = sonuc['puan']?.toString(); // API'den gelen puanı alır.
      // API'den 'kazanilan_rozetler_detayli' listesi gelmişse, bunları RozetModel'e dönüştürür.
      if (sonuc['kazanilan_rozetler_detayli'] != null) {
        _kazanilanRozetler = (sonuc['kazanilan_rozetler_detayli'] as List)
            .map((r) => RozetModel.fromTestSonuc(r)) // Test sonucu API'sine uygun fabrika metodu kullanılır.
            .toList();
      }
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _testSonucuYukleniyor = false; // Sonuç yükleme işlemi bitti.
    notifyListeners(); // Sonucu ve olası hatayı UI'a bildirir.
  }

  /// Provider'ın tüm state'ini başlangıç durumuna sıfırlar.
  /// Bu, yeni bir teste başlarken veya test ekranından çıkılırken çağrılır.
  void resetState() {
     _testSorulariModel = null;
     _mevcutSoruIndex = 0;
     _verilenCevaplar = {};
     _sonucPuan = null;
     _kazanilanRozetler = [];
     _hataMesaji = null;
     _isLoading = false;
     _testSonucuYukleniyor = false;
     // Geliştirme için loglama: State'in resetlendiğini belirtir.
     // print('[TestProvider] State resetlendi.');
     notifyListeners(); // UI'ın bu temizlenmiş durumu yansıtması için.
  }
}
