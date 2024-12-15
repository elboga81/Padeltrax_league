import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/app_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_dashboard/main_dashboard.dart';
import 'services/firebase_service.dart';
import 'services/firestore_service.dart';
import 'theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Initializing FirebaseService...');
    await FirebaseService.instance.initialize();

    debugPrint('Starting MyApp...');
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error during initialization: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MyApp...');
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
        ),
        StreamProvider<User?>(
          create: (_) {
            debugPrint('Listening to authStateChanges...');
            return FirebaseService.instance.auth.authStateChanges();
          },
          initialData: null,
          catchError: (_, error) {
            debugPrint('Error in authStateChanges: $error');
            return null;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Padeltrax',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('AuthWrapper: Checking authentication state...');
    return Consumer<User?>(
      builder: (context, user, _) {
        if (user == null) {
          debugPrint('AuthWrapper: User not logged in. Showing LoginScreen.');
          return const LoginScreen();
        } else {
          debugPrint('AuthWrapper: User logged in. Showing MainDashboard.');
          return const MainDashboard();
        }
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    debugPrint('ErrorApp: Displaying initialization error UI.');
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  debugPrint('ErrorApp: Retrying app initialization...');
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MyApp()),
                    (route) => false,
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
