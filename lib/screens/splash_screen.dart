import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Name
            Text(
              'Project App', // Or replace with your actual app name
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor, // Using primary color from theme
              ),
            ),
            const SizedBox(height: 20), // Spacing
            // Catchy tagline
            const Text(
              'Your Next Home Awaits',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 80), // More spacing before buttons

            // Sign Up Button
            SizedBox(
              width: 250, // Fixed width for the button
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Signup/Login Screen
                  print('Sign Up pressed');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 15), // Spacing between buttons

            // Login Button
            SizedBox(
              width: 250, // Fixed width for the button
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to Login Screen
                  print('Login pressed');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor), // Border color
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor, // Text color
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15), // Spacing

            // Optional "Browse as Guest" button
            TextButton(
              onPressed: () {
                // TODO: Navigate to Home Screen as guest
                print('Browse as Guest pressed');
              },
              child: const Text(
                'Browse as Guest',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}