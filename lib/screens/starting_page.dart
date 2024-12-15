import 'package:flutter/material.dart';
import 'main_dashboard/main_dashboard.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Use theme background color
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/padeltrax_logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Padeltrax',
                style:
                    Theme.of(context).textTheme.displayLarge, // Use theme style
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainDashboard(),
                    ),
                  );
                },
                child: Text(
                  'Start Playing',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge, // Use labelLarge from theme
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
