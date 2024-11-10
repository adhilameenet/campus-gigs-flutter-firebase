import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _registrationNoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _courseController = TextEditingController();
  final _startYearController = TextEditingController();
  final _endYearController = TextEditingController();
  final _skillsController = TextEditingController();
  final _phoneNoController =
      TextEditingController(); // Added phone number controller

  File? _profileImage;
  File? _resume;
  String? _resumeName;
  String? _resumeSize;
  String? _resumeUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _registrationNoController.text = data['registrationNo'] ?? '';
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _courseController.text = data['course'] ?? '';
          _startYearController.text = data['startYear'] ?? '';
          _endYearController.text = data['endYear'] ?? '';
          _skillsController.text = data['skills'].join(', ') ?? '';
          _phoneNoController.text = data['phoneno'] ?? ''; // Fetch phone number
          _resumeUrl = data['resume']; // Fetch resume URL if exists
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _resume = File(result.files.single.path!);
        _resumeName = result.files.single.name;
        _resumeSize =
            '${(result.files.single.size / 1024).toStringAsFixed(2)} KB';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef =
            FirebaseFirestore.instance.collection('students').doc(user.uid);

        Map<String, dynamic> data = {
          'course': _courseController.text.trim(),
          'startYear': _startYearController.text.trim(),
          'endYear': _endYearController.text.trim(),
          'skills': _skillsController.text.trim().split(','),
          'phoneno': _phoneNoController.text.trim(), // Added phone number field
        };

        // Upload Profile Picture
        if (_profileImage != null) {
          try {
            final profilePicRef =
                FirebaseStorage.instance.ref('profile_pictures/${user.uid}');
            await profilePicRef.putFile(_profileImage!);
            final profilePicUrl = await profilePicRef.getDownloadURL();
            data['profilePicture'] = profilePicUrl;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload profile picture: $e')),
            );
          }
        }

        // Upload Resume if selected
        if (_resume != null) {
          try {
            final resumeRef =
                FirebaseStorage.instance.ref('resumes/${user.uid}');
            await resumeRef.putFile(_resume!);
            final resumeUrl = await resumeRef.getDownloadURL();
            data['resume'] = resumeUrl;
            _resumeUrl = resumeUrl; // Update the resume URL state
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload resume: $e')),
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

                  // Profile Picture
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/user.png') as ImageProvider,
                      child: _profileImage == null
                          ? const Icon(Icons.camera_alt,
                              size: 50, color: Colors.white)
                          : null,
                    ),
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

                  // First and Last Name (read-only)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
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

                  // Course
                  TextFormField(
                    controller: _courseController,
                    decoration: InputDecoration(
                      labelText: 'Course',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone No
                  TextFormField(
                    controller: _phoneNoController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  // Start Year
                  TextFormField(
                    controller: _startYearController,
                    decoration: InputDecoration(
                      labelText: 'Start Year',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // End Year
                  TextFormField(
                    controller: _endYearController,
                    decoration: InputDecoration(
                      labelText: 'End Year',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Skills
                  TextFormField(
                    controller: _skillsController,
                    decoration: InputDecoration(
                      labelText: 'Skills (comma separated)',
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
                    child: const Text('Save Changes'),
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
