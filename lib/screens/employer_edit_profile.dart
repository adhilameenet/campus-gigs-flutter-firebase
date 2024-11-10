import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditEmployerProfilePage extends StatefulWidget {
  const EditEmployerProfilePage({Key? key}) : super(key: key);

  @override
  _EditEmployerProfilePageState createState() =>
      _EditEmployerProfilePageState();
}

class _EditEmployerProfilePageState extends State<EditEmployerProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _registrationNoController = TextEditingController();
  final _websiteController = TextEditingController();

  File? _logoImage;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _fetchEmployerProfile();
  }

  Future<void> _fetchEmployerProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _companyNameController.text = data['company_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _registrationNoController.text = data['registrationNo'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _locationController.text = data['location'] ?? '';
          _websiteController.text = data['website'] ?? '';
          _logoUrl = data['logo']; // Fetch logo URL if exists
        });
      }
    }
  }

  Future<void> _pickLogoImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef =
            FirebaseFirestore.instance.collection('employers').doc(user.uid);

        Map<String, dynamic> data = {
          'description': _descriptionController.text.trim(),
          'location': _locationController.text.trim(),
          'website': _websiteController.text.trim(),
        };

        // Upload Logo Image
        if (_logoImage != null) {
          try {
            final logoRef = FirebaseStorage.instance.ref('logos/${user.uid}');
            await logoRef.putFile(_logoImage!);
            final logoUrl = await logoRef.getDownloadURL();
            data['logo'] = logoUrl;
            _logoUrl = logoUrl; // Update logo URL
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload logo: $e')),
            );
          }
        }

        try {
          await docRef.update(data);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Logo Upload
                  GestureDetector(
                    onTap: _pickLogoImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _logoImage != null
                          ? FileImage(_logoImage!)
                          : _logoUrl != null
                              ? NetworkImage(_logoUrl!)
                              : AssetImage(
                                      'assets/company_logo_placeholder.png')
                                  as ImageProvider,
                      child: _logoImage == null && _logoUrl == null
                          ? const Icon(Icons.camera_alt,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Company Name (read-only)
                  TextFormField(
                    controller: _companyNameController,
                    decoration: InputDecoration(
                      labelText: 'Company Name',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),

                  // Email (read-only)
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),

                  // Registration No (read-only)
                  TextFormField(
                    controller: _registrationNoController,
                    decoration: InputDecoration(
                      labelText: 'Registration No.',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Website
                  TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(
                      labelText: 'Website',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button color
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
