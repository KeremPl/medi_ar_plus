// Flutter foundation kütüphanesini (ChangeNotifier için) import eder.
import 'package:flutter/foundation.dart'; // ChangeNotifier sınıfı için.

/// [NavigasyonProvider], uygulamanın ana alt navigasyon çubuğundaki (BottomNavigationBar)
/// seçili olan sekmenin indeksini yöneten bir `ChangeNotifier` sınıfıdır.
/// Bu, farklı ekranlar arasında geçiş yapıldığında hangi sekmenin aktif olduğunu
/// takip etmek ve UI'ı buna göre güncellemek için kullanılır.
class NavigasyonProvider with ChangeNotifier {
  // State değişkeni:
  // Alt navigasyon çubuğundaki seçili olan sekmenin indeksi.
  // Varsayılan olarak ilk sekme (index 0) seçilidir.
  int _seciliIndex = 0;

  // Getter (UI'ın seçili indekse erişmesi için):
  int get seciliIndex => _seciliIndex;

  /// Seçili olan sekmenin indeksini günceller.
  ///
  /// Parametreler:
  ///   [index]: Yeni seçilecek sekmenin indeksi.
  ///
  /// Eğer yeni index mevcut indeksten farklıysa, `_seciliIndex` güncellenir
  /// ve `notifyListeners()` çağrılarak UI'ın yeniden çizilmesi sağlanır.
  /// Bu, gereksiz UI güncellemelerini önler.
  void seciliIndexAta(int index) {
    if (_seciliIndex != index) {
      _seciliIndex = index;
      notifyListeners(); // Değişikliği UI'a bildirir.
    }
  }
}
