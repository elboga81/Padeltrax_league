import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  // Players Methods
  Stream<List<Player>> getPlayersStream() {
    debugPrint('Getting players stream from Firestore');
    return _firestore.collection('players').snapshots().map((snapshot) {
      final players =
          snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();
      debugPrint('Retrieved ${players.length} players');
      return players;
    });
  }

  Future<List<Player>> getAllPlayers() async {
    final snapshot = await _firestore.collection('players').get();
    return snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();
  }

  // Bookings Methods
  Future<void> createBooking(
      String playerId, String day, String timeslot) async {
    try {
      debugPrint('Creating booking for player $playerId on $day at $timeslot');

      // Delete existing booking if any
      final existingBookings = await _firestore
          .collection('bookings')
          .where('playerId', isEqualTo: playerId)
          .where('day', isEqualTo: day)
          .get();

      final batch = _firestore.batch();
      for (var doc in existingBookings.docs) {
        batch.delete(doc.reference);
      }

      // Create new booking
      final bookingRef = _firestore.collection('bookings').doc();
      final bookingData = {
        'playerId': playerId,
        'day': day,
        'timeslot': timeslot,
        'createdAt': FieldValue.serverTimestamp(),
      };

      batch.set(bookingRef, bookingData);
      await batch.commit();

      // After creating booking, update matches
      await createMatchesFromBookings(
        day: day,
        timeslot: timeslot,
        bookings: [bookingData],
        players: await getAllPlayers(),
      );

      debugPrint(
          'Successfully created booking and updated matches for player $playerId');
    } catch (e) {
      debugPrint('Error creating booking: $e');
      rethrow;
    }
  }

  Future<void> deletePlayerBookings(String playerId) async {
    try {
      debugPrint('Deleting all bookings for player: $playerId');
      final snapshot = await _firestore
          .collection('bookings')
          .where('playerId', isEqualTo: playerId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('Successfully deleted bookings for player $playerId');
    } catch (e) {
      debugPrint('Error deleting player bookings: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getBookingsForDay(String day) {
    return _firestore
        .collection('bookings')
        .where('day', isEqualTo: day)
        .snapshots()
        .map((snapshot) {
      final bookings =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      debugPrint('Retrieved ${bookings.length} bookings for $day');
      return bookings;
    });
  }

  // Matches Methods
  Future<void> createMatchesFromBookings({
    required String day,
    required String timeslot,
    required List<Map<String, dynamic>> bookings,
    required List<Player> players,
  }) async {
    try {
      debugPrint('Creating matches for $day $timeslot');

      // Get existing matches that match the day and time
      final matchesQuery = await _firestore
          .collection('matches')
          .where('day', isEqualTo: day.toLowerCase())
          .where('time',
              isEqualTo:
                  '${timeslot == TimeslotConstants.earlyTimeslot ? "9:00 - 10:30" : "11:00 - 12:30"}')
          .get();

      // Get available players for this timeslot
      final availablePlayers = bookings
          .where((b) =>
              b['timeslot'] == timeslot ||
              b['timeslot'] == TimeslotConstants.playEither)
          .map((b) => b['playerId'] as String)
          .toList();

      debugPrint('Found ${availablePlayers.length} players for this timeslot');

      if (availablePlayers.isEmpty) return;

      // Update first available match with players
      if (matchesQuery.docs.isNotEmpty) {
        final batch = _firestore.batch();
        final matchDoc = matchesQuery.docs.first;

        // Get current match data
        final currentMatchData = matchDoc.data();
        final currentPlayers =
            (currentMatchData['players'] as Map<String, dynamic>?) ??
                {
                  'team1': {'player1': null, 'player2': null},
                  'team2': {'player1': null, 'player2': null}
                };

        // Find first empty slot
        String? teamToUpdate;
        String? positionToUpdate;

        for (var team in ['team1', 'team2']) {
          for (var position in ['player1', 'player2']) {
            if (currentPlayers[team][position] == null &&
                teamToUpdate == null) {
              teamToUpdate = team;
              positionToUpdate = position;
              break;
            }
          }
          if (teamToUpdate != null) break;
        }

        if (teamToUpdate != null && positionToUpdate != null) {
          // Update the first empty slot with the first available player
          currentPlayers[teamToUpdate][positionToUpdate] =
              _firestore.doc('players/${availablePlayers[0]}');

          int filledSlots = currentPlayers.values
              .expand((team) => (team as Map).values)
              .where((player) => player != null)
              .length;

          batch.update(matchDoc.reference, {
            'players': currentPlayers,
            'availableSlots': 4 - filledSlots,
            'status': filledSlots == 4 ? 'scheduled' : 'waitingPlayers',
          });

          await batch.commit();
          debugPrint('Successfully updated match with player');
        }
      }
    } catch (e) {
      debugPrint('Error in createMatchesFromBookings: $e');
      rethrow;
    }
  }

  Stream<List<Match>> getMatchesStream() {
    return _firestore
        .collection('matches')
        .snapshots()
        .asyncMap((snapshot) async {
      final players = await getAllPlayers();
      return snapshot.docs
          .map((doc) => Match.fromFirestore(doc, players))
          .toList();
    });
  }

  Future<List<Match>> getAllMatches() async {
    final snapshot = await _firestore.collection('matches').get();
    final players = await getAllPlayers();
    return snapshot.docs
        .map((doc) => Match.fromFirestore(doc, players))
        .toList();
  }

  Future<void> updateMatchScore(
    String matchId,
    String team,
    String type,
    dynamic value,
  ) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .update({'score.$team.$type': value});
  }

  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': status.toString().split('.').last,
    });
  }

  Future<void> resetAllBookingsAndMatches() async {
    try {
      debugPrint('Resetting all bookings and matches');
      final batch = _firestore.batch();

      final bookingsSnapshot = await _firestore.collection('bookings').get();
      for (var doc in bookingsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final matchesSnapshot = await _firestore.collection('matches').get();
      for (var doc in matchesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('Successfully reset all bookings and matches');
    } catch (e) {
      debugPrint('Error resetting bookings and matches: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    return docSnapshot.exists ? docSnapshot.data() : null;
  }

  // Helper method to load bookings for a specific day
  Future<List<Map<String, dynamic>>> loadBookingsForDay(String day) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('day', isEqualTo: day)
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}
