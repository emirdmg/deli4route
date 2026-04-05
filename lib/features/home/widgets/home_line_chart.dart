import 'package:deli4route/core/colors/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildLineChart() {
  return Container(
    height: 250,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weekly Deliveries",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(
                show: false,
              ), // Izgaraları gizle (Daha temiz durur)
              titlesData: const FlTitlesData(
                show: false,
              ), // Eksen yazılarını şimdilik gizleyelim
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 3),
                    const FlSpot(2, 5),
                    const FlSpot(4, 4),
                    const FlSpot(6, 8),
                    const FlSpot(8, 6),
                    const FlSpot(11, 7),
                  ],
                  isCurved: true, // Görseldeki o yumuşak dalga efekti
                  color: AppColors.activeDefaultButton, // Senin turuncu rengin
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false), // Noktaları gizle
                  belowBarData: BarAreaData(
                    show: true,
                    // Görseldeki o soft gölge efekti (Gradient)
                    gradient: LinearGradient(
                      colors: [
                        AppColors.activeDefaultButton.withOpacity(0.3),
                        AppColors.activeDefaultButton.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}