// lib/screens/account_creation_screen.dart
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:housingapp/widgets/custom_button.dart';
import 'package:housingapp/screens/housing_type_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:logging/logging.dart';
import 'dart:math'; // Import for Random number generation


class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  final Random _random = Random(); // Initialize Random once

  // List of different house icons to choose from randomly
  final List<IconData> _houseIconTypes = [
    Icons.house_outlined,
    Icons.apartment_outlined,
    Icons.villa_outlined,
    Icons.home_work_outlined,
    Icons.cottage_outlined,
    Icons.architecture_outlined, // Can represent a building structure
  ];

  // Helper to generate a random position within screen bounds
  double _randomX(double screenWidth, {double padding = 10}) =>
      _random.nextDouble() * (screenWidth - 2 * padding) + padding;
  double _randomY(double screenHeight, {double padding = 10}) =>
      _random.nextDouble() * (screenHeight - 2 * padding) + padding;

  // Helper to generate a random rotation angle (in radians)
  double _randomRotation() => (_random.nextDouble() - 0.5) * 2 * pi * 0.3; // -0.3pi to 0.3pi for varied rotation

  // Helper to generate a random size within a range
  double _randomSize(double min, double max) => min + (_random.nextDouble() * (max - min));


  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign-In cancelled.')),
          );
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        Logger('AccountCreationScreen').info('Successfully signed in with Google: ${user.displayName ?? user.email}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome, ${user.displayName ?? user.email}!')),
          );

          final userPreferences = Provider.of<UserPreferences>(context, listen: false);
          await userPreferences.updateUserDetails(
            uid: user.uid,
            name: user.displayName ?? user.email!,
            email: user.email!,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HousingTypeSelectionScreen(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'account-exists-with-different-credential') {
        message = 'An account already exists with the same email address but different sign-in credentials.';
      } else if (e.code == 'invalid-credential') {
        message = 'The credential provided is invalid.';
      } else {
        message = 'Google Sign-In failed: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      Logger('AccountCreationScreen').warning("Firebase Auth Error during Google Sign-In: ${e.code} - ${e.message}");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred during Google Sign-In: $e')),
        );
      }
      Logger('AccountCreationScreen').severe("General Error during Google Sign-In: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final AuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          Logger('AccountCreationScreen').info('Successfully signed in with Facebook: ${user.displayName ?? user.email}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome, ${user.displayName ?? user.email}!')),
            );

            final userPreferences = Provider.of<UserPreferences>(context, listen: false);
            await userPreferences.updateUserDetails(
              uid: user.uid,
              name: user.displayName ?? user.email!,
              email: user.email!,
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HousingTypeSelectionScreen(),
              ),
            );
          }
        }
      } else if (result.status == LoginStatus.cancelled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facebook Sign-In cancelled.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Facebook Sign-In failed: ${result.message}')),
          );
        }
        Logger('AccountCreationScreen').warning("Facebook Login Status: ${result.status} - Message: ${result.message}");
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'account-exists-with-different-credential') {
        message = 'An account already exists with the same email address but different sign-in credentials.';
      } else if (e.code == 'invalid-credential') {
        message = 'The credential provided is invalid.';
      } else {
        message = 'Facebook Sign-In failed with Firebase: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      Logger('AccountCreationScreen').warning("Firebase Auth Error during Facebook Sign-In: ${e.code} - ${e.message}");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred during Facebook Sign-In: $e')),
        );
      }
      Logger('AccountCreationScreen').severe("General Error during Facebook Sign-In: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent, // App bar remains transparent
        elevation: 0, // No shadow
        foregroundColor: Colors.black, // App bar text/icon color is black on white background
      ),
      extendBodyBehindAppBar: true, // Extend content behind app bar
      body: Stack( // Use Stack to layer elements
        children: [
          // --- Main Background: Solid White ---
          Positioned.fill(
            child: Container(
              color: Colors.white, // Solid white background
            ),
          ),

          // --- Oversized, Abstract Dark Shape (the "icon-like" background art) ---
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15, // Adjusted top position
            left: MediaQuery.of(context).size.width * -0.2, // Extends off-screen left
            child: Transform.rotate(
              angle: -0.2, // Slight rotation for artistic feel
              child: Opacity(
                opacity: 0.1, // Subtle but visible presence
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.2, // Very wide to cover a large area
                  height: MediaQuery.of(context).size.height * 0.4, // Significant height
                  decoration: BoxDecoration(
                    color: Colors.black, // Dark black color
                    borderRadius: BorderRadius.circular(100), // Very rounded for a soft, abstract shape
                  ),
                ),
              ),
            ),
          ),

          // --- Subtle Abstract Accents ---
          // Small green circle accent
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0.05 * 255).round()), // Subtle green
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Small black circle accent
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            right: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.03 * 255).round()), // Subtle black
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- Small Random Green House Icons ---
          // Loop to add multiple random house icons
          ...List.generate(8, (index) { // Generate 8 random icons for more distribution
            final double iconSize = _randomSize(35.0, 70.0); // Slightly larger range for visibility
            final double opacity = _random.nextDouble() * 0.1 + 0.05; // **Increased opacity range **
            final IconData selectedIcon = _houseIconTypes[_random.nextInt(_houseIconTypes.length)];

            return Positioned(
              top: _randomY(MediaQuery.of(context).size.height, padding: iconSize),
              left: _randomX(MediaQuery.of(context).size.width, padding: iconSize),
              child: Transform.rotate(
                angle: _randomRotation(),
                child: Opacity(
                  opacity: opacity,
                  child: Icon(
                    selectedIcon,
                    size: iconSize,
                    color: Colors.green, 
                  ),
                ),
              ),
            );
          }),

          // --- Main Content (Text and Buttons) ---
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Home!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Dark text for contrast on white
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign in to explore housing options.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black54, // Dark text for contrast on white
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48), // Space before buttons
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.green) // Loading indicator is green
                      : Column(
                          children: [
                            CustomButton(
                              text: 'Sign in with Google',
                              onPressed: _signInWithGoogle,
                              color: Colors.white, // White button background
                              textColor: Colors.black87, // Dark text
                              leadingIcon: Image.asset(
                                'assets/images/google_logo.png',
                                height: 24,
                                width: 24,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Sign in with Facebook',
                              onPressed: _signInWithFacebook,
                              color: const Color(0xFF1877F2), // Facebook's blue
                              textColor: Colors.white, // White text
                              leadingIcon: Image.asset(
                                'assets/images/facebook_logo.png',
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}