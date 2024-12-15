import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';

class MatchMaker {
  static Future<void> createCourtsForAllDaysPreservingData(
    BuildContext context,
    List<Player> players,
    Map<String, Map<String, dynamic>> existingMatches, {
    required Map<String, dynamic> earlyConfig,
    required Map<String, dynamic> laterConfig,
  }) async {
    try {
      final firestore = FirebaseService.instance.firestore;
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

      for (final day in days) {
        // Handle early timeslot
        await _updateTimeslotMatches(
          day: day,
          timeslot: TimeslotConstants.earlyTimeslot,
          numberOfCourts: (earlyConfig['numberOfCourts'] as num).toInt(),
          startTime: earlyConfig['startTime'] as String,
          endTime: earlyConfig['endTime'] as String,
          existingMatches: existingMatches,
          firestore: firestore,
        );

        // Handle later timeslot
        await _updateTimeslotMatches(
          day: day,
          timeslot: TimeslotConstants.laterTimeslot,
          numberOfCourts: (laterConfig['numberOfCourts'] as num).toInt(),
          startTime: laterConfig['startTime'] as String,
          endTime: laterConfig['endTime'] as String,
          existingMatches: existingMatches,
          firestore: firestore,
        );
      }

      debugPrint('Successfully created/updated matches for all days');
    } catch (e) {
      debugPrint('Error in createCourtsForAllDaysPreservingData: $e');
      rethrow;
    }
  }

