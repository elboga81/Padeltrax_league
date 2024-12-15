import 'package:flutter/material.dart';
import '../../models/player.dart';

class FormView extends StatelessWidget {
  final List<Player> players;

  const FormView({super.key, required this.players});

  Color getRankColor(int rank) {
    if (rank >= 1 && rank <= 15) return Colors.blue.shade900;
    if (rank >= 16 && rank <= 30) return Colors.blue.shade300;
    if (rank >= 31 && rank <= 50) return Colors.amber;
    if (rank >= 51 && rank <= 70) return Colors.green;
    if (rank >= 71 && rank <= 90) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => a.statistics.rating.compareTo(b.statistics.rating));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Padeltrax S League',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                  width: 80,
                  child: Text('Rating',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                  width: 120,
                  child: Text('Form',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedPlayers.length,
            itemBuilder: (context, index) {
              final player = sortedPlayers[index];
              return InkWell(
                onTap: () => _showPlayerStats(context, player),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      _buildRankBadge(index + 1),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            player.avatar(size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${player.statistics.wins}W ${player.statistics.draws}D ${player.statistics.losses}L',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          player.statistics.rating.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children:
                              player.statistics.recentMatches.map((result) {
                            return Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(left: 2),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _getResultColor(result),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                result,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRankBadge(int rank) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getRankColor(rank),
        shape: BoxShape.circle,
      ),
      child: Text(
        rank.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  void _showPlayerStats(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PlayerStatsSheet(player: player),
    );
  }
}

class _PlayerStatsSheet extends StatelessWidget {
  final Player player;

  const _PlayerStatsSheet({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              player.avatar(size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                        'Rating: ${player.statistics.rating.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.blue.shade700)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatItem(
                  'Matches', player.statistics.totalMatches.toString()),
              _buildStatItem('Wins', player.statistics.wins.toString()),
              _buildStatItem('Win Rate',
                  '${player.statistics.winRate.toStringAsFixed(1)}%'),
              _buildStatItem('Current Streak',
                  _formatStreak(player.statistics.currentStreak)),
              _buildStatItem('Sets Won', player.statistics.setsWon.toString()),
              _buildStatItem(
                  'Games Won', player.statistics.gamesWon.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatStreak(int streak) {
    if (streak == 0) return '0';
    if (streak > 0) return '+$streak';
    return streak.toString();
  }
}
