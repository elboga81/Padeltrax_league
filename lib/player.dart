class Player {
  final String name;
  final double rating;
  final int rank; // Make sure this line is present
  final String profileImage;
  Map<String, String> signedTimeslots = {};

  Player({
    required this.name,
    required this.rating,
    required this.rank, // Make sure this line is present
    required this.profileImage,
  });

  // Method to assign a timeslot for a specific day
  void signForTimeslot(String day, String timeslot) {
    signedTimeslots[day] = timeslot;
  }

  // Check if player signed for both timeslots on the same day
  bool isPlayEither(String day) {
    return signedTimeslots[day] == 'Play Either';
  }
}
