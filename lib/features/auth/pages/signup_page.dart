import 'package:deli4route/core/theme/app_borders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();



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
      body: Padding(
        padding: const EdgeInsets.all(16),
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
              
              SizedBox(height: 8,),

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
                    return 'Please enter a value.';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid e-mail.';
                  }
                  return null;
                },
              ),

              SizedBox(height: 8,),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
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
            ],
          ),
        ),
      )
    );
  }
}
