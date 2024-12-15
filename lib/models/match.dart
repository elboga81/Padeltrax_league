import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player.dart';
import '../services/firebase_service.dart';

enum MatchStatus { scheduled, inProgress, completed, cancelled, waitingPlayers }

class Score {
  int sets;
  List<int> games;

  Score({
    this.sets = 0,
    List<int>? games,
  }) : games = games ?? [];

  Map<String, dynamic> toMap() {
    return {
      'sets': sets,
      'games': games,
    };
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      sets: (map['sets'] as num?)?.toInt() ?? 0,
      games: (map['games'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
    );
  }

  Score copyWith({
    int? sets,
    List<int>? games,
  }) {
    return Score(
      sets: sets ?? this.sets,
      games: games != null ? List<int>.from(games) : List<int>.from(this.games),
    );
  }
}

class Match {
  final String id;
  final DateTime date;
  final String time;
  final MatchStatus status;
  final Map<String, Player?> players;
  final Map<String, Score> score;
  final DateTime createdAt;
  final int availableSlots;
  final int? courtNumber;

  Match({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.players,
    required this.score,
    required this.createdAt,
    this.availableSlots = 0,
    this.courtNumber,
  });

  Player? get team1Player1 => players['team1_player1'];
  Player? get team1Player2 => players['team1_player2'];
  Player? get team2Player1 => players['team2_player1'];
  Player? get team2Player2 => players['team2_player2'];

  Score? get team1Score => score['team1'];
  Score? get team2Score => score['team2'];

  bool get isComplete => status == MatchStatus.completed;
  bool get needsPlayers => availableSlots > 0;

  String? get winner {
    if (!isComplete) return null;
    final team1Sets = team1Score?.sets ?? 0;
    final team2Sets = team2Score?.sets ?? 0;
    if (team1Sets > team2Sets) return 'team1';
    if (team2Sets > team1Sets) return 'team2';
    return null;
  }

  factory Match.fromFirestore(DocumentSnapshot doc, List<Player> allPlayers) {
    final data = doc.data() as Map<String, dynamic>;
    Map<String, Player?> matchPlayers = {};

    try {
      final playersData = data['players'] as Map<String, dynamic>? ?? {};

      // Process team1
      final team1Data = playersData['team1'] as Map<String, dynamic>? ?? {};
      final player1Ref = team1Data['player1'];
      final player2Ref = team1Data['player2'];

      // Process team2
      final team2Data = playersData['team2'] as Map<String, dynamic>? ?? {};
      final player3Ref = team2Data['player1'];
      final player4Ref = team2Data['player2'];

      // Helper function to extract ID from reference
      String? getPlayerIdFromRef(dynamic ref) {
        if (ref == null) return null;
        if (ref is DocumentReference) return ref.id;
        if (ref is Map) return (ref['path'] as String?)?.split('/').last;
        if (ref is String) return ref;
        return null;
      }

      // Assign players based on references
      final player1Id = getPlayerIdFromRef(player1Ref);
      if (player1Id != null) {
        matchPlayers['team1_player1'] = allPlayers.firstWhere(
          (p) => p.id == player1Id,
          orElse: () => Player.unknown(),
        );
      }

      final player2Id = getPlayerIdFromRef(player2Ref);
      if (player2Id != null) {
        matchPlayers['team1_player2'] = allPlayers.firstWhere(
          (p) => p.id == player2Id,
          orElse: () => Player.unknown(),
        );
      }

      final player3Id = getPlayerIdFromRef(player3Ref);
      if (player3Id != null) {
        matchPlayers['team2_player1'] = allPlayers.firstWhere(
          (p) => p.id == player3Id,
          orElse: () => Player.unknown(),
        );
      }

      final player4Id = getPlayerIdFromRef(player4Ref);
      if (player4Id != null) {
        matchPlayers['team2_player2'] = allPlayers.firstWhere(
          (p) => p.id == player4Id,
          orElse: () => Player.unknown(),
        );
      }
    } catch (e) {
      debugPrint('Error processing players in Match.fromFirestore: $e');
    }

    return Match(
      id: data['id'] as String? ?? doc.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] as String? ?? '',
      status: MatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] as String?),
        orElse: () => MatchStatus.waitingPlayers,
      ),
      players: matchPlayers,
      score: {
        'team1': Score.fromMap(
            data['score']?['team1'] as Map<String, dynamic>? ??
                {'sets': 0, 'games': []}),
        'team2': Score.fromMap(
            data['score']?['team2'] as Map<String, dynamic>? ??
                {'sets': 0, 'games': []}),
      },
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      availableSlots: (data['availableSlots'] as num?)?.toInt() ?? 4,
      courtNumber: (data['courtNumber'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    final firestore = FirebaseService.instance.firestore;
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status.toString().split('.').last,
      'players': {
        'team1': {
          'player1': team1Player1 != null
              ? firestore.doc('players/${team1Player1!.id}')
              : null,
          'player2': team1Player2 != null
              ? firestore.doc('players/${team1Player2!.id}')
              : null,
        },
        'team2': {
          'player1': team2Player1 != null
              ? firestore.doc('players/${team2Player1!.id}')
              : null,
          'player2': team2Player2 != null
              ? firestore.doc('players/${team2Player2!.id}')
              : null,
        },
      },
      'score': {
        'team1': score['team1']!.toMap(),
        'team2': score['team2']!.toMap(),
      },
      'createdAt': Timestamp.fromDate(createdAt),
      'availableSlots': availableSlots,
      'courtNumber': courtNumber,
    };
  }

  Match copyWith({
    String? id,
    DateTime? date,
    String? time,
    MatchStatus? status,
    Map<String, Player?>? players,
    Map<String, Score>? score,
    DateTime? createdAt,
    int? availableSlots,
    int? courtNumber,
  }) {
    return Match(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      players: players ?? Map<String, Player?>.from(this.players),
      score: score ?? Map<String, Score>.from(this.score),
      createdAt: createdAt ?? this.createdAt,
      availableSlots: availableSlots ?? this.availableSlots,
      courtNumber: courtNumber ?? this.courtNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Match && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Match(id: $id, time: $time, status: $status)';
}
