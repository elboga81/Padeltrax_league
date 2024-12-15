// lib/screens/match/components/score_board.dart

import 'package:flutter/material.dart';
import '../../../models/match_scoring.dart';

class ScoreBoard extends StatelessWidget {
  final MatchScoring scoring;
  final Function(String team, int gameIndex) onScoreUpdate;
  final bool isMatchComplete;

  const ScoreBoard({
    super.key,
    required this.scoring,
    required this.onScoreUpdate,
    this.isMatchComplete = false,
  });

  Widget _buildScoreBox(int score, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          score.toString(),
          style: TextStyle(
            color: color == Colors.grey.shade300 ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScore(String team) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sets score
        _buildScoreBox(
          scoring.teamScores[team]!.sets,
          Colors.blue.shade700,
        ),
        const SizedBox(width: 8),
        // Games scores
        ...List.generate(
            3,
            (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildScoreBox(
                    index < scoring.teamScores[team]!.games.length
                        ? scoring.teamScores[team]!.games[index]
                        : 0,
                    Colors.grey.shade300,
                    onTap: isMatchComplete
                        ? null
                        : () => onScoreUpdate(team, index),
                  ),
                )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTeamScore('team1'),
        const SizedBox(height: 8),
        _buildTeamScore('team2'),
      ],
    );
  }
}

// Optional: Create a model class for individual score boxes
class ScoreBoxConfig {
  final int score;
  final Color color;
  final VoidCallback? onTap;

  const ScoreBoxConfig({
    required this.score,
    required this.color,
    this.onTap,
  });
}

// Optional: Enums for team identification
enum Team { team1, team2 }

// Optional: Score Box Types for better type safety
enum ScoreBoxType { set, game }
