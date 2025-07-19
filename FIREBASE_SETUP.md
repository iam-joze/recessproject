# Firebase Setup Guide

## Prerequisites
- Flutter SDK installed
- Android Studio or VS Code
- Firebase account

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "Housing App")
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Add Android App to Firebase

1. In your Firebase project console, click the Android icon (</>) to add an Android app
2. Enter your Android package name: `com.example.housingapp`
3. Enter app nickname (optional): "Housing App"
4. Click "Register app"
5. Download the `google-services.json` file
6. Replace the placeholder file in `android/app/google-services.json` with the downloaded file

## Step 3: Enable Authentication

1. In Firebase Console, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to the "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

## Step 4: Install Dependencies

Run the following command to install Firebase dependencies:

```bash
flutter pub get
```

## Step 5: Test the App

1. Run the app: `flutter run`
2. You should see the login screen
3. Create a new account using the signup screen
4. Test login functionality

## Troubleshooting

### Common Issues:

1. **"google-services.json not found"**
   - Make sure you've downloaded the correct `google-services.json` file
   - Place it in `android/app/google-services.json`

2. **"Firebase not initialized"**
   - Ensure you've added the Google Services plugin to your build.gradle files
   - Check that Firebase.initializeApp() is called in main.dart

3. **Authentication errors**
   - Verify that Email/Password authentication is enabled in Firebase Console
   - Check that your package name matches the one in Firebase Console

## Next Steps

After setting up authentication, you can:

1. Add Firestore for data storage
2. Implement user profile management
3. Add property listings to Firestore
4. Implement real-time updates
5. Add push notifications

## iOS Setup (Later)

When you're ready to add iOS support:

1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Add it to your iOS project
4. Update iOS configuration files
5. Test on iOS simulator or device 