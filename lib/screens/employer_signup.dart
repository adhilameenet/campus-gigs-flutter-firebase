import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployerSignUpScreen extends StatefulWidget {
  const EmployerSignUpScreen({super.key});

  @override
  _EmployerSignUpScreenState createState() => _EmployerSignUpScreenState();
}

class _EmployerSignUpScreenState extends State<EmployerSignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  Future<void> _signUpEmployer() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        // Create user in Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Update the user's display name in Firebase Authentication
        await userCredential.user!.updateDisplayName(name);

        // Store additional employer data in Firestore
        await _firestore
            .collection('employers')
            .doc(userCredential.user!.uid)
            .set({
          'name': name,
          'email': email,
          'isVerified': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Signup successful! Redirecting to login...')),
        );

        // Clear text fields
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();

        // Redirect to login page
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/employer-login');
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Employer Signup'),
      //   backgroundColor: Colors.blue, // Same as the login page
      // ),
      body: Center(
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
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Employer Sign Up',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Name TextField with icon
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.black),
                        labelText: 'Name',
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Enter your Name',
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
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                      keyboardType: TextInputType.emailAddress,
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
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Enter your Password',
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Signup Button with style
                    ElevatedButton(
                      onPressed: _signUpEmployer,
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
                      child: const Text('Sign Up'),
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
