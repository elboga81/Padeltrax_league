import '../models/player.dart';
import '../models/match.dart';

abstract class DataServiceInterface {
  Stream<List<Player>> getPlayersStream();
  Future<List<Player>> getAllPlayers();
  Future<void> createBooking(String playerId, String day, String timeslot);
  Stream<List<Map<String, dynamic>>> getBookingsForDay(String day);

  Future<void> loadBookingsForDay(String day);
  Future<void> loadBookingsForPlayer(String playerId);
  Future<void> deletePlayerBookings(String playerId);
  Future<void> createMatch({
    required DateTime date,
    required String time,
    required List<String> team1PlayerIds,
    required List<String> team2PlayerIds,
  });
  Stream<List<Match>> getMatchesStream();
  Future<List<Match>> getAllMatches();
  Future<void> updateMatchScore(
      String matchId, String team, String type, dynamic value);
  Future<void> updateMatchStatus(String matchId, MatchStatus status);
}
