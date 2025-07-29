import 'package:flutter/material.dart';
import 'package:smart_ambulance_app/screens/signup_screen.dart';
import 'package:smart_ambulance_app/services/auth_service.dart';

import '../widgets/role_router.dart';
// Import other screens like signup and home

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - Smart Ambulance')),
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
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        child: const Text('Sign In'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => loading = true);
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);
                            if (result == null) {
                              setState(() {
                                error =
                                    'Could not sign in with those credentials';
                                loading = false;
                              });
                            } else {
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
                        child: const Text('Don\'t have an account? Sign Up'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
