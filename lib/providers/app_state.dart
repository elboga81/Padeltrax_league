import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';

class AppState extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  List<Player> _players = [];
  List<Match> _matches = [];
  final Map<String, List<Map<String, dynamic>>> _bookings = {};

  bool get isLoading => _isLoading;
  List<Player> get players => _players;
  List<Match> get matches => _matches;
  Map<String, List<Map<String, dynamic>>> get bookings => _bookings;

  AppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      initializeStreams();
      await _initializeBookings();
    } catch (e) {
      debugPrint('Error in AppState initialization: $e');
    } finally {
      _setLoading(false);
    }
  }

  void initializeStreams() {
    debugPrint('Initializing streams');
    // Listen to players stream
    _firestoreService.getPlayersStream().listen(
      (updatedPlayers) {
        _players = updatedPlayers;
        notifyListeners();
      },
      onError: (e) => debugPrint('Error in players stream: $e'),
    );

    // Listen to matches stream
    _firestoreService.getMatchesStream().listen(
      (updatedMatches) {
        _matches = updatedMatches;
        notifyListeners();
      },
      onError: (e) => debugPrint('Error in matches stream: $e'),
    );
  }

  Future<void> _initializeBookings() async {
    debugPrint('Initializing bookings for all days');
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    for (final day in days) {
      await loadBookingsForDay(day);
    }
  }

  Future<void> loadBookingsForDay(String day) async {
    try {
      _firestoreService.getBookingsForDay(day).listen(
        (dayBookings) {
          _bookings[day] = dayBookings;
          notifyListeners();
        },
        onError: (e) => debugPrint('Error loading bookings for $day: $e'),
      );
    } catch (e) {
      debugPrint('Error in loadBookingsForDay: $e');
    }
  }

  Future<void> createMatchesFromSchedule(String day, String timeslot) async {
    _setLoading(true);
    try {
      debugPrint('Creating matches for $day $timeslot');
      final dayBookings = _bookings[day] ?? [];

      await _firestoreService.createMatchesFromBookings(
        day: day,
        timeslot: timeslot,
        bookings: dayBookings,
        players: _players,
      );

      await refreshMatches();
    } catch (e) {
      debugPrint('Error creating matches from schedule: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshMatches() async {
    _setLoading(true);
    try {
      _matches = await _firestoreService.getAllMatches();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing matches: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createBooking(
      String playerId, String day, String timeslot) async {
    _setLoading(true);
    try {
      await _firestoreService.createBooking(playerId, day, timeslot);
      await loadBookingsForDay(day);

      // After creating booking, update matches if they exist
      final dayMatches = _matches
          .where((m) =>
              m.id.toLowerCase().contains(day.toLowerCase()) &&
              (m.time.contains(timeslot) ||
                  timeslot == TimeslotConstants.playEither))
          .toList();

      if (dayMatches.isNotEmpty) {
        await createMatchesFromSchedule(day, timeslot);
      }
    } catch (e) {
      debugPrint('Error creating booking: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePlayerBookings(String playerId) async {
    _setLoading(true);
    try {
      await _firestoreService.deletePlayerBookings(playerId);
      await _initializeBookings();
    } catch (e) {
      debugPrint('Error deleting player bookings: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetBookings() async {
    _setLoading(true);
    try {
      await _firestoreService.resetAllBookingsAndMatches();
      await _initializeBookings();
      await refreshMatches();
    } catch (e) {
      debugPrint('Error resetting bookings: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> syncAllData() async {
    _setLoading(true);
    try {
      await refreshMatches();
      await _initializeBookings();
    } catch (e) {
      debugPrint('Error syncing all data: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
