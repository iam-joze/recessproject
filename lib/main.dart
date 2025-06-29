import 'package:flutter/material.dart';
import 'package:project/screens/splash_screen.dart'; // Import your Splash Screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project App',
      theme: ThemeData(
        // We can define our primary color here to be used throughout the app
        primarySwatch: Colors.blue, // A default Material Design color swatch
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Using blue as the seed color
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Set Splash Screen as the initial screen
    );
  }
}
