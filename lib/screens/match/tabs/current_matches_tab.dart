import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/match.dart';
import '../../../models/player.dart'; // Added Player import
import '../../../providers/app_state.dart';
import '../../../constants/app_constants.dart';
import '../components/match_card.dart'; // Added MatchCard import

class CurrentMatchesTab extends StatelessWidget {
  const CurrentMatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
            ),
            child: const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 2,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'Monday'),
                Tab(text: 'Tuesday'),
                Tab(text: 'Wednesday'),
                Tab(text: 'Thursday'),
                Tab(text: 'Friday'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            DayMatchesView(day: 'Monday'),
            DayMatchesView(day: 'Tuesday'),
            DayMatchesView(day: 'Wednesday'),
            DayMatchesView(day: 'Thursday'),
            DayMatchesView(day: 'Friday'),
          ],
        ),
      ),
    );
  }
}

class DayMatchesView extends StatelessWidget {
  final String day;

  const DayMatchesView({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final allMatches = appState.matches;
        final dayMatches = allMatches.where((match) {
          return match.date.weekday == _getWeekdayNumber(day);
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Early Timeslot Section
              _buildTimeslotSection(
                context,
                TimeslotConstants.earlyTimeslot,
                dayMatches
                    .where((m) => m.time == TimeslotConstants.earlyTimeslot)
                    .toList(),
                appState.bookings[day] ?? [],
                appState.players,
              ),
              const SizedBox(height: 16),
              // Later Timeslot Section
              _buildTimeslotSection(
                context,
                TimeslotConstants.laterTimeslot,
                dayMatches
                    .where((m) => m.time == TimeslotConstants.laterTimeslot)
                    .toList(),
                appState.bookings[day] ?? [],
                appState.players,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeslotSection(
    BuildContext context,
    String timeslot,
    List<Match> matches,
    List<Map<String, dynamic>> bookings,
    List<Player> allPlayers,
  ) {
    // Get players booked for this timeslot
    final bookedPlayers = bookings
        .where((booking) =>
            booking['timeslot'] == timeslot ||
            booking['timeslot'] == TimeslotConstants.playEither)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeslot Header
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Text(
            timeslot,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),

        // Show either matches or booking info
        if (matches.isNotEmpty)
          ...matches.map((match) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MatchCard(match: match),
              )),

        if (matches.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'No matches scheduled yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (bookedPlayers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${bookedPlayers.length} player(s) signed up',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Waiting for ${4 - bookedPlayers.length} more player(s)',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  int _getWeekdayNumber(String day) {
    final days = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
    };
    return days[day] ?? 1;
  }
}
