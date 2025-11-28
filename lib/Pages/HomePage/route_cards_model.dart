import 'package:deli4route/Colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class MyRouteCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final VoidCallback? onTap;

  const MyRouteCard({
    super.key,
    required this.title,
    required this.subTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.activeDefaultButton,
            width: 1
          ),
          color: Colors.white,  // beyaz kutu
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50), // soft shadow
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Colors.black87,
              )
            ),
          ],
        ),
      ),
    );
  }
}

// fontSize: 14,
//                 color: Colors.black87,
//                 fontStyle: FontStyle.italic,