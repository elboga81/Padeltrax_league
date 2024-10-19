import 'package:flutter/material.dart';
import 'player.dart';

class SchedulePage extends StatefulWidget {
  final List<Player> players;

  const SchedulePage({Key? key, required this.players}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get players for a specific day and timeslot
  List<Player> getPlayersForDay(String day, String timeslot) {
    return widget.players
        .where((player) =>
            player.signedTimeslots[day] == timeslot || player.isPlayEither(day))
        .toList();
  }

  Widget buildPlayerList(String day, String timeslot) {
    List<Player> players = getPlayersForDay(day, timeslot);

    if (players.isEmpty) {
      return const Text('No players signed up for this timeslot.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: players.map((player) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(player.profileImage),
          ),
          title: Text(player.name),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Monday'),
            Tab(text: 'Tuesday'),
            Tab(text: 'Wednesday'),
            Tab(text: 'Thursday'),
            Tab(text: 'Friday'),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildScheduleForDay('Monday'),
          buildScheduleForDay('Tuesday'),
          buildScheduleForDay('Wednesday'),
          buildScheduleForDay('Thursday'),
          buildScheduleForDay('Friday'),
        ],
      ),
    );
  }

  Widget buildScheduleForDay(String day) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Early Timeslot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                buildPlayerList(day, 'Early Timeslot'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Later Timeslot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                buildPlayerList(day, 'Later Timeslot'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
