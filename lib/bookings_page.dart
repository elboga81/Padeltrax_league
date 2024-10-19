import 'package:flutter/material.dart';
import 'player.dart';
import 'booking_details_page.dart';

class BookingsPage extends StatefulWidget {
  final List<Player> players;

  const BookingsPage({Key? key, required this.players}) : super(key: key);

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late List<Player> players;

  @override
  void initState() {
    super.initState();
    players = widget.players;
  }

  Color getBorderColor(int index) {
    if (index >= 0 && index < 15) {
      return Colors.blue[900]!;
    } else if (index >= 15 && index < 30) {
      return Colors.blue[300]!;
    } else if (index >= 30 && index < 50) {
      return Colors.yellow;
    } else if (index >= 50 && index < 70) {
      return Colors.green;
    } else if (index >= 70 && index < 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            Player player = players[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDetailsPage(player: player),
                  ),
                ).then((updatedPlayer) {
                  if (updatedPlayer != null) {
                    setState(() {
                      // Find the player and update it in the players list
                      int playerIndex = players
                          .indexWhere((p) => p.name == updatedPlayer.name);
                      if (playerIndex != -1) {
                        players[playerIndex] = updatedPlayer;
                      }
                    });
                  }
                });
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          player.avatar(
                              size: 60), // Using the new avatar method
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                player.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Current Form: ${player.rating.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
