import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., user not found, wrong password)
      print('Failed to sign in: ${e.message}');
      return null;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // TODO: Add user details to Firestore after successful signup
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., email already in use, weak password)
      print('Failed to sign up: ${e.message}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // TODO: Add other methods if needed (e.g., password reset, phone auth)
}

