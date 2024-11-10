import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'employer_edit_profile.dart';
import 'add_job_details.dart';
import 'view_jobs_employer.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
  int _currentSelectedIndex = 0; // Index to keep track of the selected page
  bool _isProfileSelected = false; // Flag to track profile selection

  // Pages for the employer dashboard
  final _pages = [
    const EditEmployerProfilePage(), // Edit Profile Page
    const AddJobDetailsScreen(),
    const ViewJobsScreen()
    // Add more pages as needed, e.g., MessagesPage(), JobsPage()
  ];

  // Dummy data for employer profile
  String employerName = 'Loading...';
  String employerEmail = 'Loading...';

  // Drawer key to control opening/closing
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadEmployerDetails(); // Fetch employer details when the widget is created
  }

  // Fetch employer details from the Firestore 'employers' collection
  Future<void> _loadEmployerDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final employerData = await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid) // Get the employer document by UID
          .get();

      if (employerData.exists) {
        setState(() {
          employerName = employerData[
              'company_name']; // Assuming field 'name' exists in 'employers' collection
          employerEmail = employerData[
              'email']; // Assuming field 'email' exists in 'employers' collection
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the scaffold key to control the drawer
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
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
              accountName: Text(employerName),
              accountEmail: Text(employerEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.business, color: Colors.teal),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Edit Profile'),
              onTap: () {
                setState(() {
                  _currentSelectedIndex = 0; // Show Edit Profile page
                  _isProfileSelected = true; // Profile is selected
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Add Job'),
              onTap: () {
                setState(() {
                  _currentSelectedIndex = 1; // Show Add Job Details page
                  _isProfileSelected = false; // Reset profile selection flag
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('View Jobs'),
              onTap: () {
                setState(() {
                  _currentSelectedIndex = 2; // Show Add Job Details page
                  _isProfileSelected = false; // Reset profile selection flag
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            // Add other pages like Messages, Jobs, etc. as needed
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                // Implement your logout logic here
                Navigator.pushReplacementNamed(
                    context, '/employer-login'); // Navigate to login screen
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Main content area: Show the page based on the selected index
          Expanded(
            child: _isProfileSelected
                ? _pages[0] // Show Edit Profile page
                : _pages[_currentSelectedIndex], // Show selected page
          ),
        ],
      ),
    );
  }
}
