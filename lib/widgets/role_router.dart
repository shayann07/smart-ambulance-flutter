import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_ambulance_app/services/auth_service.dart';
import 'package:smart_ambulance_app/services/firestore_service.dart';
import 'package:smart_ambulance_app/screens/user_home_screen.dart';
import 'package:smart_ambulance_app/screens/driver_home_screen.dart';
// Import other role-specific home screens if they exist
// import 'package:smart_ambulance_app/screens/hospital_home_screen.dart';
// import 'package:smart_ambulance_app/screens/admin_home_screen.dart';
import 'package:smart_ambulance_app/screens/login_screen.dart'; // Import LoginScreen for logout navigation

class RoleRouter extends StatefulWidget {
  const RoleRouter({super.key});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      // Should not happen if called from AuthWrapper correctly, but handle defensively
      return const LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot?>(
      future: _firestore.getUser(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
          // Handle error or user data not found
          // Maybe log them out or show an error screen
          print('Error fetching user role or user data not found for ${user.uid}');
          // Optionally sign out the user if their data is missing
          // WidgetsBinding.instance.addPostFrameCallback((_) async {
          //   await _auth.signOut();
          // });
          return const Scaffold(
            body: Center(
              child: Text('Error loading user data. Please try logging in again.'),
            ),
          );
        }

        // User data exists, determine role
        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userRole = userData?['role'] as String? ?? 'user'; // Default to 'user' if role is missing

        print('User role determined as: $userRole');

        // Navigate based on role
        switch (userRole.toLowerCase()) {
          case 'driver':
            return const DriverHomeScreen();
          case 'hospital':
            // return const HospitalHomeScreen(); // Uncomment when created
            return const Scaffold(body: Center(child: Text('Hospital Portal (Not Implemented)')));
          case 'admin':
            // return const AdminHomeScreen(); // Uncomment when created
            return const Scaffold(body: Center(child: Text('Admin Portal (Not Implemented)')));
          case 'user':
          default:
            return const UserHomeScreen();
        }
      },
    );
  }
}

