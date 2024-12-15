import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/player.dart';
import '../../constants/app_constants.dart';
import '../../models/match.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllBookings();
    });
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadBookingsForCurrentDay();
      }
    });
  }

  void _loadAllBookings() {
    if (!mounted) return;
    final appState = context.read<AppState>();
    for (final day in _days) {
      appState.loadBookingsForDay(day);
    }
  }

  void _loadBookingsForCurrentDay() {
    if (!mounted) return;
    final currentDay = _days[_tabController.index];
    context.read<AppState>().loadBookingsForDay(currentDay);
  }

  Future<void> _handleAction(Future<void> Function() action) async {
    if (!mounted) return;

    try {
      final messenger = ScaffoldMessenger.of(context);

      // Execute the provided action
      await action();

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Success')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All Bookings and Matches?'),
          content: const Text(
            'This will delete all current bookings and matches. This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('RESET'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _handleAction(() => context.read<AppState>().resetBookings());
    }
  }

  String getCurrentDay() {
    return _days[_tabController.index];
  }

  Widget buildTimeSlotColumn(
    String title,
    List<Map<String, dynamic>> bookings,
    List<Player> players,
    String timeslot,
    List<Match> matches,
  ) {
    final timeSlotBookings = bookings.where((b) {
      final bookingTimeslot = b['timeslot'] as String?;
      return bookingTimeslot == timeslot ||
          bookingTimeslot == TimeslotConstants.playEither;
    }).toList();

    final hasMatchesForTimeslot = matches.any((m) =>
        m.time == timeslot &&
        m.id.toLowerCase().contains(_days[_tabController.index].toLowerCase()));

    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasMatchesForTimeslot
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (hasMatchesForTimeslot)
                    const Tooltip(
                      message: 'Matches created for this timeslot',
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            if (timeSlotBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No players signed up for this timeslot.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: timeSlotBookings.length,
                  itemBuilder: (context, index) {
                    final booking = timeSlotBookings[index];
                    final playerId = booking['playerId'];
                    debugPrint('Player ID in booking: $playerId');
                    final player = players.firstWhere(
                      (p) => p.id == playerId,
                      orElse: () {
                        debugPrint(
                            'Player ID $playerId not found in AppState.players');
                        return Player.unknown();
                      },
                    );

                    return ListTile(
                      leading: player.avatar(size: 40),
                      title: Text(player.name),
                      subtitle: Text(
                        booking['timeslot'] == 'Play Either'
                            ? 'Available for both timeslots'
                            : 'Rating: ${player.rating}',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildDaySchedule(String day, AppState appState) {
    final dayBookings = appState.bookings[day] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTimeSlotColumn(
                  'Early Timeslot',
                  dayBookings,
                  appState.players,
                  TimeslotConstants.earlyTimeslot,
                  appState.matches,
                ),
                buildTimeSlotColumn(
                  'Later Timeslot',
                  dayBookings,
                  appState.players,
                  TimeslotConstants.laterTimeslot,
                  appState.matches,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await _handleAction(() async {
                  final currentDay = getCurrentDay();
                  await appState.createMatchesFromSchedule(
                    currentDay,
                    TimeslotConstants.earlyTimeslot,
                  );
                  await appState.createMatchesFromSchedule(
                    currentDay,
                    TimeslotConstants.laterTimeslot,
                  );
                });
              },
              icon: const Icon(Icons.sports_tennis),
              label: const Text('Create Matches'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _days.map((day) => Tab(text: day)).toList(),
          isScrollable: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Reset All Bookings and Matches',
            onPressed: _showResetConfirmation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllBookings,
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: _days.map((day) {
              return buildDaySchedule(day, appState);
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
