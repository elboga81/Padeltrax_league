import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/asset_paths.dart';
import '../utils/url_converter.dart';
import 'statistics/player_statistics.dart';
import 'match/match_result.dart';
import 'player_avatar.dart';

class Player {
  final String id;
  final String name;
  final double rating;
  final int rank;
  final String profileImage;
  final DateTime createdAt;
  Map<String, String> signedTimeslots;
  final PlayerStatistics statistics;

  Player({
    required this.id,
    required this.name,
    required this.rating,
    required this.rank,
    required this.profileImage,
    required this.createdAt,
    Map<String, String>? signedTimeslots,
    PlayerStatistics? statistics,
  })  : signedTimeslots = signedTimeslots ?? {},
        statistics = statistics ?? PlayerStatistics();

  factory Player.unknown() {
    return Player(
      id: 'unknown',
      name: 'Unknown Player',
      rating: 0,
      rank: 0,
      profileImage: AssetPaths.defaultProfileImage,
      createdAt: DateTime.now(),
      signedTimeslots: {},
      statistics: PlayerStatistics(),
    );
  }

  factory Player.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final profileImageUrl = data['profileImage']?.toString();

      DateTime createdAtDate;
      try {
        createdAtDate =
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      } catch (e) {
        debugPrint('Error converting timestamp: $e');
        createdAtDate = DateTime.now();
      }

      Map<String, String> timeslots = {};
      try {
        if (data['signedTimeslots'] != null) {
          final slots = data['signedTimeslots'] as Map<dynamic, dynamic>;
          timeslots = Map<String, String>.from(slots.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ));
        }
      } catch (e) {
        debugPrint('Error converting signedTimeslots: $e');
      }

      PlayerStatistics stats;
      try {
        stats = PlayerStatistics.fromMap(
            data['statistics'] as Map<String, dynamic>?);
      } catch (e) {
        debugPrint('Error converting statistics: $e');
        stats = PlayerStatistics();
      }

      return Player(
        id: doc.id,
        name: data['name']?.toString() ?? 'Unknown Player',
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        rank: (data['rank'] as num?)?.toInt() ?? 0,
        profileImage: profileImageUrl != null
            ? UrlConverter.getDirectGoogleDriveUrl(profileImageUrl)
            : AssetPaths.defaultProfileImage,
        createdAt: createdAtDate,
        signedTimeslots: timeslots,
        statistics: stats,
      );
    } catch (e) {
      debugPrint('Error creating Player from Firestore: $e');
      return Player.unknown();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'rank': rank,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'signedTimeslots': signedTimeslots,
      'statistics': statistics.toMap(),
    };
  }

  void updateMatchStats(MatchResult result) {
    statistics.updateStats(result);
  }

  void signForTimeslot(String day, String timeslot) {
    debugPrint('Signing $name for $timeslot on $day');
    signedTimeslots[day] = timeslot;
  }

  bool isPlayEither(String day) {
    return signedTimeslots[day] == 'Play Either';
  }

  Widget avatar({double size = 60, Color? borderColor}) {
    return PlayerAvatar(
      player: this,
      size: size,
      borderColor: borderColor,
    );
  }

  bool get hasProfileImage =>
      profileImage.isNotEmpty && profileImage != AssetPaths.defaultProfileImage;

  bool get isUnknown => id == 'unknown';

  String get initials => name
      .split(' ')
      .take(2)
      .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
      .join();

  String get shortName => name.split(' ').first;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Player(id: $id, name: $name, rating: $rating)';

  Player copyWith({
    String? id,
    String? name,
    double? rating,
    int? rank,
    String? profileImage,
    DateTime? createdAt,
    Map<String, String>? signedTimeslots,
    PlayerStatistics? statistics,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      rank: rank ?? this.rank,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      signedTimeslots:
          signedTimeslots ?? Map<String, String>.from(this.signedTimeslots),
      statistics: statistics ?? this.statistics,
    );
  }
}
