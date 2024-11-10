import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showAlertDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center the entire form horizontally and vertically
        child: Container(
          width: 400, // Fixed width for the form
          decoration: const BoxDecoration(
            color: Colors.white, // Light background color for the theme
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    Text(
                      '${widget.role} Login',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Email TextField with icon
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.black),
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Enter your Email',
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password TextField with icon
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Enter your Password',
                        hintStyle: const TextStyle(color: Colors.black54),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Login Button with style
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // Sign in the user with email and password
                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            // Check the role and redirect accordingly
                            if (widget.role == 'Student') {
                              // Fetch student details from Firestore
                              final userDoc = await FirebaseFirestore.instance
                                  .collection('students')
                                  .doc(userCredential.user!.uid)
                                  .get();

                              if (userDoc.exists) {
                                Navigator.pushNamed(
                                    context, "/student-dashboard");
                              } else {
                                _showAlertDialog('Invalid credentials.');
                              }
                            } else if (widget.role == 'Employer') {
                              // Fetch employer details from Firestore
                              final userDoc = await FirebaseFirestore.instance
                                  .collection('employers')
                                  .doc(userCredential.user!.uid)
                                  .get();

                              // Check if the user exists and redirect
                              if (userDoc.exists) {
                                Navigator.pushNamed(
                                    context, "/employer-dashboard");
                              } else {
                                _showAlertDialog('Invalid credentials.');
                              }
                            }
                          } catch (e) {
                            print('Error signing in: ${e.toString()}');
                            _showAlertDialog('Invalid credentials.');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),
                    // Signup Link based on role
                    if (widget.role == 'Student')
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/student-signup');
                        },
                        child: const Text(
                          'Don’t have an account? Sign up as student',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    if (widget.role == 'Employer')
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/employer-signup');
                        },
                        child: const Text(
                          'Don’t have an account? Sign up as Employer',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
