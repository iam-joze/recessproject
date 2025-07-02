import 'package:flutter/material.dart';
import 'package:project/screens/splash_screen.dart';  // Adjust path
import 'package:project/screens/tenant_home_screen.dart'; // Adjust path
import 'package:project/screens/auth_screen.dart';  // Adjust path

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
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