  static Future<void> _updateTimeslotMatches({
    required String day,
    required String timeslot,
    required int numberOfCourts,
    required String startTime,
    required String endTime,
    required Map<String, Map<String, dynamic>> existingMatches,
    required FirebaseFirestore firestore,
  }) async {
    final timeRange = '$startTime - $endTime';
    final batch = firestore.batch();

    try {
      for (int courtNumber = 1; courtNumber <= numberOfCourts; courtNumber++) {
        final matchId =
            '${day.toLowerCase()}_${timeslot.toLowerCase().replaceAll(' ', '_')}_court_$courtNumber';
        final matchRef = firestore.collection('matches').doc(matchId);

        if (existingMatches.containsKey(matchId)) {
          // Update existing match while preserving player and score data
          final existingMatch = existingMatches[matchId]!;
          batch.update(matchRef, {
            'time': timeRange,
            'courtNumber': courtNumber,
            // Preserve existing data
            'players': existingMatch['players'],
            'score': existingMatch['score'],
            'availableSlots': existingMatch['availableSlots'],
            'status': existingMatch['status'],
          });
        } else {
          // Create new match
          batch.set(matchRef, {
            'id': matchId,
            'date': Timestamp.fromDate(DateTime.now()),
            'time': timeRange,
            'day': day.toLowerCase(),
            'status': MatchStatus.waitingPlayers.toString().split('.').last,
            'courtNumber': courtNumber,
            'players': {
              'team1': {'player1': null, 'player2': null},
              'team2': {'player1': null, 'player2': null}
            },
            'score': {
              'team1': {'sets': 0, 'games': []},
              'team2': {'sets': 0, 'games': []}
            },
            'availableSlots': 4,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Remove extra courts if number of courts has decreased
      final existingCourts = existingMatches.keys.where((key) => key.startsWith(
          '${day.toLowerCase()}_${timeslot.toLowerCase().replaceAll(' ', '_')}_court_'));

      for (final existingMatchId in existingCourts) {
        final courtNumber = int.tryParse(existingMatchId.split('_').last) ?? 0;
        if (courtNumber > numberOfCourts) {
          batch.delete(firestore.collection('matches').doc(existingMatchId));
        }
      }

      await batch.commit();
      debugPrint('Successfully updated $timeslot matches for $day');
    } catch (e) {
      debugPrint('Error updating matches for $day $timeslot: $e');
      rethrow;
    }
  }

  static Future<void> updateMatchWithPlayer(
    String matchId,
    Player player,
    String team,
    String position,
  ) async {
    try {
      final firestore = FirebaseService.instance.firestore;
      final matchRef = firestore.collection('matches').doc(matchId);

      await firestore.runTransaction((transaction) async {
        final matchDoc = await transaction.get(matchRef);
        if (!matchDoc.exists) {
          throw Exception('Match not found');
        }

        final matchData = matchDoc.data() as Map<String, dynamic>;
        final players = matchData['players'] as Map<String, dynamic>;
        final teamData = players[team] as Map<String, dynamic>;

        // Update player position
        teamData[position] = firestore.doc('players/${player.id}');

        // Update available slots
        int availableSlots = matchData['availableSlots'] as int;
        availableSlots = availableSlots > 0 ? availableSlots - 1 : 0;

        // Update match status if needed
        String status = availableSlots == 0
            ? MatchStatus.scheduled.toString().split('.').last
            : MatchStatus.waitingPlayers.toString().split('.').last;

        transaction.update(matchRef, {
          'players': players,
          'availableSlots': availableSlots,
          'status': status,
        });
      });

      debugPrint('Successfully added player ${player.name} to match $matchId');
    } catch (e) {
      debugPrint('Error updating match with player: $e');
      throw Exception('Failed to update match: $e');
    }
  }

  static Future<List<Match>> createMatchesFromBookings(
    List<Map<String, dynamic>> bookings,
    List<Player> players,
    String timeslot,
    String day,
  ) async {
    try {
      debugPrint(
          'Creating matches for $day $timeslot with ${bookings.length} bookings');
      final FirebaseFirestore firestore = FirebaseService.instance.firestore;

      // Get admin configuration
      final configDoc = await firestore
          .collection(TimeslotConstants.adminConfigCollection)
          .doc(TimeslotConstants.weeklyConfigDoc)
          .get();

      if (!configDoc.exists) {
        debugPrint('No admin configuration found');
        return [];
      }

      final config = configDoc.data()!;
      final slotConfig = timeslot == TimeslotConstants.earlyTimeslot
          ? config['earlyTimeslot'] as Map<String, dynamic>
          : config['laterTimeslot'] as Map<String, dynamic>;

      final numberOfCourts = (slotConfig['numberOfCourts'] as num).toInt();
      final startTime = slotConfig['startTime'] as String;
      final endTime = slotConfig['endTime'] as String;
      final timeRange = '$startTime - $endTime';

      debugPrint('Creating $numberOfCourts courts for $timeRange');

      // Get available players
      List<Player> availablePlayers = [];
      for (var booking in bookings) {
        debugPrint('Processing booking: $booking');
        final bookingTimeslot = booking['timeslot'] as String;
        final playerId = booking['playerId'] as String;

        if (bookingTimeslot == timeslot ||
            bookingTimeslot == TimeslotConstants.playEither) {
          final player = players.firstWhere(
            (p) => p.id == playerId,
            orElse: () => Player.unknown(),
          );
          if (!player.isUnknown) {
            availablePlayers.add(player);
            debugPrint('Added player ${player.name} to available players');
          }
        }
      }

      debugPrint('Available players for matching: ${availablePlayers.length}');
      List<Match> createdMatches = [];
      int playerIndex = 0;

      // Create matches for each court
      for (int i = 0; i < numberOfCourts; i++) {
        final courtNumber = i + 1;
        final matchId =
            '${day.toLowerCase()}_${timeslot.replaceAll(' ', '_').toLowerCase()}_court_$courtNumber';
        final matchRef = firestore.collection('matches').doc(matchId);

        // Get existing match data if it exists
        final existingMatch = await matchRef.get();
        final Map<String, dynamic> matchData = {
          'id': matchId,
          'date': Timestamp.fromDate(DateTime.now()),
          'time': timeRange,
          'day': day.toLowerCase(),
          'status': MatchStatus.waitingPlayers.toString().split('.').last,
          'courtNumber': courtNumber,
          'players': {
            'team1': {'player1': null, 'player2': null},
            'team2': {'player1': null, 'player2': null}
          },
          'score': {
            'team1': {'sets': 0, 'games': []},
            'team2': {'sets': 0, 'games': []}
          },
          'availableSlots': 4,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (!existingMatch.exists) {
          int playersAssigned = 0;
          while (playerIndex < availablePlayers.length && playersAssigned < 4) {
            final player = availablePlayers[playerIndex];
            final team = playersAssigned < 2 ? 'team1' : 'team2';
            final position = playersAssigned % 2 == 0 ? 'player1' : 'player2';

            (matchData['players'] as Map<String, dynamic>)[team][position] =
                firestore.doc('players/${player.id}');
            playersAssigned++;
            playerIndex++;
          }

          matchData['availableSlots'] = 4 - playersAssigned;
        }

        await matchRef.set(matchData);

        createdMatches.add(Match(
          id: matchId,
          date: DateTime.now(),
          time: timeRange,
          status: MatchStatus.waitingPlayers,
          players: {},
          score: {
            'team1': Score(sets: 0, games: []),
            'team2': Score(sets: 0, games: [])
          },
          createdAt: DateTime.now(),
          availableSlots: matchData['availableSlots'] as int,
          courtNumber: courtNumber,
        ));
      }

      debugPrint('Successfully created ${createdMatches.length} matches');
      return createdMatches;
    } catch (e) {
      debugPrint('Error in createMatchesFromBookings: $e');
      return [];
    }
  }

  static void showInsufficientPlayersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Creating Matches'),
          content: const Text(
            'Matches will be created based on admin configuration. Players can join later.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
