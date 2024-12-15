import 'package:flutter/material.dart';
import '../../../models/match.dart';
import '../../../models/match_scoring.dart';
import '../../../models/player.dart';
import './score_board.dart';

class MatchCard extends StatefulWidget {
  final Match match;
  final bool isHistory;
  final VoidCallback? onScoreUpdated;
  final VoidCallback? onViewDetails;

  const MatchCard({
    super.key,
    required this.match,
    this.isHistory = false,
    this.onScoreUpdated,
    this.onViewDetails,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  late MatchScoring _scoring;

  @override
  void initState() {
    super.initState();
    _scoring = MatchScoring();
    _initializeScores();
  }

  void _initializeScores() {
    final team1Score = widget.match.score['team1'];
    final team2Score = widget.match.score['team2'];

    if (team1Score != null) {
      _scoring.teamScores['team1']!.games = List<int>.from(team1Score.games);
      _scoring.teamScores['team1']!.sets = team1Score.sets;
    }

    if (team2Score != null) {
      _scoring.teamScores['team2']!.games = List<int>.from(team2Score.games);
      _scoring.teamScores['team2']!.sets = team2Score.sets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4), // Reduced margins
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Reduced border radius
      ),
      child: InkWell(
        onTap: widget.isHistory && widget.onViewDetails != null
            ? widget.onViewDetails
            : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6), // Reduced padding
                decoration: const BoxDecoration(
                  color: Color(0xFF1A237E), // Deep Blue
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Match ${widget.match.id.split('_').last}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Slightly smaller font
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2), // Compact time box
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.match.time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Match Content
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8), // Reduced padding
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Team 1
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPlayerProfile(
                              widget.match.players['team1_player1']),
                          const SizedBox(height: 4), // Reduced spacing
                          _buildPlayerProfile(
                              widget.match.players['team1_player2']),
                        ],
                      ),
                    ),

                    // Scoreboard
                    Expanded(
                      child: ScoreBoard(
                        scoring: _scoring,
                        onScoreUpdate: (team, gameIndex) {},
                        isMatchComplete: _scoring.isMatchComplete,
                      ),
                    ),

                    // Team 2
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildPlayerProfile(
                              widget.match.players['team2_player1']),
                          const SizedBox(height: 4), // Reduced spacing
                          _buildPlayerProfile(
                              widget.match.players['team2_player2']),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerProfile(Player? player) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: 4), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12, // Smaller avatar
            backgroundColor:
                player == null ? Colors.grey[200] : Colors.blue[100],
            child: player?.profileImage != null
                ? null
                : Icon(
                    Icons.person,
                    color: player == null ? Colors.grey : Colors.blue[700],
                    size: 12, // Smaller icon
                  ),
          ),
          const SizedBox(width: 6), // Reduced spacing
          Expanded(
            child: Text(
              player?.name ?? 'Available Slot',
              style: TextStyle(
                fontSize: 12, // Smaller font
                fontWeight:
                    player == null ? FontWeight.normal : FontWeight.w500,
                color: player == null ? Colors.grey : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
