// lib/screens/statistics/widgets/rating_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RatingChart extends StatelessWidget {
  final List<double> ratingHistory;

  const RatingChart({
    super.key,
    required this.ratingHistory,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: ratingHistory.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
