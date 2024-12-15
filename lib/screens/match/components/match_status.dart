// lib/screens/match/components/match_status.dart

import 'package:flutter/material.dart';

class MatchStatus extends StatelessWidget {
  final bool isComplete;
  final String? winner;
  final String? matchTime;

  const MatchStatus({
    super.key,
    required this.isComplete,
    this.winner,
    this.matchTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (matchTime != null) _buildTimeRow(),
        if (isComplete) _buildWinnerStatus(),
      ],
    );
  }

  Widget _buildTimeRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(
            Icons.access_time,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            matchTime!,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerStatus() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${winner ?? "Team"} Wins!',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Static method to determine winner display name
  static String getWinnerDisplay(String winner) {
    return winner == 'team1' ? 'Team 1' : 'Team 2';
  }
}

// Optional: enum for match states
enum MatchState {
  scheduled,
  inProgress,
  completed,
  cancelled;

  Color get color {
    switch (this) {
      case MatchState.scheduled:
        return Colors.blue;
      case MatchState.inProgress:
        return Colors.orange;
      case MatchState.completed:
        return Colors.green;
      case MatchState.cancelled:
        return Colors.red;
    }
  }

  String get label {
    switch (this) {
      case MatchState.scheduled:
        return 'Scheduled';
      case MatchState.inProgress:
        return 'In Progress';
      case MatchState.completed:
        return 'Completed';
      case MatchState.cancelled:
        return 'Cancelled';
    }
  }
}
