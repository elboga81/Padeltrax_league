import 'package:flutter/material.dart';
import '../../models/player.dart';
import 'widgets/stats_overview_tab.dart';
import 'widgets/stats_achievements_tab.dart';
import 'widgets/stats_partnerships_tab.dart';

class PlayerStatisticsScreen extends StatelessWidget {
  final List<Player> players;

  const PlayerStatisticsScreen({
    super.key,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Player Statistics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Achievements'),
              Tab(text: 'Partnerships'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StatsOverviewTab(players: players),
            StatsAchievementsTab(players: players),
            StatsPartnershipsTab(players: players),
          ],
        ),
      ),
    );
  }
}
