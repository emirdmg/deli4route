import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/core/theme/app_borders.dart';
import 'package:deli4route/features/auth/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isActiveLoginButton = false;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordAgainController = TextEditingController();
  bool _isObscured = true;

  void showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> signUp() async {
    try {
      // 1️⃣ Auth - kullanıcı oluştur
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // 2️⃣ UID al
      final String uid = userCredential.user!.uid;

      // 3️⃣ Firestore - user profili yaz
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'surname': surnameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        isActiveLoginButton = true;
      });

      showSnackBar("Account created successfully 🎉");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showSnackBar("This email is already in use.", isError: true);
      } else if (e.code == 'weak-password') {
        showSnackBar("The password is too weak.", isError: true);
      } else if (e.code == 'invalid-email') {
        showSnackBar("The email address is not valid.", isError: true);
      } else {
        showSnackBar("Something went wrong. Please try again.", isError: true);
      }
    } catch (e) {
      showSnackBar("Unexpected error occurred.\n$e", isError: true);
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
              children: [
                SizedBox(
                  height: 220,
                  child: SvgPicture.asset(
                    'assets/signup.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    enabledBorder: AppBorders.enabled,
                    focusedBorder: AppBorders.focused,
                    errorBorder: AppBorders.error,
                    focusedErrorBorder: AppBorders.focusedError,
                    labelText: 'Name',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    if (value.length < 3) {
                      return 'Please enter a valid name.';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: surnameController,
                  decoration: InputDecoration(
                    enabledBorder: AppBorders.enabled,
                    focusedBorder: AppBorders.focused,
                    errorBorder: AppBorders.error,
                    focusedErrorBorder: AppBorders.focusedError,
                    labelText: 'Surname',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    if (value.length < 2) {
                      return 'Please enter a valid surname.';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    enabledBorder: AppBorders.enabled,
                    focusedBorder: AppBorders.focused,
                    errorBorder: AppBorders.error,
                    focusedErrorBorder: AppBorders.focusedError,
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter e-mail.';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid e-mail.';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: passwordController,
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

                SizedBox(height: 8),

                TextFormField(
                  controller: passwordAgainController,
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
                        value != passwordController.text.trim()) {
                      return 'Passwords not match!';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20),
                Visibility(
                  visible: !isActiveLoginButton,
                  child: SizedBox(
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
                          signUp();
                        }
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Visibility(
                  visible: isActiveLoginButton,
                  child: SizedBox(
                    height: 52,
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB4E50D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)
                        )
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (builder) => LoginPage()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
