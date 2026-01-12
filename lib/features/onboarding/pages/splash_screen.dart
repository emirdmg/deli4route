import 'package:deli4route/features/navigation/pages/app_shell.dart';
import 'package:deli4route/features/onboarding/pages/welcome_page.dart';
// AppShell dosyanın yolunu buraya eklemeyi unutma
// import 'package:deli4route/features/home/pages/app_shell.dart'; 
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  // Navigasyon mantığını ayrı bir fonksiyona aldık
  Future<void> _handleNavigation() async {
    // 1. Lottie animasyonunun keyfini sürmek için 3 saniye bekle
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 2. Cihaz hafızasından giriş bilgisini kontrol et
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // 3. Hangi sayfaya gidileceğine karar ver
    Widget nextWidget = isLoggedIn ? const AppShell() : const WelcomePage();

    // 4. Geçiş efektini koruyarak yönlendir
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: nextWidget,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/splash.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}