import 'dart:async';

import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/features/auth/pages/reset-password/new_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  bool _isResendActive = true;
  Timer? _timer;
  int _start = 20;
  String pin = "";

  void startTimer() {
    setState(() {
      _isResendActive = false; // Sayaç başladığında butonu pasif yap
      _start = 20; // Her başladığında 20'ye resetle
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendActive = true; // Süre bittiğinde butonu aktif yap
          timer.cancel(); // Sayacı durdur
        });
      } else {
        setState(() {
          _start--; // Her saniye bir azalt
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.blue, width: 2),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 220,
              child: SvgPicture.asset('assets/login.svg', fit: BoxFit.contain),
            ),

            SizedBox(height: 20),

            Text(
              'Please enter vertification code',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 20),

            Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              onCompleted: (value) {
                setState(() {
                  pin = value;
                });
                // Kod tamamlandığında API'ye gönderilecek fonksiyon
                print("Girilen Kod: $pin");
              },
              keyboardType: TextInputType.number,
              autofocus: true,
            ),

            SizedBox(height: 20),

            TextButton(
              onPressed: _isResendActive
                  ? () {
                      startTimer(); // Sayacı başlat
                      // Buraya API'den kodu tekrar gönderen fonksiyonunu ekle
                      print("Kod tekrar gönderiliyor...");
                    }
                  : null, // Aktif değilse tıklanamaz
              child: Text(
                _isResendActive
                    ? 'Resend'
                    : 'Resend in $_start s', // 20, 19, 18... diye azalır
                style: TextStyle(
                  color: _isResendActive
                      ? AppColors.activeDefaultButton
                      : AppColors.inactiveButtonColor,
                  decoration: TextDecoration.underline,
                  decorationColor: _isResendActive
                      ? AppColors.activeDefaultButton
                      : Colors.transparent,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 160,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeDefaultButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (pin.length == 6) {
                    if (pin == '000000') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (builder) => NewPassword()),
                      );
                      print('Başarılı');
                      // nav push yeni sifre ekrani
                    } else {
                      print('Hatalı kod');
                    }
                  } else {
                    print('Lütfen 6 haneli kodu tamamlayın.');
                  }
                },
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
