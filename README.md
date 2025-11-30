# Smart Ambulance Flutter Application

## Project Overview

This Flutter application provides a platform for users to request emergency ambulance services, for drivers to manage requests and update their status, and potentially for hospitals/admins to oversee operations (though hospital/admin portals are not fully implemented in this version).

The application features:
- User authentication (Login/Signup) via Firebase Authentication.
- Role-based access (User, Driver - Hospital/Admin roles planned).
- Real-time location tracking using the `location` package.
- Map display and interaction using `google_maps_flutter`.
- Ambulance request functionality for users.
- Driver availability status management.
- Data storage and real-time updates using Cloud Firestore.

**Tech Stack:**
- **Frontend:** Flutter
- **Backend:** Firebase (Authentication, Cloud Firestore)
- **Mapping:** Google Maps SDK (via `google_maps_flutter`), `location` package

## Prerequisites

Before running this application, ensure you have the following installed and configured:

1.  **Flutter SDK:** Follow the official Flutter installation guide for your operating system: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2.  **Android SDK:** Set up as part of the Flutter installation. Ensure you have the necessary build tools and platform tools installed via the Android SDK Manager (or `sdkmanager` command-line tool).
3.  **Java Development Kit (JDK):** Required by the Android SDK. Version 11 or later is recommended (OpenJDK 17 was used during development).
4.  **VS Code:** Visual Studio Code IDE ([https://code.visualstudio.com/](https://code.visualstudio.com/))
5.  **Flutter and Dart Extensions for VS Code:** Install from the VS Code Marketplace.
6.  **Firebase Account:** You need a Google account to create and manage Firebase projects ([https://firebase.google.com/](https://firebase.google.com/)).
7.  **Google Cloud Platform (GCP) Account:** Required for enabling and managing Google Maps APIs.

## Firebase Setup (Crucial Step)

This project relies heavily on Firebase. You **must** configure your own Firebase project before the app can run correctly.

1.  **Create a Firebase Project:**
    *   Go to the [Firebase Console](https://console.firebase.google.com/).
    *   Click "Add project" and follow the setup steps.
2.  **Add Flutter App to Firebase:**
    *   Inside your Firebase project, navigate to Project Overview > Project settings.
    *   Under "Your apps", click the Flutter icon (or Android/iOS icons if configuring manually).
    *   Follow the instructions provided by the Firebase console. This typically involves using the FlutterFire CLI.
3.  **Install FlutterFire CLI:**
    *   If you haven\t already, install the Firebase CLI: `npm install -g firebase-tools`
    *   Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
    *   Ensure `~/.pub-cache/bin` (or the equivalent for your OS) is in your PATH.
4.  **Configure Your App:**
    *   Navigate to your project directory (`smart_ambulance_app`) in your terminal.
    *   Log in to Firebase: `firebase login`
    *   Configure your Flutter app with Firebase: `flutterfire configure`
    *   Select the Firebase project you created.
    *   Choose the platforms you want to configure (e.g., Android).
    *   This command should automatically generate the necessary configuration files, including `firebase_options.dart` and potentially download `google-services.json` for Android.
5.  **Enable Firebase Services:**
    *   In the Firebase Console, go to the "Build" section.
    *   **Authentication:** Enable the "Email/Password" sign-in method.
    *   **Firestore Database:** Create a Firestore database. Start in **test mode** for initial development (allows open read/write access - **remember to secure this with security rules before production!**). Note the database location.
6.  **Update `main.dart`:**
    *   Ensure `firebase_options.dart` is generated in your `lib` folder.
    *   Uncomment the Firebase initialization lines in `/lib/main.dart`:
        ```dart
        import 'firebase_options.dart'; // Make sure this import exists
        // ...
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform, // Use generated options
        );
        ```

## Google Maps API Setup

1.  **Enable Maps SDK:**
    *   Go to the [Google Cloud Console](https://console.cloud.google.com/).
    *   Select your Firebase project (it should also be a GCP project).
    *   Navigate to "APIs & Services" > "Library".
    *   Search for and enable "Maps SDK for Android".
    *   Search for and enable "Maps SDK for iOS" if you plan to build for iOS.
2.  **Get API Key:**
    *   Navigate to "APIs & Services" > "Credentials".
    *   Create or find an existing API key. **Restrict this key** to only be usable by your Android (and/or iOS) app and the enabled Maps SDKs to prevent unauthorized use.
3.  **Add API Key to Android:**
    *   Open the file `android/app/src/main/AndroidManifest.xml`.
    *   Add the following inside the `<application>` tag, replacing `YOUR_API_KEY` with the key you obtained:
        ```xml
        <meta-data android:name="com.google.android.geo.API_KEY"
                   android:value="YOUR_API_KEY"/>
        ```
4.  **Add API Key to iOS (if applicable):**
    *   Open `ios/Runner/AppDelegate.swift` (or `AppDelegate.m` for Objective-C).
    *   Add the following, replacing `YOUR_API_KEY`:
        *Swift:* 
        ```swift
        import UIKit
        import Flutter
        import GoogleMaps // Add this import

        @UIApplicationMain
        @objc class AppDelegate: FlutterAppDelegate {
          override func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
          ) -> Bool {
            GMSServices.provideAPIKey("YOUR_API_KEY") // Add this line
            GeneratedPluginRegistrant.register(with: self)
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
          }
        }
        ```
        *Objective-C:*
        ```objectivec
        #import "AppDelegate.h"
        #import "GeneratedPluginRegistrant.h"
        #import <GoogleMaps/GoogleMaps.h> // Add this import

        @implementation AppDelegate

        - (BOOL)application:(
          UIApplication *)application
          didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
          [GMSServices provideAPIKey:@"YOUR_API_KEY"]; // Add this line
          [GeneratedPluginRegistrant registerWithRegistry:self];
          return [super application:application didFinishLaunchingWithOptions:launchOptions];
        }
        @end
        ```

## Running the App in VS Code

1.  **Open Project:** Open the `smart_ambulance_app` folder in VS Code.
2.  **Select Device/Emulator:**
    *   Ensure you have an Android emulator running or a physical Android device connected (with USB debugging enabled).
    *   Use the device selector in the bottom-right corner of the VS Code status bar to choose your target device.
3.  **Get Dependencies:**
    *   Open a terminal in VS Code (`Terminal` > `New Terminal`).
    *   Run: `flutter pub get`
4.  **Run the App:**
    *   Press `F5` or go to `Run` > `Start Debugging`.
    *   Alternatively, run `flutter run` in the VS Code terminal.

## Project Structure

```
smart_ambulance_app/
├── android/          # Android specific files
├── ios/              # iOS specific files
├── lib/
│   ├── main.dart       # App entry point, Firebase init, MaterialApp setup
│   ├── models/         # Data models (e.g., User, Request) - (Currently empty)
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── user_home_screen.dart
│   │   └── driver_home_screen.dart
│   │   # (Add hospital_home_screen.dart, admin_home_screen.dart etc. here)
│   ├── services/
│   │   ├── auth_service.dart     # Firebase Authentication logic
│   │   └── firestore_service.dart # Cloud Firestore interactions
│   ├── utils/          # Utility functions/constants - (Currently empty)
│   └── widgets/
│       └── role_router.dart    # Routes user based on Firestore role
│       # (Add common/reusable widgets here)
│   └── firebase_options.dart # Auto-generated by FlutterFire CLI
├── test/
│   └── widget_test.dart  # Basic widget tests
├── pubspec.yaml      # Project dependencies and metadata
└── README.md         # This file
```

## Key Dependencies

- `flutter`: Core Flutter framework.
- `firebase_core`: Required for Firebase initialization.
- `firebase_auth`: For user authentication.
- `cloud_firestore`: For database interactions.
- `google_maps_flutter`: For displaying Google Maps.
- `location`: For accessing device location.
- `cupertino_icons`: iOS style icons.
- `flutter_lints`: Code linting rules.

## Important Notes & Testing

- **Firebase Configuration:** The app **will not work** without proper Firebase project setup and configuration as described above.
- **API Keys:** Ensure your Google Maps API key is correctly added and restricted.
- **Firestore Rules:** The default Firestore rules (test mode) are insecure. You **must** write appropriate security rules before deploying to production.
- **Role Management:** User roles (`user`, `driver`, `hospital`, `admin`) need to be set in the Firestore `users` collection document for the `RoleRouter` to work correctly. This needs to be implemented either during signup or via an admin interface.
- **Testing:** This codebase was developed in an environment without device/emulator access. **Thorough testing on actual devices/emulators is essential.** Pay close attention to:
    - Location permissions and accuracy.
    - Map interactions and marker updates.
    - Firebase authentication flows (login, signup, logout).
    - Firestore data reading/writing and real-time updates.
    - Navigation between screens.
    - UI responsiveness and adherence to design.
    - Error handling (network issues, invalid credentials, permission denial).
- **Missing Features:** Hospital and Admin portals are not implemented. Driver request acceptance/rejection and status updates (picked up, reached hospital) logic needs completion.


<!-- commit 1 -->
