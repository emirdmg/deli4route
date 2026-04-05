import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deli4route/features/home/widgets/home_line_chart.dart';
import 'package:deli4route/features/home/widgets/stat_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  Stream<DocumentSnapshot> getUserStream() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: getUserStream(), // Future yerine Stream verdik
      builder: (context, snapshot) {
        // 1. Durum: Yükleniyor
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Durum: Hata veya Veri Yok
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Kullanıcı verisi bulunamadı.")),
          );
        }

        // 3. Durum: Veri Geldi - Hesaplamaları BURADA yapıyoruz
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String name = data['name'] ?? "Sürücü";
        final double perPackageFee = (data['per_package_fee'] ?? 0).toDouble();
        final int completedDeliveries = data['completed_deliveries'] ?? 0;
        final String currency = data['currency'] ?? "₺";
        final double totalEarnings = perPackageFee * completedDeliveries;

        return Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome $name",
                  style: GoogleFonts.playwriteUsModern(fontSize: 28),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. HAFTALIK GRAFİK
                buildLineChart(),

                const SizedBox(height: 20),

                // 2. ANALİZ KARTLARI
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    buildSmallStatCard(
                      "Toplam Kazanç",
                      "$currency${totalEarnings.toStringAsFixed(0)}",
                      Icons.monetization_on_outlined,
                      Colors.green,
                    ),
                    buildSmallStatCard(
                      "Teslimat",
                      "$completedDeliveries",
                      Icons.local_shipping,
                      Colors.blue,
                    ),
                    buildSmallStatCard(
                      "Mesafe",
                      "145km",
                      Icons.route,
                      Colors.purple,
                    ),
                    buildSmallStatCard(
                      "Saat",
                      "32h",
                      Icons.access_time,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
