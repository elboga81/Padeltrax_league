import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../booking/bookings_page.dart';
import '../table/table_tabs.dart';
import '../schedule/schedule_page.dart';
import '../match/match_view.dart';
import '../admin/admin_config_page.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../../providers/app_state.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Debug log to check the logged-in user's UID and email
    final currentUser = FirebaseAuth.instance.currentUser;
    debugPrint('Logged-in UID: ${currentUser?.uid}');
    debugPrint('Logged-in Email: ${currentUser?.email}');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Define the main screens
    final List<Widget> screens = [
      const BookingsPage(),
      const TableTabs(),
      const SchedulePage(),
      const MatchView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Dashboard'),
        actions: [
          // Admin Button Logic with Email Query
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final currentUser = snapshot.data!;

                // Debug log for StreamBuilder
                debugPrint('StreamBuilder UID: ${currentUser.uid}');
                debugPrint('StreamBuilder Email: ${currentUser.email}');

                // Query Firestore for user document by email
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: currentUser.email)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasData &&
                        userSnapshot.data!.docs.isNotEmpty) {
                      final userData = userSnapshot.data!.docs.first.data()
                          as Map<String, dynamic>;
                      if (userData['isAdmin'] == true) {
                        return IconButton(
                          icon: const Icon(Icons.admin_panel_settings),
                          tooltip: 'Admin Settings',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminConfigPage(),
                              ),
                            );
                          },
                        );
                      }
                    }
                    return const SizedBox.shrink(); // Hide for non-admin users
                  },
                );
              }
              return const SizedBox.shrink(); // Hide if no user is logged in
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          screens[_selectedIndex], // Display the selected screen
          if (appState.isLoading || _isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Table',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: 'Match Day',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _handleNavigation,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: appState.initializeStreams,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final appState = context.read<AppState>();
    switch (index) {
      case 0: // Bookings
        appState.initializeStreams();
        break;
      case 1: // Table
        appState.initializeStreams();
        break;
      case 2: // Schedule
        final weekdays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday'
        ];
        for (var day in weekdays) {
          appState.loadBookingsForDay(day);
        }
        break;
      case 3: // Match Day
        appState.refreshMatches();
        break;
    }
  }

  Future<void> _handleLogout() async {
    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance.signOut();
      await _authService.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
