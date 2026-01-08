import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/core/theme/app_borders.dart';
import 'package:deli4route/features/auth/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final _passwordController = TextEditingController();
  final _passwordAgainController = TextEditingController();
  bool _isObscured = true;
  final _formKey = GlobalKey<FormState>();
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı animasyonu kapatamasın
      builder: (BuildContext context) {
        // Diyalog kapandığında çalışacak kod (örn: Giriş sayfasına git)
        Future.delayed(const Duration(seconds: 4), () {
          // 2 saniye bekle
          Navigator.of(context).pop(); // Diyaloğu kapat
          // TODO: Buraya giriş sayfasına yönlendirme kodunu ekle
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => LoginPage()),
          );
          print("Giriş sayfasına yönlendiriliyor...");
        });

        return Dialog(
          backgroundColor: Colors.transparent, // Arka planı şeffaf yap
          elevation: 0, // Gölgeyi kaldır
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white, // Beyaz bir kutu içinde göster
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Lottie.asset(
                'assets/successful_splash.json', // Senin JSON dosyanın yolu
                repeat: false, // Animasyon sadece bir kez oynasın
                // Animasyonun hızını ayarlayabilirsin (isteğe bağlı)
                // controller: _controller,
                // onLoaded: (composition) {
                //   _controller
                //     ..duration = composition.duration
                //     ..forward();
                // },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 220,
                  child: SvgPicture.asset(
                    'assets/login.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscured,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    suffix: Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        child: Icon(
                          _isObscured
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                        ),
                      ),
                    ),
                    enabledBorder: AppBorders.enabled,
                    focusedBorder: AppBorders.focused,
                    errorBorder: AppBorders.error,
                    focusedErrorBorder: AppBorders.focusedError,
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    if (value.length < 6) {
                      return 'Password must be min 6 characters.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordAgainController,
                  obscureText: _isObscured,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    enabledBorder: AppBorders.enabled,
                    focusedBorder: AppBorders.focused,
                    errorBorder: AppBorders.error,
                    focusedErrorBorder: AppBorders.focusedError,
                    labelText: 'Password Again',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == '' ||
                        value != _passwordController.text.trim()) {
                      return 'Passwords not match!';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 16),

                SizedBox(
                  width: 180,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activeDefaultButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showSuccessDialog();
                      }
                      // if (_formKey.currentState!.validate()) {
                      //   print("Navigating to VerifyPage...");
                      //   Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(builder: (builder) => VerifyPage()),
                      //   );
                      // }
                      // Maile kod gönderimi
                    },
                    child: const Text(
                      'Reset Password',
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
        ),
      ),
    );
  }
}
