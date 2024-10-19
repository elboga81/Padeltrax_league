import 'package:flutter/material.dart';
import 'player.dart';

class MatchResultsView extends StatelessWidget {
  final List<Player> players;

  const MatchResultsView({Key? key, required this.players}) : super(key: key);

  Color getRankColor(int rank) {
    if (rank >= 1 && rank <= 15) return Colors.blue[900]!;
    if (rank >= 16 && rank <= 30) return Colors.blue[300]!;
    if (rank >= 31 && rank <= 50) return Colors.yellow;
    if (rank >= 51 && rank <= 70) return Colors.green;
    if (rank >= 71 && rank <= 90) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[200],
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Padeltrax S League',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Text(
                'Statistics',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(width: 16),
              Text(
                'Sets',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: getRankColor(index + 1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        player.name,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildStatBox('0', Colors.grey[300]!),
                    _buildStatBox('0', Colors.green),
                    _buildStatBox('0', Colors.yellow),
                    _buildStatBox('0', Colors.red),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: const Text(
                        '0%',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatBox('0', Colors.green),
                    _buildStatBox('0', Colors.red),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String text, Color color) {
    return Container(
      width: 30,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
