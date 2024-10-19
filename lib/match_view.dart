import 'package:flutter/material.dart';
import 'player.dart';

class MatchView extends StatefulWidget {
  final List<Player> players;

  const MatchView({Key? key, required this.players}) : super(key: key);

  @override
  _MatchViewState createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  late List<Map<String, dynamic>> matches;

  @override
  void initState() {
    super.initState();
    matches = generateMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Day'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: matches.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Thursday',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            );
          }
          var match = matches[index - 1];
          return buildMatchCard(match, index);
        },
      ),
    );
  }

  Widget buildMatchCard(Map<String, dynamic> match, int matchIndex) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Match $matchIndex',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(match['time'], style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            buildPlayerRow(match, 'player1', 'player2'),
            buildPlayerRow(match, 'player3', 'player4'),
          ],
        ),
      ),
    );
  }

  Widget buildPlayerRow(
      Map<String, dynamic> match, String player1Key, String player2Key) {
    return Row(
      children: [
        Expanded(child: buildPlayerInfo(match, player1Key)),
        buildScoreBoxes(match, player1Key),
        Expanded(child: buildPlayerInfo(match, player2Key, alignRight: true)),
      ],
    );
  }

  Widget buildPlayerInfo(Map<String, dynamic> match, String playerKey,
      {bool alignRight = false}) {
    Player player = match[playerKey];
    return Row(
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!alignRight) player.avatar(size: 30),
        SizedBox(width: 8),
        Text(
          player.name,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        if (alignRight) SizedBox(width: 8),
        if (alignRight) player.avatar(size: 30),
      ],
    );
  }

  Widget buildScoreBoxes(Map<String, dynamic> match, String playerKey) {
    return Row(
      children: [
        // Sets (blue box) - only 1 needed
        buildScoreBox(match, playerKey, 'sets', 0, Colors.blue),
        const SizedBox(width: 4),
        // Games (grey boxes) - 3 needed
        buildScoreBox(match, playerKey, 'games', 0, Colors.grey[800]!),
        buildScoreBox(match, playerKey, 'games', 1, Colors.grey[800]!),
        buildScoreBox(match, playerKey, 'games', 2, Colors.grey[800]!),
      ],
    );
  }

  Widget buildScoreBox(Map<String, dynamic> match, String playerKey,
      String scoreType, int index, Color color) {
    int score = 0;
    if (match['score'] != null &&
        match['score'][playerKey] != null &&
        match['score'][playerKey][scoreType] != null) {
      if (scoreType == 'sets') {
        score = match['score'][playerKey][scoreType];
      } else {
        // 'games'
        List<int> games = List<int>.from(match['score'][playerKey][scoreType]);
        if (index < games.length) {
          score = games[index];
        }
      }
    }

    return GestureDetector(
      onTap: () => _updateScore(match, playerKey, scoreType, index),
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            score.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _updateScore(Map<String, dynamic> match, String playerKey,
      String scoreType, int index) {
    setState(() {
      if (match['score'] == null) {
        match['score'] = {
          'player1': {'sets': 0, 'games': []},
          'player2': {'sets': 0, 'games': []},
          'player3': {'sets': 0, 'games': []},
          'player4': {'sets': 0, 'games': []},
        };
      }

      String opponentKey = playerKey == 'player1' ? 'player2' : 'player1';

      if (scoreType == 'games') {
        List<int> playerGames =
            List<int>.from(match['score'][playerKey]['games']);
        List<int> opponentGames =
            List<int>.from(match['score'][opponentKey]['games']);

        if (index == playerGames.length) {
          playerGames.add(1);
          opponentGames.add(0);
        } else {
          playerGames[index]++;
        }

        // Check if the player won the set
        if ((playerGames[index] == 6 &&
                playerGames[index] - opponentGames[index] >= 2) ||
            (playerGames[index] == 7 &&
                (opponentGames[index] == 5 || opponentGames[index] == 6))) {
          _incrementSets(match, playerKey);
        } else if (playerGames[index] > 7 ||
            (playerGames[index] == 7 && opponentGames[index] < 5)) {
          playerGames[index]--; // Prevent invalid scores
        }

        match['score'][playerKey]['games'] = playerGames;
        match['score'][opponentKey]['games'] = opponentGames;
      } else if (scoreType == 'sets') {
        if (match['score'][playerKey]['sets'] < 2) {
          match['score'][playerKey]['sets']++;
        }
      }
    });
  }

  void _incrementSets(Map<String, dynamic> match, String playerKey) {
    String opponentKey = playerKey == 'player1' ? 'player2' : 'player1';
    if (match['score'][playerKey]['sets'] < 2) {
      match['score'][playerKey]['sets']++;
      if (match['score'][playerKey]['games'].length < 3) {
        match['score'][playerKey]['games'].add(0);
        match['score'][opponentKey]['games'].add(0);
      }
    }
  }

  List<Map<String, dynamic>> generateMatches() {
    return List.generate(10, (index) {
      return {
        'player1': widget.players[index * 4 % widget.players.length],
        'player2': widget.players[(index * 4 + 1) % widget.players.length],
        'player3': widget.players[(index * 4 + 2) % widget.players.length],
        'player4': widget.players[(index * 4 + 3) % widget.players.length],
        'time': '${9 + (index ~/ 2)}:${index % 2 == 0 ? '00' : '30'}',
        'score': {
          'player1': {'sets': 0, 'games': []},
          'player2': {'sets': 0, 'games': []},
          'player3': {'sets': 0, 'games': []},
          'player4': {'sets': 0, 'games': []},
        },
      };
    });
  }
}
