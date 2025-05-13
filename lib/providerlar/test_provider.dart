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
  SoruModel? get mevcutSoru { /* ... getter içeriği aynı ... */ }
  bool get sonSorudaMi { /* ... getter içeriği aynı ... */ }
  String? get sonucPuan => _sonucPuan;
  List<RozetModel> get kazanilanRozetler => _kazanilanRozetler;
  bool get testSonucuYukleniyor => _testSonucuYukleniyor;
  void setMevcutSoruIndex(int newIndex) { /* ... metod içeriği aynı ... */ }

  Future<void> testSorulariniGetir(int testId) async {
    print('[TestProvider] testSorulariniGetir çağrıldı. ID: $testId');
    _isLoading = true;
    _hataMesaji = null;
    // resetState() zaten bu değerleri sıfırlıyor, burada tekrar etmeye gerek yok eğer resetState çağrılacaksa.
    // Ama testSorulariniGetir direkt çağrılırsa sıfırlama önemli.
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

  void cevapVer(int soruId, int cevapId) { /* ... (içerik aynı) ... */ }
  void sonrakiSoruyaGec() { /* ... (içerik aynı) ... */ }
  Future<void> testiBitir(int testId) async { /* ... (içerik aynı) ... */ }

  void resetState() {
     _testSorulariModel = null;
     _mevcutSoruIndex = 0;
     _verilenCevaplar = {};
     _sonucPuan = null;
     _kazanilanRozetler = [];
     _hataMesaji = null;
     _isLoading = false;
     _testSonucuYukleniyor = false;
     print('[TestProvider] State resetlendi.');
     notifyListeners();
  }
}
