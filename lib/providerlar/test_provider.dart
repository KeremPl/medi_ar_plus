import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_servisi.dart';
import '../modeller/soru_model.dart';
import '../modeller/rozet_model.dart';

class TestProvider with ChangeNotifier {
  final ApiServisi _apiServisi = ApiServisi();
  final SharedPreferences _prefs;

  TestSorularModel? _testSorulariModel;
  bool _isLoading = false;
  String? _hataMesaji;
  int _mevcutSoruIndex = 0;
  Map<int, int> _verilenCevaplar = {};

  String? _sonucPuan;
  List<RozetModel> _kazanilanRozetler = [];
  bool _testSonucuYukleniyor = false;

  TestProvider(this._prefs);

  TestSorularModel? get testSorulariModel => _testSorulariModel;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;
  int get mevcutSoruIndex => _mevcutSoruIndex;
  Map<int, int> get verilenCevaplar => _verilenCevaplar;

  SoruModel? get mevcutSoru =>
      _testSorulariModel != null &&
      _testSorulariModel!.sorular.isNotEmpty &&
      _mevcutSoruIndex < _testSorulariModel!.sorular.length
          ? _testSorulariModel!.sorular[_mevcutSoruIndex]
          : null;

  bool get sonSorudaMi =>
      _testSorulariModel != null &&
      _mevcutSoruIndex == _testSorulariModel!.sorular.length - 1;

  String? get sonucPuan => _sonucPuan;
  List<RozetModel> get kazanilanRozetler => _kazanilanRozetler;
  bool get testSonucuYukleniyor => _testSonucuYukleniyor;

  // Yeni metot: PageView'dan gelen index ile mevcut soruyu güncellemek için
  void setMevcutSoruIndex(int newIndex) {
    if (_testSorulariModel != null && newIndex >= 0 && newIndex < _testSorulariModel!.sorular.length) {
      if (_mevcutSoruIndex != newIndex) {
        _mevcutSoruIndex = newIndex;
        notifyListeners(); // UI'ın güncellenmesi için
      }
    }
  }

  Future<void> testSorulariniGetir(int testId) async {
    _isLoading = true;
    _hataMesaji = null;
    _testSorulariModel = null;
    _mevcutSoruIndex = 0;
    _verilenCevaplar = {};
    _sonucPuan = null;
    _kazanilanRozetler = [];
    notifyListeners();
    try {
      _testSorulariModel = await _apiServisi.getTestSorular(testId);
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _isLoading = false;
    notifyListeners();
  }

  void cevapVer(int soruId, int cevapId) {
    _verilenCevaplar[soruId] = cevapId;
    notifyListeners();
  }

  void sonrakiSoruyaGec() {
    if (_testSorulariModel != null &&
        _mevcutSoruIndex < _testSorulariModel!.sorular.length - 1) {
      _mevcutSoruIndex++;
      notifyListeners();
    }
  }

  Future<void> testiBitir(int testId) async {
    if (_testSorulariModel == null) return;

    _testSonucuYukleniyor = true;
    _hataMesaji = null;
    _sonucPuan = null;
    _kazanilanRozetler = [];
    // notifyListeners(); // Bu metodun başında zaten yükleme durumu değişiyor

    int dogruSayisi = 0;
    int yanlisSayisi = 0;

    for (var soru in _testSorulariModel!.sorular) {
      int? kullaniciCevapId = _verilenCevaplar[soru.soruId];
      if (kullaniciCevapId != null) {
        bool dogruMu = false;
        for (var cevap in soru.cevaplar) {
          if (cevap.cevapId == kullaniciCevapId && cevap.dogruMu) {
            dogruMu = true;
            break;
          }
        }
        if (dogruMu) {
          dogruSayisi++;
        } else {
          yanlisSayisi++;
        }
      } else {
        yanlisSayisi++;
      }
    }

    final int? kullaniciId = _prefs.getInt('mevcutKullaniciId');
    if (kullaniciId == null) {
      _hataMesaji = "Kullanıcı oturumu bulunamadı.";
      _testSonucuYukleniyor = false;
      notifyListeners();
      return;
    }

    try {
      final sonuc = await _apiServisi.submitTestSonuc(
          kullaniciId, testId, dogruSayisi, yanlisSayisi);
      _sonucPuan = sonuc['puan']?.toString();
      if (sonuc['kazanilan_rozetler_detayli'] != null) {
        _kazanilanRozetler = (sonuc['kazanilan_rozetler_detayli'] as List)
            .map((r) => RozetModel.fromTestSonuc(r))
            .toList();
      }
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
    }
    _testSonucuYukleniyor = false;
    notifyListeners();
  }

  void testiSifirla() {
     _testSorulariModel = null;
     _mevcutSoruIndex = 0;
     _verilenCevaplar = {};
     _sonucPuan = null;
     _kazanilanRozetler = [];
     _hataMesaji = null;
     _isLoading = false;
     _testSonucuYukleniyor = false;
  }
}
