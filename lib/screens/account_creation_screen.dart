import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:housingapp/widgets/custom_button.dart';
import 'package:housingapp/widgets/custom_text_field.dart';
// REMOVED: import 'package:housingapp/screens/housing_type_selection_screen.dart'; // No longer navigated to directly from here
// REMOVED: import 'package:provider/provider.dart'; // No longer needed here
// REMOVED: import 'package:housingapp/models/user_preferences.dart'; // No longer needed here
import 'package:housingapp/screens/check_email_screen.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendSignInLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    // String name = _nameController.text.trim(); // You could store this locally for later if needed.

    final actionCodeSettings = ActionCodeSettings(
      url: 'https://housing-app-5a129.firebaseapp.com', // Your Firebase Dynamic Link domain
      handleCodeInApp: true,
      androidPackageName: 'com.example.housingapp',
      androidInstallApp: true,
      androidMinimumVersion: '21',
      iOSBundleId: 'com.example.housingapp',
    );

    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      if (mounted) {
        // Optionally, save the name and email locally (e.g., SharedPreferences)
        // so you can use it in _handleLink in main.dart if the app was killed.
        // For simplicity, we'll assume a fresh sign-up flow often has the user's name
        // as part of the initial details. Firebase Auth does NOT store displayName
        // for email link auth directly until you explicitly update the user profile.
        // It's better to get the name from your Firestore document *after* login.

        print('Sign-in link sent to $email');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A sign-in link has been sent to $email. Please check your email to continue.')),
        );

        // Navigate to an informational screen after sending the link
        // We'll pass the entered email so CheckEmailScreen can display it.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CheckEmailScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'Error sending link: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      print("Firebase Auth Error: ${e.code} - ${e.message}");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
      print("General Error sending sign-in link: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // REMOVED: _saveUserDetailsAndNavigate() method is no longer here.
  // Its logic is now handled in main.dart after successful authentication via deep link.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Just a few details to get started!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Your Name',
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: 'Send Sign-in Link',
                        onPressed: _sendSignInLink,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}