import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_ambulance_app/screens/driver_home_screen.dart';
import 'package:smart_ambulance_app/screens/login_screen.dart';
import 'package:smart_ambulance_app/screens/signup_screen.dart';
import 'package:smart_ambulance_app/screens/user_home_screen.dart';
import 'package:smart_ambulance_app/services/auth_service.dart';
import 'package:smart_ambulance_app/widgets/role_router.dart'; // Import RoleRouter

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase (Requires configuration setup)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Use generated options
    );
    print('Firebase initialization placeholder - Configuration required.');
    // If you have set up firebase_options.dart, uncomment the above await call.
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Handle initialization error (e.g., show an error message or exit)
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Ambulance',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red, // Link color
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        // Role-specific home screens are handled by RoleRouter, but can be defined for direct navigation if needed
        '/user_home': (context) => const UserHomeScreen(),
        '/driver_home': (context) => const DriverHomeScreen(),
        // '/hospital_home': (context) => const HospitalHomeScreen(), // Uncomment when created
        // '/admin_home': (context) => const AdminHomeScreen(), // Uncomment when created
      },
    );
  }
}

// Wrapper to check authentication state and route accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, use RoleRouter to determine the correct home screen
          print(
            'User logged in: ${snapshot.data!.uid}. Routing based on role...',
          );
          return const RoleRouter(); // Use RoleRouter here
        } else {
          // User is not logged in
          print('User not logged in. Showing LoginScreen.');
          return const LoginScreen();
        }
      },
    );
  }
}
