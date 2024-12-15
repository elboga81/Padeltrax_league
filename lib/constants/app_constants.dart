class TimeslotConstants {
  // Constants for timeslots
  static const String earlyTimeslot = 'Early Timeslot';
  static const String laterTimeslot = 'Later Timeslot';
  static const String playEither = 'Play Either';

  // Constants for admin configuration
  static const String adminConfigCollection = 'admin_config';
  static const String weeklyConfigDoc = 'weekly_config';

  // Days of the week
  static const List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  // Court limits
  static const int minCourts = 1;
  static const int maxCourts = 10;

  // Time ranges (for display and validation)
  static const Map<String, String> timeRanges = {
    earlyTimeslot: '9:00 - 10:30',
    laterTimeslot: '11:00 - 12:30',
  };

  // Match statuses
  static const String statusWaitingPlayers = 'waitingPlayers';
  static const String statusScheduled = 'scheduled';
  static const String statusInProgress = 'inProgress';
  static const String statusCompleted = 'completed';

  // Player limits
  static const int playersPerMatch = 4;
  static const int playersPerTeam = 2;

  // Collection names
  static const String matchesCollection = 'matches';
  static const String bookingsCollection = 'bookings';
  static const String playersCollection = 'players';

  // Match document fields
  static const String fieldDay = 'day';
  static const String fieldTime = 'time';
  static const String fieldPlayers = 'players';
  static const String fieldStatus = 'status';

  // Method to format match ID
  static String formatMatchId(String day, String timeslot) {
    final formattedTimeslot = timeslot.replaceAll(' ', '_').toLowerCase();
    return 'match_${day.toLowerCase()}_${formattedTimeslot}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Method to format booking ID
  static String formatBookingId(String playerId, String day) {
    return 'booking_${playerId}_${day.toLowerCase()}';
  }
}
