// lib/screens/statistics/widgets/stats_partnerships_tab.dart

import 'package:flutter/material.dart';
import 'package:padeltrax_app/models/player.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPartnershipsTab extends StatelessWidget {
  final List<Player> players;

  const StatsPartnershipsTab({
    super.key,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, playerIndex) {
        final player = players[playerIndex];
        final partnershipStats = player.statistics.partnershipMatches;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Header
              ListTile(
                leading: player.avatar(size: 48),
                title: Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${partnershipStats.length} Partners',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

              // Partnership List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: partnershipStats.length,
                itemBuilder: (context, index) {
                  final partnerName = partnershipStats.keys.elementAt(index);
                  final matches = partnershipStats[partnerName] ?? 0;
                  final winRate =
                      player.statistics.partnershipWinRate[partnerName] ?? 0.0;

                  return _buildPartnershipCard(
                    partnerName: partnerName,
                    matches: matches,
                    winRate: winRate,
                  );
                },
              ),

              if (partnershipStats.isNotEmpty)
                _buildPartnershipChart(player, partnershipStats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPartnershipChart(
      Player player, Map<String, int> partnershipStats) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Partnership Win Rates',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= partnershipStats.length) {
                          return const Text('');
                        }
                        return RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            partnershipStats.keys
                                .elementAt(value.toInt())
                                .split(' ')[0],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: partnershipStats.entries
                    .map((entry) => BarChartGroupData(
                          x: partnershipStats.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: (player.statistics
                                          .partnershipWinRate[entry.key] ??
                                      0) *
                                  100,
                              color: Colors.blue,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnershipCard({
    required String partnerName,
    required int matches,
    required double winRate,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.people, color: Colors.blue),
      ),
      title: Text(partnerName),
      subtitle: Text('$matches matches played'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getWinRateColor(winRate).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${(winRate * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: _getWinRateColor(winRate),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getWinRateColor(double winRate) {
    if (winRate >= 0.7) return Colors.green;
    if (winRate >= 0.5) return Colors.blue;
    if (winRate >= 0.3) return Colors.orange;
    return Colors.red;
  }
}
