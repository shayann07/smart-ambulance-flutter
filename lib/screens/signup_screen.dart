import 'package:flutter/material.dart';
import 'package:smart_ambulance_app/services/auth_service.dart';
import 'package:smart_ambulance_app/services/firestore_service.dart';

import '../widgets/role_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = ''; // Add other fields as needed (e.g., phone, userType)
  String error = '';
  bool loading = false;

  // Add state for user type selection if needed (User/Driver/Hospital)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up - Smart Ambulance')),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 50.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(hintText: 'Name'),
                        validator:
                            (val) => val!.isEmpty ? 'Enter your name' : null,
                        onChanged: (val) {
                          setState(() => name = val);
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(hintText: 'Email'),
                        validator:
                            (val) => val!.isEmpty ? 'Enter an email' : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(hintText: 'Password'),
                        obscureText: true,
                        validator:
                            (val) =>
                                val!.length < 6
                                    ? 'Enter a password 6+ chars long'
                                    : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                      ),
                      // TODO: Add fields for user type, phone number etc. based on requirements
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        child: const Text('Sign Up'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => loading = true);
                            dynamic result = await _auth
                                .signUpWithEmailAndPassword(email, password);
                            if (result == null) {
                              setState(() {
                                error =
                                    'Please supply a valid email or password';
                                loading = false;
                              });
                            } else {
                              // Add user details to Firestore
                              await _firestore.addUser(result.user!.uid, {
                                'name': name,
                                'email': email,
                                // Add other relevant fields like userType, phone
                                'created_at': DateTime.now(),
                              });
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RoleRouter(),
                                ),
                                (route) => false,
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                        ),
                      ),
                      TextButton(
                        child: const Text('Already have an account? Sign In'),
                        onPressed: () {
                          Navigator.pop(context); // Go back to LoginScreen
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
