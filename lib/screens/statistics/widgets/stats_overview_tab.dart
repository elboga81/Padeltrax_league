// lib/screens/statistics/widgets/stats_overview_tab.dart

import 'package:flutter/material.dart';
import 'package:padeltrax_app/models/player.dart';
import 'stats_card.dart';
import 'recent_form_display.dart';
import 'rating_chart.dart';

class StatsOverviewTab extends StatelessWidget {
  final List<Player> players;

  const StatsOverviewTab({
    super.key,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final winRate = player.statistics.wins /
            (player.statistics.totalMatches == 0
                ? 1
                : player.statistics.totalMatches) *
            100;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Header
                ListTile(
                  leading: player.avatar(size: 48),
                  title: Text(player.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rating: ${player.rating}'),
                ),

                const SizedBox(height: 16),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Win Rate',
                        value: '${winRate.toStringAsFixed(1)}%',
                        trend: 5,
                        isPositive: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatsCard(
                        title: 'Total Matches',
                        value: player.statistics.totalMatches.toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatsCard(
                        title: 'Current Streak',
                        value: player.statistics.currentStreak.toString(),
                        trend: player.statistics.currentStreak,
                        isPositive: player.statistics.currentStreak > 0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Recent Form
                RecentFormDisplay(
                  recentResults: player.statistics.recentResults,
                ),

                const SizedBox(height: 16),

                // Rating Chart
                SizedBox(
                  height: 200,
                  child: RatingChart(
                    ratingHistory: player.statistics.last10MatchesRating,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
