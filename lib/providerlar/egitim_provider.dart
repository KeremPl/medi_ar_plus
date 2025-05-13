import 'package:flutter/foundation.dart';
import '../api/api_servisi.dart';
import '../modeller/egitim_model.dart';

class EgitimProvider with ChangeNotifier {
  final ApiServisi _apiServisi = ApiServisi();
  List<EgitimModel> _egitimler = [];
  bool _isLoading = false;
  String? _hataMesaji;

  List<EgitimModel> get egitimler => _egitimler;
  bool get isLoading => _isLoading;
  String? get hataMesaji => _hataMesaji;

  Future<void> egitimleriGetir() async {
    print('[EgitimProvider] egitimleriGetir çağrıldı.');
    _isLoading = true;
    _hataMesaji = null;
    // İlk yüklemede UI'ın hemen tepki vermesi için notifyListeners() eklenebilir,
    // ancak veri geldikten sonra tekrar çağrılacağı için zorunlu değil.
    // notifyListeners(); 
    try {
      _egitimler = await _apiServisi.getEgitimler();
      print('[EgitimProvider] Eğitimler başarıyla çekildi: ${_egitimler.length} adet.');
    } catch (e) {
      _hataMesaji = e.toString().replaceFirst("Exception: ", "");
      _egitimler = []; // Hata durumunda listeyi boşalt
      print('[EgitimProvider] Eğitimler çekilirken hata: $_hataMesaji');
    }
    _isLoading = false;
    notifyListeners();
  }

  void resetState() {
    _egitimler = [];
    _isLoading = false;
    _hataMesaji = null;
    print('[EgitimProvider] State resetlendi.');
    // Bu notifyListeners önemli, çünkü reset sonrası UI güncellenmeli.
    notifyListeners();
  }
}
