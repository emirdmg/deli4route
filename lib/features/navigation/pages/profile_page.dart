import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/features/auth/pages/auth_landing_page.dart';
import 'package:deli4route/features/auth/pages/login_page.dart';
import 'package:deli4route/features/onboarding/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<DocumentSnapshot> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              LogoutService.showLogoutDialog(context);
            },
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text('Profile')],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.activeDefaultButton,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(75),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withAlpha(75),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: getUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("");
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text("");
                          }

                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final String name = data['name'];

                          return Text(
                            name,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          );
                        },
                      ),
                    ],
                    //name and surname
                  ),
                  Spacer(),
                  IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoutService {
  static Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Oturumu Kapat"),
        content: const Text("Çıkış yapmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // İptal: Diyaloğu kapat
            child: const Text("Vazgeç", style: TextStyle(color: AppColors.inactiveButtonColor),),
          ),
          TextButton(
            onPressed: () async {
              // 1. Firebase oturumunu kapat
              await FirebaseAuth.instance.signOut();

              // 2. Cihaz hafızasındaki giriş bilgisini sil
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);

              // 3. Diyaloğu kapat ve WelcomePage'e dön
              if (!context.mounted) return;

              // Tüm sayfaları temizleyerek WelcomePage'e gönderir
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthLandingPage()),
                (route) => false,
              );
            },
            child: const Text(
              "Çıkış Yap",
              style: TextStyle(color: AppColors.activeDefaultButton),
            ),
          ),
        ],
      ),
    );
  }
}
