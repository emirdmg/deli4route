import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/core/theme/app_borders.dart';
import 'package:deli4route/features/navigation/pages/app_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppShell()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
    }
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
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    enabledBorder: AppBorders.enabled,
                    focusedBorder: AppBorders.focused,
                    errorBorder: AppBorders.error,
                    focusedErrorBorder: AppBorders.focusedError,
                    labelText: 'E-mail',
                    labelStyle: TextStyle(
                      color: AppColors.inactiveButtonColor
                      
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta bos olamaz';
                    }
                    if (!value.contains('@')) {
                      return 'Gecerli bir e-posta gir.';
                    }
                    return null;
                  },
                ),
        
                const SizedBox(height: 16),
        
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: AppBorders.enabled,
                    focusedBorder: AppBorders.focused,
                    errorBorder: AppBorders.error,
                    focusedErrorBorder: AppBorders.focusedError,
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: AppColors.inactiveButtonColor
                    ),
                    border: const OutlineInputBorder(
                      
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sifre bos olamaz';
                    }
                    if (value.length < 6) {
                      return 'Sifre en az 6 karakter olmali.';
                    }
                    return null;
                  },
                ),
        
                const SizedBox(height: 8),
        
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      //Sifre yenileme sayfasi
                    },
                    child: const Text('Forgot your password?',
                    style: TextStyle(
                      color: AppColors.inactiveButtonColor
                    ),
                    ),
                  ),
                ),
        
                const SizedBox(height: 16),
        
                SizedBox(
                  width: 160,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activeDefaultButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)
                      )
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
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


// try {
//                       await FirebaseAuth.instance.signInWithEmailAndPassword(
//                         email: email,
//                         password: password,
//                       );
//                     } on FirebaseAuthException catch (e) {
//                       SnackBar(content: Text('Giris basarisiz'));
//                     }

