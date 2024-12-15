// lib/screens/statistics/widgets/stats_achievements_tab.dart

import 'package:flutter/material.dart';
import 'package:padeltrax_app/models/player.dart';
import 'package:padeltrax_app/models/match/achievement.dart';

class StatsAchievementsTab extends StatelessWidget {
  final List<Player> players;

  const StatsAchievementsTab({
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
              ),

              // Achievements Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: player.statistics.achievements.length,
                itemBuilder: (context, index) {
                  final achievement = player.statistics.achievements[index];
                  return _buildAchievementCard(achievement);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {}, // Could show achievement details
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: achievement.rarity.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAchievementIcon(achievement.type),
                      color: achievement.rarity.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      achievement.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                'Earned ${_formatDate(achievement.dateEarned)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.winStreak:
        return Icons.bolt;
      case AchievementType.perfectSet:
        return Icons.star;
      case AchievementType.comeback:
        return Icons.trending_up;
      case AchievementType.tournament:
        return Icons.emoji_events;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
