import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/player.dart';
import '../../providers/app_state.dart';

class BookingDetailsPage extends StatefulWidget {
  final Player player;
  final Map<String, String> selectedTimeSlots;

  const BookingDetailsPage({
    super.key,
    required this.player,
    required this.selectedTimeSlots,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  late Map<String, String?> _selectedTimeSlots;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize selected timeslots from passed in map or empty
    _selectedTimeSlots = Map<String, String?>.from(widget.selectedTimeSlots);
  }

  // Handle timeslot selection
  void _selectTimeSlot(String day, String timeslot) {
    setState(() {
      if (_selectedTimeSlots[day] == timeslot) {
        // Deselect if already selected
        _selectedTimeSlots[day] = null;
      } else {
        // Select new timeslot
        _selectedTimeSlots[day] = timeslot;
      }
    });
  }

  // Save bookings
  Future<void> _saveBookings() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final appState = context.read<AppState>();
      bool hasBookings = false;

      // Create bookings for each selected day/timeslot
      for (final day in TimeslotConstants.days) {
        final timeslot = _selectedTimeSlots[day];
        if (timeslot != null) {
          hasBookings = true;
          await appState.createBooking(widget.player.id, day, timeslot);
        }
      }

      if (hasBookings) {
        await appState.refreshMatches();
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bookings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTimeSlotButton(String day, String label, String timeslot) {
    final isSelected = _selectedTimeSlots[day] == timeslot;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
          foregroundColor: isSelected ? Colors.white : null,
        ),
        onPressed: () => _selectTimeSlot(day, timeslot),
        child: Text(label),
      ),
    );
  }

  Widget _buildDaySection(String day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTimeSlotButton(
                day,
                'Early',
                TimeslotConstants.earlyTimeslot,
              ),
              const SizedBox(width: 8),
              _buildTimeSlotButton(
                day,
                'Late',
                TimeslotConstants.laterTimeslot,
              ),
            ],
          ),
          // Show time range for selected timeslot
          if (_selectedTimeSlots[day] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                TimeslotConstants.timeRanges[_selectedTimeSlots[day]!] ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        // Changed to onPopInvoked
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content:
                const Text('Are you sure you want to discard your changes?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );

        if (shouldPop ?? false) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bookings - ${widget.player.name}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard Changes?'),
                  content: const Text(
                      'Are you sure you want to discard your changes?'),
                  actions: [
                    TextButton(
                      child: const Text('No'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );

              if (shouldPop ?? false) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(widget.player.profileImage),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.player.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Rating: ${widget.player.rating}'),
                ],
              ),
            ),
            const Divider(),
            ...TimeslotConstants.days.map((day) => _buildDaySection(day)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBookings,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
