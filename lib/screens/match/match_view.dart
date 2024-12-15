import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/match_maker.dart';
import '../../models/match.dart';
import '../../constants/app_constants.dart';
import 'components/match_card.dart';

class MatchView extends StatelessWidget {
  const MatchView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Monday to Friday
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            bottom: const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
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
        body: Stack(
          children: [
            const TabBarView(
              children: [
                DayMatchesView(day: 'Monday'),
                DayMatchesView(day: 'Tuesday'),
                DayMatchesView(day: 'Wednesday'),
                DayMatchesView(day: 'Thursday'),
                DayMatchesView(day: 'Friday'),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _createAutomaticMatches(context),
                backgroundColor: const Color(0xFF1A237E),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAutomaticMatches(BuildContext context) async {
    final appState = context.read<AppState>();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final today = weekdays[DateTime.now().weekday - 1];

    try {
      debugPrint('Creating automatic matches for $today');

      // Ensure bookings are loaded first
      await appState.loadBookingsForDay(today);

      final dayBookings = appState.bookings[today] ?? [];
      debugPrint('Found ${dayBookings.length} bookings for $today');

      // Create Early and Later matches
      final earlyMatches = await MatchMaker.createMatchesFromBookings(
        dayBookings,
        appState.players,
        TimeslotConstants.earlyTimeslot,
        today,
      );

      final laterMatches = await MatchMaker.createMatchesFromBookings(
        dayBookings,
        appState.players,
        TimeslotConstants.laterTimeslot,
        today,
      );

      // Refresh matches in AppState
      await appState.refreshMatches();

      if (!context.mounted) return;

      // Handle empty matches
      if (earlyMatches.isEmpty && laterMatches.isEmpty) {
        debugPrint('No matches created, showing insufficient players dialog');
        MatchMaker.showInsufficientPlayersDialog(context);
        return;
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Created ${earlyMatches.length + laterMatches.length} matches successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error creating automatic matches: $e');
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating matches: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DayMatchesView extends StatelessWidget {
  final String day;

  const DayMatchesView({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final dayMatches = appState.matches.where((match) {
          return match.id.toLowerCase().contains(day.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeslotSection(
                context,
                TimeslotConstants.earlyTimeslot,
                dayMatches,
              ),
              const SizedBox(height: 16),
              _buildTimeslotSection(
                context,
                TimeslotConstants.laterTimeslot,
                dayMatches,
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
  ) {
    // Filter matches for this timeslot
    final timeslotMatches = matches.where((m) {
      final timeRange = _getTimeRange(timeslot);
      return m.time == timeRange;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              timeslot,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_getTimeRange(timeslot)})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (timeslotMatches.isEmpty)
          _buildEmptyState()
        else
          ...timeslotMatches.map((match) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MatchCard(match: match),
              )),
      ],
    );
  }

  String _getTimeRange(String timeslot) {
    return timeslot == TimeslotConstants.earlyTimeslot
        ? '9:00 - 10:30'
        : '11:00 - 12:30';
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Icon(
              Icons.sports_tennis_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No Courts Available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
