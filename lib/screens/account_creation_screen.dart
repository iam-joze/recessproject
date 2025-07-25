// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // ADDED: Facebook SDK import
import 'package:housingapp/widgets/custom_button.dart';
// REMOVED: import 'package:housingapp/widgets/custom_text_field.dart'; // Not needed for social login
import 'package:housingapp/screens/housing_type_selection_screen.dart'; // Re-add for navigation
import 'package:provider/provider.dart'; // Re-add for UserPreferences
import 'package:housingapp/models/user_preferences.dart'; // Re-add for UserPreferences
// REMOVED: import 'package:housingapp/screens/check_email_screen.dart'; // Not needed for social login

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  // REMOVED: final TextEditingController _nameController = TextEditingController();
  // REMOVED: final TextEditingController _emailController = TextEditingController();
  // REMOVED: final _formKey = GlobalKey<FormState>(); // Not strictly needed for a single button

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false; // Manages loading state for all social logins

  @override
  void dispose() {
    // REMOVED: _nameController.dispose();
    // REMOVED: _emailController.dispose();
    super.dispose();
  }

  // REMOVED: _sendSignInLink method is removed entirely.

  // Google Sign-In method (from previous step - remains the same)
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // 1. Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in process
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign-In cancelled.')),
          );
        }
        return;
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential with the Google ID token and access token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print('Successfully signed in with Google: ${user.displayName ?? user.email}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome, ${user.displayName ?? user.email}!')),
          );

          // Update UserPreferences with the new user data
          final userPreferences = Provider.of<UserPreferences>(context, listen: false);
          await userPreferences.updateUserDetails(
            uid: user.uid,
            name: user.displayName ?? user.email!, // Use Google's display name or email
            email: user.email!,
          );

          // Navigate to the main app screen
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
      print("Firebase Auth Error during Google Sign-In: ${e.code} - ${e.message}");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred during Google Sign-In: $e')),
        );
      }
      print("General Error during Google Sign-In: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // NEW METHOD: Handles Facebook Sign-In
  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // 1. Trigger the Facebook Sign-In flow
      // You can specify permissions like: .login(permissions: ['email', 'public_profile'])
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // 2. Obtain the access token
        final AccessToken accessToken = result.accessToken!;

        // 3. Create a new credential with the Facebook access token
        final AuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);

        // 4. Sign in to Firebase with the credential
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          print('Successfully signed in with Facebook: ${user.displayName ?? user.email}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome, ${user.displayName ?? user.email}!')),
            );

            // Update UserPreferences with the new user data
            final userPreferences = Provider.of<UserPreferences>(context, listen: false);
            await userPreferences.updateUserDetails(
              uid: user.uid,
              name: user.displayName ?? user.email!, // Use Facebook's display name or email
              email: user.email!,
            );

            // Navigate to the main app screen
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
        // LoginStatus.failed or LoginStatus.operationNotAllowed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Facebook Sign-In failed: ${result.message}')),
          );
        }
        print("Facebook Login Status: ${result.status} - Message: ${result.message}");
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
      print("Firebase Auth Error during Facebook Sign-In: ${e.code} - ${e.message}");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred during Facebook Sign-In: $e')),
        );
      }
      print("General Error during Facebook Sign-In: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading regardless of success/failure
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign in to get started!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // REMOVED: CustomTextField for name
              // REMOVED: CustomTextField for email
              // REMOVED: SizedBox(height: 20)

              _isLoading
                  ? const CircularProgressIndicator()
                  : Column( // Use a Column to stack the buttons
                      children: [
                        CustomButton(
                          text: 'Sign in with Google',
                          onPressed: _signInWithGoogle,
                          // Removed backgroundColor and foregroundColor to avoid conflicts
                          // and rely on CustomButton's default styling from your theme.
                        ),
                        const SizedBox(height: 16), // Spacing between buttons
                        CustomButton(
                          text: 'Sign in with Facebook', // New button
                          onPressed: _signInWithFacebook, // New method call
                          // Removed backgroundColor and foregroundColor for consistency
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}