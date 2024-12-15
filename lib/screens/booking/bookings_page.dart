import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/player.dart';
import '../../theme/theme.dart';
import 'booking_details_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String _sortOrder = 'Alphabetical'; // Default sorting order

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initializeStreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appState.players.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No players available',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: appState.initializeStreams,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        // Sort players based on the selected order
        List<Player> sortedPlayers = List.from(appState.players);
        if (_sortOrder == 'Alphabetical') {
          sortedPlayers.sort((a, b) => a.name.compareTo(b.name));
        } else if (_sortOrder == 'Position') {
          sortedPlayers.sort((a, b) => a.rank.compareTo(b.rank));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    'assets/images/padeltrax_logo.png',
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
                const Text(
                  'Bookings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              DropdownButton<String>(
                value: _sortOrder,
                dropdownColor: AppTheme.secondaryColor,
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortOrder = value;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'Alphabetical',
                    child: Text('Alphabetical'),
                  ),
                  DropdownMenuItem(
                    value: 'Position',
                    child: Text('Position'),
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RefreshIndicator(
                onRefresh: () async {
                  appState.initializeStreams();
                },
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    return buildPlayerCard(context, sortedPlayers[index]);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPlayerCard(BuildContext context, Player player) {
    return GestureDetector(
      onTap: () => _navigateToBookingDetails(context, player),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: player.profileImage.isNotEmpty
                  ? NetworkImage(player.profileImage)
                  : const AssetImage('assets/images/profile.png')
                      as ImageProvider<Object>?,
              onBackgroundImageError: (_, __) {
                debugPrint('Error loading profile image for ${player.name}');
              },
              child: player.profileImage.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                player.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToBookingDetails(
      BuildContext context, Player player) async {
    try {
      // Get current bookings for player if any
      Map<String, String> currentBookings = {};
      final appState = context.read<AppState>();

      // Create an empty map for selected timeslots
      const emptyBookings = <String, String>{};

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetailsPage(
            player: player,
            selectedTimeSlots: emptyBookings,
          ),
        ),
      );

      if (result == true && mounted) {
        await appState.refreshMatches();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating bookings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
