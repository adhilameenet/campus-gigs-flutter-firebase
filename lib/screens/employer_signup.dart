// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EmployerSignUpScreen extends StatefulWidget {
//   const EmployerSignUpScreen({super.key});

//   @override
//   _EmployerSignUpScreenState createState() => _EmployerSignUpScreenState();
// }

// class _EmployerSignUpScreenState extends State<EmployerSignUpScreen> {
//   final TextEditingController _registrationNoController =
//       TextEditingController();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _formKey = GlobalKey<FormState>();

//   Future<void> _signUpEmployer() async {
//     if (_formKey.currentState!.validate()) {
//       String registrationNo = _registrationNoController.text.trim();
//       String companyName = _companyNameController.text.trim();
//       String email = _emailController.text.trim();
//       String password = _passwordController.text.trim();

//       try {
//         UserCredential userCredential =
//             await _auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );

//         await _firestore
//             .collection('employers')
//             .doc(userCredential.user!.uid)
//             .set({
//           'registrationNo': registrationNo,
//           'company_name': companyName,
//           'email': email,
//           'isVerified': false,
//           'website': '', // Placeholder, to be updated on profile page
//           'location': '', // Placeholder, to be updated on profile page
//           'description': '', // Placeholder, to be updated on profile page
//           'logo': '', // Placeholder, to be updated on profile page
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Signup successful! Redirecting to login...')),
//         );

//         // Clear text fields
//         _registrationNoController.clear();
//         _companyNameController.clear();
//         _emailController.clear();
//         _passwordController.clear();

//         // Redirect to login page
//         Future.delayed(const Duration(seconds: 2), () {
//           Navigator.pushReplacementNamed(context, '/employer-login');
//         });
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Set full background to white
//       body: Center(
//         child: Container(
//           width: 400,
//           decoration: BoxDecoration(
//             color: Colors.white, // Set container background to white
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 40),
//                     const Text(
//                       'Employer Sign Up',
//                       style: TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     _buildTextField(
//                       controller: _registrationNoController,
//                       label: 'Registration Number',
//                       icon: Icons.assignment_ind,
//                       hint: 'Enter Registration Number',
//                     ),
//                     const SizedBox(height: 20),
//                     _buildTextField(
//                       controller: _companyNameController,
//                       label: 'Company Name',
//                       icon: Icons.business,
//                       hint: 'Enter Company Name',
//                     ),
//                     const SizedBox(height: 20),
//                     _buildTextField(
//                       controller: _emailController,
//                       label: 'Email',
//                       icon: Icons.email,
//                       hint: 'Enter your Email',
//                       keyboardType: TextInputType.emailAddress,
//                     ),
//                     const SizedBox(height: 20),
//                     _buildTextField(
//                       controller: _passwordController,
//                       label: 'Password',
//                       icon: Icons.lock,
//                       hint: 'Enter your Password',
//                       obscureText: true,
//                     ),
//                     const SizedBox(height: 32),
//                     ElevatedButton(
//                       onPressed: _signUpEmployer,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 50, vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: const Text('Sign Up'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String hint,
//     bool obscureText = false,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: Colors.black),
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.black54),
//         filled: true,
//         fillColor: Colors.grey[200],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       style: const TextStyle(color: Colors.black),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter your $label';
//         }
//         if (label == 'Email' && !value.contains('@')) {
//           return 'Please enter a valid email';
//         }
//         if (label == 'Password' && value.length < 6) {
//           return 'Password must be at least 6 characters long';
//         }
//         return null;
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class EmployerSignUpScreen extends StatefulWidget {
  const EmployerSignUpScreen({super.key});

  @override
  _EmployerSignUpScreenState createState() => _EmployerSignUpScreenState();
}

class _EmployerSignUpScreenState extends State<EmployerSignUpScreen> {
  final TextEditingController _registrationNoController =
      TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();

  String? _certificateUrl; // Stores the uploaded certificate URL
  String? _certificateName; // Stores the uploaded certificate file name
  bool _isUploadingCertificate = false;

  Future<void> _pickAndUploadCertificate() async {
    setState(() {
      _isUploadingCertificate = true;
      _certificateName = null; // Clear previous name if re-uploading
    });

    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      final file = result.files.first;

      // Upload the certificate to Firebase Storage
      final storageRef = _storage.ref().child('certificates/${file.name}');
      try {
        await storageRef.putData(file.bytes!);
        _certificateUrl = await storageRef.getDownloadURL();
        _certificateName = file.name;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Certificate "${file.name}" uploaded successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading certificate: $e')),
        );
      }
    }

    setState(() {
      _isUploadingCertificate = false;
    });
  }

  Future<void> _signUpEmployer() async {
    if (_formKey.currentState!.validate() && _certificateUrl != null) {
      String registrationNo = _registrationNoController.text.trim();
      String companyName = _companyNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore
            .collection('employers')
            .doc(userCredential.user!.uid)
            .set({
          'registrationNo': registrationNo,
          'company_name': companyName,
          'email': email,
          'isVerified': false,
          'certificate': _certificateUrl, // Save certificate URL
          'website': '',
          'location': '',
          'description': '',
          'logo': '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Signup successful! Redirecting to login...')),
        );

        // Clear text fields
        _registrationNoController.clear();
        _companyNameController.clear();
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload a certificate before signing up.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
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
                    _buildTextField(
                      controller: _registrationNoController,
                      label: 'Registration Number',
                      icon: Icons.assignment_ind,
                      hint: 'Enter Registration Number',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _companyNameController,
                      label: 'Company Name',
                      icon: Icons.business,
                      hint: 'Enter Company Name',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      hint: 'Enter your Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      hint: 'Enter your Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isUploadingCertificate
                          ? null
                          : _pickAndUploadCertificate,
                      icon: _isUploadingCertificate
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.upload_file),
                      label: Text(
                        _certificateName == null
                            ? 'Upload Certificate'
                            : 'Certificate Uploaded',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_certificateName !=
                        null) // Display file name if available
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Uploaded: $_certificateName',
                          style: const TextStyle(
                              color: Colors.green, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 32),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        hintText: hint,
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
          return 'Please enter your $label';
        }
        if (label == 'Email' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        if (label == 'Password' && value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }
}
