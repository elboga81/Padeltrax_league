import 'package:flutter/material.dart';
import 'player.dart';

class BookingDetailsPage extends StatefulWidget {
  final Player player;

  const BookingDetailsPage({Key? key, required this.player}) : super(key: key);

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  Map<String, String> selectedTimeslots = {};

  @override
  void initState() {
    super.initState();
    selectedTimeslots = {
      'Monday': widget.player.signedTimeslots['Monday'] ?? '',
      'Tuesday': widget.player.signedTimeslots['Tuesday'] ?? '',
      'Wednesday': widget.player.signedTimeslots['Wednesday'] ?? '',
      'Thursday': widget.player.signedTimeslots['Thursday'] ?? '',
      'Friday': widget.player.signedTimeslots['Friday'] ?? '',
    };
  }

  void _selectTimeslot(String day, String timeslot) {
    setState(() {
      selectedTimeslots[day] = timeslot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings for ${widget.player.name}'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(widget.player.profileImage),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.player.name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rating: ${widget.player.rating.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday'
                  ]
                      .map((day) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: [
                                  buildTimeslotButton(day, 'Early Timeslot'),
                                  const SizedBox(width: 8),
                                  buildTimeslotButton(day, 'Later Timeslot'),
                                  const SizedBox(width: 8),
                                  buildTimeslotButton(day, 'Play Either'),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Loop through each day's selection
                  selectedTimeslots.forEach((day, timeslot) {
                    if (timeslot.isNotEmpty) {
                      widget.player.signForTimeslot(day, timeslot);
                    }
                  });
                  Navigator.pop(context, widget.player);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text('Save',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                  elevation: 0,
                ),
                child: const Text('Cancel',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeslotButton(String day, String timeslot) {
    bool isSelected = selectedTimeslots[day] == timeslot;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _selectTimeslot(day, timeslot),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue.shade700 : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.blue.shade700,
          elevation: isSelected ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.blue.shade700, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          timeslot,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
