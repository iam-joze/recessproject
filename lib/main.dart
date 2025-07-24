import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ADD THIS IMPORT
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:housingapp/services/mock_notification_service.dart'; // Keep if still used for mock
import 'package:housingapp/screens/account_creation_screen.dart';
import 'package:housingapp/screens/housing_type_selection_screen.dart';
import 'package:housingapp/firebase_options.dart'; // Assuming you have this for Firebase.initializeApp

// --- TOP-LEVEL FUNCTION FOR BACKGROUND MESSAGES (REQUIRED BY FCM) ---
// This needs to be a top-level function, not a method of a class.
// It is called when the app is in the background or terminated.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background processing
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // Here, you can perform background data processing, show local notifications, etc.
  // Be aware of platform-specific limitations for background execution.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize with platform options
  );

  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserPreferences()),
        ChangeNotifierProvider(create: (context) => MockNotificationService()), // Keep if still used
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver { // Add WidgetsBindingObserver
  StreamSubscription? _dynamicLinkSubscription;
  StreamSubscription? _authStateSubscription;
  StreamSubscription? _fcmTokenRefreshSubscription; // NEW: For FCM token refresh listener

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for app lifecycle
    _initDynamicLinks();
    _listenToAuthChanges();
    // FCM initialization will be called once authentication status is determined
    // or when user successfully signs in.
  }

  @override
  void dispose() {
    _dynamicLinkSubscription?.cancel();
    _authStateSubscription?.cancel();
    _fcmTokenRefreshSubscription?.cancel(); // NEW: Cancel FCM token refresh subscription
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  // Handle Firebase Dynamic Links
  Future<void> _initDynamicLinks() async {
    // Handle initial link (app opened from a terminated state)
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      if (mounted) {
        _handleDeepLink(initialLink.link); // Call the new private method
      }
    }

    // Listen for dynamic links when the app is in the background or foreground
    _dynamicLinkSubscription = FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData? dynamicLink) {
        if (dynamicLink != null && mounted) {
          _handleDeepLink(dynamicLink.link); // Call the new private method
        }
      },
      onError: (e) {
        print('Error handling dynamic link: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error processing sign-in link: ${e.toString()}')),
          );
        }
      },
    );
  }

  // NEW: Refactored _handleLink into _handleDeepLink method
  void _handleDeepLink(Uri deepLink) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String? emailAddress = auth.currentUser?.email; // Get current user's email if they're still around

    if (auth.isSignInWithEmailLink(deepLink.toString())) {
      try {
        if (emailAddress == null) {
          // If email is null, it means the app was terminated and relaunched
          // Or the user's session expired. Prompt for email again.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please re-enter your email to complete sign-in.')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AccountCreationScreen()),
            (route) => false,
          );
          return;
        }

        final UserCredential userCredential = await auth.signInWithEmailLink(
          email: emailAddress,
          emailLink: deepLink.toString(),
        );

        final User? user = userCredential.user;
        if (user != null && user.emailVerified) {
          print('User signed in via email link: ${user.email}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully signed in as ${user.email}')),
          );

          final userPreferences = Provider.of<UserPreferences>(context, listen: false);

          // Load user data from Firestore
          await userPreferences.loadUserDetails(user.uid);

          // Ensure UserPreferences has name/email from Auth and save to Firestore
          await userPreferences.updateUserDetails(
            uid: user.uid,
            name: user.displayName ?? user.email!, // Use display name from Auth if available, else email
            email: user.email!,
          );

          // --- NEW FCM INTEGRATION: Get and save FCM token after successful sign-in ---
          await _updateFcmTokenForCurrentUser(userPreferences);

          // Navigate to the main app screen
          if (mounted) { // Check mounted again before navigation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HousingTypeSelectionScreen()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        print('Error signing in with email link: ${e.code} - ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing in with link: ${e.message}')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AccountCreationScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        print('Unexpected error handling email link: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An unexpected error occurred.')),
          );
        }
      }
    }
  }


  // NEW: Firebase Messaging Initialization
  Future<void> _initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS/macOS (Android handles permission at install time)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted notification permission: ${settings.authorizationStatus}');

    // Get the initial message if the app was opened from a terminated state via a notification
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationMessage(initialMessage);
    }

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification!.title}: ${message.notification!.body}');
        // You would typically show a local notification here using flutter_local_notifications
      }
      _handleNotificationMessage(message);
    });

    // Handle messages when the app is opened from background (but not terminated) by a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNotificationMessage(message);
    });

    // We get the token and save it to UserPreferences whenever auth state changes to signed-in.
    // This listener is crucial to ensure the token is updated for the currently logged-in user.
    // The actual token update logic is in _updateFcmTokenForCurrentUser().
  }

  // NEW: Helper to get FCM token and save it to current user's preferences
  Future<void> _updateFcmTokenForCurrentUser(UserPreferences userPrefs) async {
    // Check if userPrefs has a UID. If not, it means the user is not truly loaded yet.
    if (userPrefs.uid == null) {
      print("Warning: UserPreferences UID is null. Cannot update FCM token.");
      return;
    }

    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token for user ${userPrefs.uid}: $token");

    if (token != null) {
      // Update the token in UserPreferences model and save it to Firestore
      await userPrefs.updateFcmToken(token);

      // Listen for token refreshes and update immediately
      _fcmTokenRefreshSubscription?.cancel(); // Cancel previous subscription if any
      _fcmTokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("FCM Token Refreshed for user ${userPrefs.uid}: $newToken");
        userPrefs.updateFcmToken(newToken);
      });
    } else {
      print("FCM Token is null. Cannot save to preferences.");
    }
  }

  // NEW: Placeholder for handling incoming notification messages
  void _handleNotificationMessage(RemoteMessage message) {
    // This is where you'd implement logic to navigate the user based on the notification data,
    // or display a specific UI component.
    print('Handling incoming notification: ${message.notification?.title ?? "No Title"}');
    // Example: if (message.data['propertyId'] != null) {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(propertyId: message.data['propertyId'])));
    // }
  }


  void _listenToAuthChanges() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (mounted) {
        final userPreferences = Provider.of<UserPreferences>(context, listen: false);

        if (user == null) {
          // User is signed out. Clear local preferences and navigate to login.
          userPreferences.resetPreferences();
          // Also clear any FCM token when signing out
          await userPreferences.updateFcmToken(null); // Explicitly remove token from Firestore
          if (ModalRoute.of(context)?.settings.name != '/') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AccountCreationScreen()),
              (route) => false,
            );
          }
        } else if (user.emailVerified) {
          // User is signed in and email is verified.
          print("User already signed in and verified: ${user.email}");

          // Load user preferences from Firestore
          await userPreferences.loadUserDetails(user.uid);

          // If the user's name is not yet set in UserPreferences (e.g., first login), update it.
          if (userPreferences.name == null || userPreferences.email == null) {
            await userPreferences.updateUserDetails(
              uid: user.uid,
              name: user.displayName ?? user.email!,
              email: user.email!,
            );
          }

          // --- NEW FCM INTEGRATION: Initialize and update FCM token for the signed-in user ---
          await _initializeFirebaseMessaging(); // Call FCM setup
          await _updateFcmTokenForCurrentUser(userPreferences); // Update token for this user

          if (mounted && ModalRoute.of(context)?.settings.name != '/home') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HousingTypeSelectionScreen()),
            );
          }
        } else {
          // User is signed in but email not verified.
          print("User signed in but email not verified: ${user.email}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please verify your email to continue.')),
            );
            // Optionally, sign out unverified user or keep them on a waiting screen
            // For now, let's keep them on the current screen but show warning.
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HousingApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppStyles.primaryColor,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: AppStyles.primaryMaterialColor)
            .copyWith(secondary: AppStyles.accentColor),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppStyles.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 57, color: AppStyles.textColor),
          displayMedium: TextStyle(fontSize: 45, color: AppStyles.textColor),
          displaySmall: TextStyle(fontSize: 36, color: AppStyles.textColor),
          headlineLarge: TextStyle(fontSize: 32, color: AppStyles.textColor),
          headlineMedium: TextStyle(fontSize: 28, color: AppStyles.textColor),
          headlineSmall: TextStyle(fontSize: 24, color: AppStyles.textColor),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppStyles.textColor),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppStyles.textColor),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppStyles.textColor),
          bodyLarge: TextStyle(fontSize: 16, color: AppStyles.textColor),
          bodyMedium: TextStyle(fontSize: 14, color: AppStyles.textColor),
          bodySmall: TextStyle(fontSize: 12, color: AppStyles.darkGrey),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.textColor),
          labelMedium: TextStyle(fontSize: 12, color: AppStyles.darkGrey),
          labelSmall: TextStyle(fontSize: 11, color: AppStyles.darkGrey),
        ),
      ),
      home: const AccountCreationScreen(),
    );
  }
}