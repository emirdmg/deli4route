import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/core/theme/app_borders.dart';
import 'package:deli4route/features/auth/pages/reset-password/verify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
                    labelStyle: TextStyle(color: AppColors.inactiveButtonColor),
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
                      if (_formKey.currentState!.validate()) {
                        print("Navigating to VerifyPage...");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (builder) => VerifyPage()),
                        );
                      }
                      // Maile kod gönderimi
                    },
                    child: const Text(
                      'Send a code',
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
