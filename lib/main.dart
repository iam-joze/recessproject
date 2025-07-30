// ignore_for_file: deprecated_member_use, use_build_context_synchronously, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:housingapp/services/mock_notification_service.dart';
// REMOVED: import 'package:housingapp/services/property_service.dart'; // <--- REMOVED THIS IMPORT
import 'package:housingapp/services/mock_property_service.dart'; // <--- ADDED THIS IMPORT
import 'package:housingapp/screens/account_creation_screen.dart';
import 'package:housingapp/screens/housing_type_selection_screen.dart'; // Assuming this leads to DiscoverListingsScreen
import 'package:housingapp/firebase_options.dart';

// --- TOP-LEVEL FUNCTION FOR BACKGROUND MESSAGES (REQUIRED BY FCM) ---
@pragma('vm:entry-point') // Required for background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase if not already
  developer.log("Handling a background message: ${message.messageId}", name: 'FCM');
  developer.log("Handling a background message: ${message.messageId}", name: 'FCM');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure Firebase is initialized before setting up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserPreferences()),
        ChangeNotifierProvider(create: (context) => MockNotificationService()),
        // CHANGED: Provide MockPropertyService instead of PropertyService
        Provider<MockPropertyService>(create: (context) => MockPropertyService()), 
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription? _authStateSubscription;
  StreamSubscription? _fcmTokenRefreshSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _fcmTokenRefreshSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Firebase Messaging Initialization remains as is
  Future<void> _initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationMessage(initialMessage);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Got a message whilst in the foreground!', name: 'FCM');
      developer.log('Message data: ${message.data}', name: 'FCM');
      if (message.notification != null) {
        developer.log('Message also contained a notification: ${message.notification!.title}: ${message.notification!.body}', name: 'FCM');
      }
      _handleNotificationMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('A new onMessageOpenedApp event was published!', name: 'FCM');
      _handleNotificationMessage(message);
    });
  }

  // Helper to get FCM token and save it to current user's preferences
  Future<void> _updateFcmTokenForCurrentUser(UserPreferences userPrefs) async {
    if (userPrefs.uid == null) {
      developer.log("Warning: UserPreferences UID is null. Cannot update FCM token.", name: 'FCM');
      return;
    }

    String? token = await FirebaseMessaging.instance.getToken();
    developer.log("FCM Token for user ${userPrefs.uid}: $token", name: 'FCM');

    if (token != null) {
      await userPrefs.updateFcmToken(token);
      _fcmTokenRefreshSubscription?.cancel();
      _fcmTokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        developer.log("FCM Token Refreshed for user ${userPrefs.uid}: $newToken", name: 'FCM');
        userPrefs.updateFcmToken(newToken);
      });
    } else {
      developer.log("FCM Token is null. Cannot save to preferences.", name: 'FCM');
    }
  }

  // Placeholder for handling incoming notification messages
  void _handleNotificationMessage(RemoteMessage message) {
    developer.log(
      'Handling incoming notification: ${message.notification?.title ?? "No Title"}',
      name: 'FCM',
    );
  }

  void _listenToAuthChanges() {
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (mounted) {
        final userPreferences = Provider.of<UserPreferences>(context, listen: false);

        if (user == null) {
          // User is signed out. Clear local preferences and navigate to login.
          userPreferences.resetPreferences();
          await userPreferences.updateFcmToken(null);
          if (ModalRoute.of(context)?.settings.name != '/') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AccountCreationScreen()),
              (route) => false,
            );
          }
        } else { // User is signed in (no email verification check needed for social logins)
          developer.log("User signed in: ${user.email ?? user.displayName}", name: 'Auth');

          await userPreferences.loadUserDetails(user.uid);

          // If the user's name or email is not yet set in UserPreferences, update it.
          // This handles cases where they're logging in for the first time with Google.
          if (userPreferences.name == null || userPreferences.email == null) {
            await userPreferences.updateUserDetails(
              uid: user.uid,
              name: user.displayName ?? user.email!,
              email: user.email!,
            );
          }

          await _initializeFirebaseMessaging();
          await _updateFcmTokenForCurrentUser(userPreferences);

          if (mounted && ModalRoute.of(context)?.settings.name != '/home') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HousingTypeSelectionScreen()),
            );
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