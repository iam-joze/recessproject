import 'package:flutter/material.dart';
import 'package:housingapp/screens/welcome_screen.dart';
import 'package:housingapp/utils/app_styles.dart'; // Import your app styles
import 'package:provider/provider.dart';
import 'package:housingapp/models/user_preferences.dart'; // Import your UserPreferences model

void main() {
  runApp(
    // Wrap the entire app with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => UserPreferences(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HousingApp',
      theme: AppStyles.appTheme(), // Apply your custom theme
      home: const WelcomeScreen(), // Start with the WelcomeScreen
      debugShowCheckedModeBanner: false, // Set to false for production
    );
  }
}