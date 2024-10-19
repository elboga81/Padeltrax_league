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
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: matches.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(match['time'],
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
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
    return GestureDetector(
      onTap: () => _showPlayerSelectionDialog(match, playerKey),
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!alignRight) buildRankBox(player.rank),
          if (!alignRight) const SizedBox(width: 8),
          Text(player.name, style: const TextStyle(color: Colors.white)),
          if (alignRight) const SizedBox(width: 8),
          if (alignRight) buildRankBox(player.rank),
        ],
      ),
    );
  }

  Widget buildRankBox(int rank) {
    Color boxColor = Colors.blue;
    if (rank > 30) boxColor = Colors.yellow;
    if (rank > 50) boxColor = Colors.green;
    if (rank > 70) boxColor = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        rank.toString(),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Updated buildScoreBoxes to match the new logic
  Widget buildScoreBoxes(Map<String, dynamic> match, String playerKey) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sets (blue box) - non-clickable, automatically updated
        buildSetBox(match, playerKey),
        const SizedBox(width: 4), // Small horizontal spacing
        // Games (grey boxes) - clickable
        ...List.generate(
          3,
          (index) => buildScoreBox(match, playerKey, index, Colors.grey[800]!),
        ),
      ],
    );
  }

  Widget buildSetBox(Map<String, dynamic> match, String playerKey) {
    int sets = match['score'][playerKey]['sets'] ?? 0;

    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          sets.toString(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget buildScoreBox(
      Map<String, dynamic> match, String playerKey, int index, Color color) {
    List<int> games = List<int>.from(match['score'][playerKey]['games']);
    int score = index < games.length ? games[index] : 0;
    bool isMatchOver = match['score'][playerKey]['sets'] == 2 ||
        match['score'][getOpponentKey(playerKey)]['sets'] == 2;
    bool isSetPlayable = !isMatchOver &&
        (index < games.length ||
            (index == games.length &&
                match['score'][playerKey]['sets'] +
                        match['score'][getOpponentKey(playerKey)]['sets'] <
                    3));

    return GestureDetector(
      onTap: isSetPlayable ? () => _updateScore(match, playerKey, index) : null,
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: isSetPlayable ? color : Colors.grey[600],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            isSetPlayable ? score.toString() : '',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _updateScore(Map<String, dynamic> match, String playerKey, int index) {
    setState(() {
      String opponentKey = getOpponentKey(playerKey);
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
    });
  }

  void _incrementSets(Map<String, dynamic> match, String playerKey) {
    String opponentKey = getOpponentKey(playerKey);
    if (match['score'][playerKey]['sets'] < 2) {
      match['score'][playerKey]['sets']++;
      if (match['score'][playerKey]['games'].length < 3 &&
          match['score'][playerKey]['sets'] +
                  match['score'][opponentKey]['sets'] <
              3) {
        match['score'][playerKey]['games'].add(0);
        match['score'][opponentKey]['games'].add(0);
      }
    }
  }

  String getOpponentKey(String playerKey) {
    return playerKey == 'player1' ? 'player2' : 'player1';
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

  void _showPlayerSelectionDialog(
      Map<String, dynamic> match, String playerKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Player'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.players.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(widget.players[index].name),
                  onTap: () {
                    setState(() {
                      match[playerKey] = widget.players[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
