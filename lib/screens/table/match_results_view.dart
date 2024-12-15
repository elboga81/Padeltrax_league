import 'package:flutter/material.dart';
import '../../models/player.dart';

class StandingsView extends StatelessWidget {
  final List<Player> players;

  const StandingsView({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.statistics.rating.compareTo(a.statistics.rating));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar with Back Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Standings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Header
            _StatsHeader(),

            // Player List
            Expanded(
              child: ListView.builder(
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  final player = sortedPlayers[index];
                  return _PlayerRow(
                    player: player,
                    rank: index + 1,
                    isEven: index.isEven,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final Player player;
  final int rank;
  final bool isEven;

  const _PlayerRow({
    required this.player,
    required this.rank,
    required this.isEven,
  });

  Color _getRankColor() {
    if (rank <= 3) return Colors.blue.shade700;
    if (rank <= 10) return Colors.green.shade700;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.grey.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Future placeholder for player details if needed
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // Rank Circle and Player Info
                SizedBox(
                  width: screenWidth * 0.4,
                  child: Row(
                    children: [
                      // Rank Circle
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getRankColor(),
                        ),
                        child: Center(
                          child: Text(
                            rank.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Player Avatar and Name
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: player.profileImage.isNotEmpty
                            ? NetworkImage(player.profileImage)
                            : null,
                        child: player.profileImage.isEmpty
                            ? const Icon(Icons.person, size: 12)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          player.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Player Stats
                Expanded(
                  child: Row(
                    children: [
                      _buildStatColumn(
                          'PTS', player.statistics.rating.toStringAsFixed(0)),
                      _buildVerticalDivider(),
                      _buildStatColumn(
                          'PLY', player.statistics.totalMatches.toString()),
                      _buildVerticalDivider(),
                      _buildStatColumn('W', player.statistics.wins.toString(),
                          textColor:
                              player.statistics.wins > 0 ? Colors.green : null),
                      _buildVerticalDivider(),
                      _buildStatColumn('L', player.statistics.losses.toString(),
                          textColor:
                              player.statistics.losses > 0 ? Colors.red : null),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: double.infinity,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildStatColumn(String label, String value, {Color? textColor}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.grey.shade800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // Player header
          SizedBox(
            width: screenWidth * 0.4,
            child: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Player',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // Stats headers
          Expanded(
            child: Row(
              children: [
                _buildHeaderColumn('PTS'),
                _buildVerticalDivider(),
                _buildHeaderColumn('PLY'),
                _buildVerticalDivider(),
                _buildHeaderColumn('W'),
                _buildVerticalDivider(),
                _buildHeaderColumn('L'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(String label) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: double.infinity,
      color: Colors.grey.shade300,
    );
  }
}
