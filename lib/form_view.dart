import 'package:flutter/material.dart';
import 'player.dart';

class FormView extends StatelessWidget {
  final List<Player> players;

  const FormView({Key? key, required this.players}) : super(key: key);

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
                child: Text('Padeltrax S League',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                  width: 80,
                  child: Text('Pts',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                  width: 120,
                  child: Text('W/D/L Record',
                      style: TextStyle(fontWeight: FontWeight.bold))),
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
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(player.rating.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(
                          6,
                          (i) => Container(
                            width: 18,
                            height: 18,
                            margin: const EdgeInsets.only(left: 2),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i % 3 == 0
                                  ? Colors.green
                                  : (i % 3 == 1 ? Colors.red : Colors.yellow),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              i % 3 == 0 ? 'W' : (i % 3 == 1 ? 'L' : 'D'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
