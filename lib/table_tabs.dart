import 'package:flutter/material.dart';
import 'form_view.dart';
import 'match_results_view.dart';
import 'player.dart';

class TableTabs extends StatelessWidget {
  final List<Player> players;

  const TableTabs({Key? key, required this.players}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Table'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Form'),
              Tab(text: 'Match Results'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FormView(players: players),
            MatchResultsView(players: players),
          ],
        ),
      ),
    );
  }
}
