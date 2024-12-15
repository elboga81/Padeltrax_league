import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/player.dart';

class TableTabs extends StatelessWidget {
  const TableTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const _CustomTabBar(),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<AppState>(
          builder: (context, appState, child) {
            return TabBarView(
              children: [
                StandingsView(players: appState.players),
                MatchStatisticsView(players: appState.players),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  const _CustomTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TabBar(
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Standings'),
          Tab(text: 'Statistics'),
        ],
      ),
    );
  }
}

class StandingsView extends StatelessWidget {
  final List<Player> players;

  const StandingsView({super.key, required this.players});

  Color _getRankColor(int rank) {
    if (rank <= 15) return const Color(0xFF1A237E);
    if (rank <= 30) return const Color(0xFF1E88E5);
    if (rank <= 50) return const Color(0xFFFFA000);
    if (rank <= 70) return const Color(0xFF43A047);
    if (rank <= 90) return const Color(0xFFF57C00);
    return const Color(0xFFD32F2F);
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.statistics.rating.compareTo(a.statistics.rating));

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            itemCount: sortedPlayers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final player = sortedPlayers[index];
              final rank = index + 1;
              return _buildPlayerRow(rank, player);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 36), // Space for rank
          const Expanded(
            flex: 3,
            child: Text(
              'PLAYER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          ..._buildHeaderItem('PTS'),
          ..._buildHeaderItem('PLY'),
          ..._buildHeaderItem('W'),
          ..._buildHeaderItem('D'),
          ..._buildHeaderItem('L'),
          ..._buildHeaderItem('SW'),
          ..._buildHeaderItem('SL'),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderItem(String text) {
    return [
      const SizedBox(width: 8),
      SizedBox(
        width: 32,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildPlayerRow(int rank, Player player) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {}, // Handle player selection
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildRankBadge(rank),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildFormIndicators(player),
                  ],
                ),
              ),
              ..._buildStatItem(player.statistics.rating.toStringAsFixed(0)),
              ..._buildStatItem(player.statistics.totalMatches.toString(),
                  isBold: true),
              ..._buildStatItem(player.statistics.wins.toString()),
              ..._buildStatItem(player.statistics.draws.toString()),
              ..._buildStatItem(player.statistics.losses.toString()),
              ..._buildStatItem(player.statistics.setsWon.toString()),
              ..._buildStatItem(player.statistics.setsLost.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormIndicators(Player player) {
    // Only show results if player has played matches
    if (player.statistics.totalMatches == 0) {
      return const SizedBox(height: 12); // Maintain consistent row height
    }

    // This should come from player match history data
    List<String> recentResults = [];

    // Here we should actually check the match results
    if (player.statistics.wins > 0) {
      recentResults.add('W');
    } else if (player.statistics.draws > 0) {
      recentResults.add('D');
    } else if (player.statistics.losses > 0) {
      recentResults.add('L');
    }

    return Row(
      children: recentResults
          .map((result) => Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: _getResultColor(result),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'W':
        return const Color(0xFF4CAF50); // Green
      case 'D':
        return const Color(0xFFFF9800); // Orange
      case 'L':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildStatItem(String value, {bool isBold = false}) {
    return [
      const SizedBox(width: 8),
      SizedBox(
        width: 32,
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : null,
          ),
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildRankBadge(int rank) {
    final color = _getRankColor(rank);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
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
    );
  }
}

class MatchStatisticsView extends StatelessWidget {
  final List<Player> players;

  const MatchStatisticsView({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Match Statistics Coming Soon',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
