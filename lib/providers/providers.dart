import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';

class PlayersProvider extends ChangeNotifier {
  List<Player> _players = [];
  List<Player> get players => _players;

  void setPlayers(List<Player> players) {
    _players = players;
    notifyListeners();
  }

  void addPlayer(Player player) {
    _players.add(player);
    notifyListeners();
  }

  void updatePlayer(Player updatedPlayer) {
    final index = _players.indexWhere((p) => p.id == updatedPlayer.id);
    if (index != -1) {
      _players[index] = updatedPlayer;
      notifyListeners();
    }
  }

  void removePlayer(String playerId) {
    _players.removeWhere((p) => p.id == playerId);
    notifyListeners();
  }
}

// Provider configuration
List<ChangeNotifierProvider> get appProviders {
  return [
    ChangeNotifierProvider<PlayersProvider>(
      create: (_) => PlayersProvider(),
    ),
  ];
}
