import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/features/home/pages/create_route_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<DocumentSnapshot> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => CreateRoutePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(250, 70),
                backgroundColor: AppColors.activeDefaultButton,
              ),
              child: Text(
                'Create Route',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
