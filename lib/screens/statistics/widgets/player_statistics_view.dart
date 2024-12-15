import 'package:flutter/material.dart';
import '../../../models/player.dart';

class PlayerStatisticsView extends StatelessWidget {
  final List<Player> players;

  const PlayerStatisticsView({
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
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: player.avatar(size: 50),
                  title: Text(
                    player.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Rating: ${player.statistics.rating.toStringAsFixed(1)}',
                  ),
                ),
                const Divider(),
                _buildStatsRow(
                  'Matches',
                  '${player.statistics.totalMatches}',
                  'Win Rate',
                  '${player.statistics.winRate.toStringAsFixed(1)}%',
                ),
                _buildStatsRow(
                  'Wins',
                  player.statistics.wins.toString(),
                  'Losses',
                  player.statistics.losses.toString(),
                ),
                _buildStatsRow(
                  'Sets Won',
                  player.statistics.setsWon.toString(),
                  'Sets Lost',
                  player.statistics.setsLost.toString(),
                ),
                _buildStatsRow(
                  'Games Won',
                  player.statistics.gamesWon.toString(),
                  'Games Lost',
                  player.statistics.gamesLost.toString(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Recent Form:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: player.statistics.recentMatches.map((result) {
                    return Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _getResultColor(result),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          result,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(
      String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(label1, value1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(label2, value2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'W':
        return Colors.green;
      case 'D':
        return Colors.orange;
      case 'L':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
