import 'package:flutter/material.dart';

enum AchievementType {
  winStreak, // Win streak achievement
  firstWin, // First victory
  perfectSet, // Won a set 6-0
  comeback, // Won after losing first set
  tournament, // Tournament victory
  undefeatedStreak, // Maintained undefeated streak
  cleanSweep, // Won all matches in tournament
  giantKiller, // Beat a higher ranked player
  rapidRiser, // Quick improvement in ranking
  ironMan, // Many matches in short time
  popularPlayer, // Played with different partners
  clutchPlayer, // Won close matches
  dominantDisplay, // Big score differences
  seasonChampion, // Top of the league
  monthlyMVP, // Best player of the month
  rookieOfTheYear, // Best new player
  improvedRating, // Rating milestone
  consistentPlayer // Regular player
}

enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

  Color get color {
    switch (this) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.uncommon:
        return Colors.green;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String get label {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final AchievementRarity rarity;
  final DateTime dateEarned;
  final int? progress;
  final int? target;
  final String? icon;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.rarity,
    required this.dateEarned,
    this.progress,
    this.target,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'rarity': rarity.toString(),
      'dateEarned': dateEarned.toIso8601String(),
      'progress': progress,
      'target': target,
      'icon': icon,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => AchievementType.firstWin,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString() == map['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      dateEarned: DateTime.parse(map['dateEarned'] as String),
      progress: map['progress'] as int?,
      target: map['target'] as int?,
      icon: map['icon'] as String?,
    );
  }

  static Achievement createAchievement({
    required AchievementType type,
    int? value,
    int? target,
  }) {
    final achievementData = _getAchievementData(type, value, target);
    return Achievement(
      id: '${type.toString()}_${DateTime.now().millisecondsSinceEpoch}',
      title: achievementData.title,
      description: achievementData.description,
      type: type,
      rarity: achievementData.rarity,
      dateEarned: DateTime.now(),
      progress: value,
      target: target,
      icon: achievementData.icon,
    );
  }

  static AchievementData _getAchievementData(
    AchievementType type,
    int? value,
    int? target,
  ) {
    switch (type) {
      case AchievementType.winStreak:
        return AchievementData(
          title: '${value ?? 5} Win Streak!',
          description: 'Won ${value ?? 5} matches in a row',
          rarity: value != null && value >= 10
              ? AchievementRarity.legendary
              : AchievementRarity.rare,
          icon: 'trophy',
        );

      case AchievementType.firstWin:
        return const AchievementData(
          title: 'First Victory',
          description: 'Won your first match',
          rarity: AchievementRarity.common,
          icon: 'star',
        );

      case AchievementType.perfectSet:
        return const AchievementData(
          title: 'Perfect Set',
          description: 'Won a set 6-0',
          rarity: AchievementRarity.rare,
          icon: 'crown',
        );

      case AchievementType.tournament:
        return const AchievementData(
          title: 'Tournament Champion',
          description: 'Won a tournament',
          rarity: AchievementRarity.legendary,
          icon: 'trophy',
        );

      case AchievementType.consistentPlayer:
        return AchievementData(
          title: 'Consistent Player',
          description: 'Played ${value ?? 10} matches in a month',
          rarity: AchievementRarity.uncommon,
          icon: 'calendar',
        );

      case AchievementType.monthlyMVP:
        return const AchievementData(
          title: 'Monthly MVP',
          description: 'Best performing player of the month',
          rarity: AchievementRarity.epic,
          icon: 'medal',
        );

      default:
        return AchievementData(
          title: type.toString().split('.').last,
          description: 'Achievement unlocked!',
          rarity: AchievementRarity.common,
          icon: 'star',
        );
    }
  }

  bool get isCompleted =>
      progress != null && target != null && progress! >= target!;

  double get progressPercentage {
    if (progress == null || target == null) return 1.0;
    return progress! / target!;
  }

  String get formattedDate {
    return '${dateEarned.day}/${dateEarned.month}/${dateEarned.year}';
  }

  bool get isRecent {
    final now = DateTime.now();
    return dateEarned.isAfter(now.subtract(const Duration(days: 7)));
  }

  IconData getIconData() {
    switch (icon) {
      case 'trophy':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      case 'crown':
        return Icons.workspace_premium;
      case 'medal':
        return Icons.military_tech;
      case 'calendar':
        return Icons.calendar_today;
      default:
        return Icons.emoji_events;
    }
  }
}

class AchievementData {
  final String title;
  final String description;
  final AchievementRarity rarity;
  final String icon;

  const AchievementData({
    required this.title,
    required this.description,
    required this.rarity,
    required this.icon,
  });
}

// Example usage:
class AchievementService {
  static bool checkForAchievements(
    int wins,
    int streak,
    int matchesThisMonth,
    double rating,
    bool wonTournament,
  ) {
    List<Achievement> newAchievements = [];

    // Check win streak
    if (streak >= 5) {
      newAchievements.add(Achievement.createAchievement(
        type: AchievementType.winStreak,
        value: streak,
      ));
    }

    // Check first win
    if (wins == 1) {
      newAchievements.add(Achievement.createAchievement(
        type: AchievementType.firstWin,
      ));
    }

    // Check consistent player
    if (matchesThisMonth >= 10) {
      newAchievements.add(Achievement.createAchievement(
        type: AchievementType.consistentPlayer,
        value: matchesThisMonth,
      ));
    }

    // Check tournament win
    if (wonTournament) {
      newAchievements.add(Achievement.createAchievement(
        type: AchievementType.tournament,
      ));
    }

    return newAchievements.isNotEmpty;
  }
}
