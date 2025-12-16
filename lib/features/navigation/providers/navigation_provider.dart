import 'package:flutter_riverpod/legacy.dart';

// 1. Notifier Sınıfı: Bu sınıf "Logic" yani mantığı tutar.
class NavigationNotifier extends StateNotifier<int> {
  // Başlangıç değeri 0 (yani Home sekmesi)
  NavigationNotifier() : super(0);

  // İndeksi değiştiren metod
  void setIndex(int index) {
    state = index;
  }

  // Özel yönlendirme metodları
  void goToHome() => state = 0;
  void goToRoute() => state = 1;
  void goToHistory() => state = 2;
  void goToProfile() => state = 3;
}

// 2. Provider Tanımı: Bu değişken "Erişim Noktası"dır.
// Uygulamanın herhangi bir yerinden bu değişkene ulaşacağız.
final navigationProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
