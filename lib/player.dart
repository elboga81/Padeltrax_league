import 'package:flutter/material.dart';

class Player {
  final String name;
  final double rating;
  final int rank;
  final String profileImage;
  Map<String, String> signedTimeslots = {};

  Player({
    required this.name,
    required this.rating,
    required this.rank,
    required this.profileImage,
  });

  // Method to assign a timeslot for a specific day
  void signForTimeslot(String day, String timeslot) {
    signedTimeslots[day] = timeslot;
  }

  // Check if player signed for both timeslots on the same day
  bool isPlayEither(String day) {
    return signedTimeslots[day] == 'Play Either';
  }

  // Avatar widget for this player
  Widget avatar({double size = 60}) {
    return PlayerAvatar(player: this, size: size);
  }
}

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;

  const PlayerAvatar({
    Key? key,
    required this.player,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: getBorderColor(player.rank),
          width: size / 30,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          player.profileImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Color getBorderColor(int rank) {
    if (rank >= 0 && rank < 15) {
      return Colors.blue[900]!;
    } else if (rank >= 15 && rank < 30) {
      return Colors.blue[300]!;
    } else if (rank >= 30 && rank < 50) {
      return Colors.yellow;
    } else if (rank >= 50 && rank < 70) {
      return Colors.green;
    } else if (rank >= 70 && rank < 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
