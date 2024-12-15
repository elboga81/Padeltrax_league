import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final double level;
  final String nationality;
  final String preferredSide;
  final String? profileImageUrl;
  final bool isAdmin;
  final bool isLevelVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.level,
    required this.nationality,
    required this.preferredSide,
    this.profileImageUrl,
    this.isAdmin = false,
    this.isLevelVerified = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      level: (data['level'] as num?)?.toDouble() ?? 0.0,
      nationality: data['nationality'] as String? ?? '',
      preferredSide: data['preferredSide'] as String? ?? 'Right',
      profileImageUrl: data['profileImageUrl'] as String?,
      isAdmin: data['isAdmin'] as bool? ?? false,
      isLevelVerified: data['isLevelVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'level': level,
      'nationality': nationality,
      'preferredSide': preferredSide,
      'profileImageUrl': profileImageUrl,
      'isAdmin': isAdmin,
      'isLevelVerified': isLevelVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  UserModel copyWith({
    String? email,
    String? name,
    double? level,
    String? nationality,
    String? preferredSide,
    String? profileImageUrl,
    bool? isAdmin,
    bool? isLevelVerified,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      level: level ?? this.level,
      nationality: nationality ?? this.nationality,
      preferredSide: preferredSide ?? this.preferredSide,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      isLevelVerified: isLevelVerified ?? this.isLevelVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
