import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'student_edit_profile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentSelectedIndex = 0;
  bool _isProfileSelected = false; // Flag to track profile selection
  final _pages = [
    const EditProfilePage(), // Profile page
    // SchedulePage(), // Other pages can be added here
    // MessagesPage()
  ];

  User? user;
  String firstName = '';
  String lastName = '';
  String userEmail = '';

  // Drawer key to control opening/closing
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Fetch user profile data from the 'students' collection
  Future<void> _loadUserProfile() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.uid)
          .get();
      if (userData.exists) {
        setState(() {
          firstName = userData['firstName'];
          lastName = userData['lastName'];
          userEmail = userData['email'];
        });
      }
    }
  }

  // Logout function
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/student-login'); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the scaffold key to control the drawer
      appBar: AppBar(
        title: const Text('Tutor Finder'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.menu), // Hamburger menu icon
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Open the sidebar (drawer)
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('$firstName $lastName'),
              accountEmail: Text(userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                setState(() {
                  _currentSelectedIndex = 0; // Show Profile page
                  _isProfileSelected = true; // Profile is selected
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: const Text('View Jobs'),
              onTap: () {
                // Navigate to Tutors page (Add implementation)
                Navigator.pushNamed(context, '/view-jobs');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Main content area: Show profile or other pages based on selection
          Expanded(
            child: _isProfileSelected
                ? _pages[0]
                : const Center(
                    child: Text('Select an option from the sidebar')),
          ),
        ],
      ),
    );
  }
}
