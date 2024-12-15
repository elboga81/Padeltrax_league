// lib/screens/statistics/widgets/recent_form_display.dart

import 'package:flutter/material.dart';
import 'package:padeltrax_app/models/match/match_result.dart';

class RecentFormDisplay extends StatelessWidget {
  final List<MatchResult> recentResults;

  const RecentFormDisplay({
    super.key,
    required this.recentResults,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Form',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: recentResults.take(5).map((result) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: result.isWin
                      ? Colors.green
                      : result.isDraw
                          ? Colors.orange
                          : Colors.red,
                ),
                child: Center(
                  child: Text(
                    result.isWin
                        ? 'W'
                        : result.isDraw
                            ? 'D'
                            : 'L',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
