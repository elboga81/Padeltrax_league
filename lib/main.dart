import 'package:flutter/material.dart';
import 'starting_page.dart'; // Import the starting page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Padeltrax',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartingPage(), // Starting page is the first screen
    );
  }
}
