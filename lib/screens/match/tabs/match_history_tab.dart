// In match_history_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/match.dart';
import '../../../providers/app_state.dart';
import '../components/match_card.dart';

class MatchHistoryTab extends StatelessWidget {
  const MatchHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Fetch completed matches from AppState
        final completedMatches = appState.matches
            .where((match) => match.status == MatchStatus.completed)
            .toList();

        if (completedMatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No completed matches yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedMatches.length,
          itemBuilder: (context, index) {
            final match = completedMatches[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _showMatchDetails(context, match),
                child: MatchCard(
                  match: match,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMatchDetails(BuildContext context, Match match) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Match Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Match ID: ${match.id}'),
                Text('Date: ${match.date.toString()}'),
                Text('Time: ${match.time}'),
                Text('Status: ${match.status.toString().split('.').last}'),
                const SizedBox(height: 16),
                _buildTeamDetails('Team 1', match.score['team1']),
                const SizedBox(height: 8),
                _buildTeamDetails('Team 2', match.score['team2']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamDetails(String teamName, Score? score) {
    if (score == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Sets Won: ${score.sets}'),
        Text('Games: ${score.games.join(", ")}'),
      ],
    );
  }
}
