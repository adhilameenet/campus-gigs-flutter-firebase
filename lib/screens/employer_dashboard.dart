import 'package:flutter/material.dart';
import 'add_job_details.dart'; // Import the relevant screen

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
  int _currentSelectedIndex = 0; // Index to keep track of the selected page
  bool _isCollapsed = true; // State for sidebar collapse/expand

  // Adding a simple dashboard page initially
  final _pages = [
    Center(
      child: Text('Welcome to Employer Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    ),
    AddJobDetailsScreen(), // The screen for Job Details
    // Add other pages like TutorsPage, SchedulePage, etc. when needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        backgroundColor: Colors.teal,
      ),
      drawer: _buildDrawer(), // Drawer for the sidebar navigation
      body: _pages[
          _currentSelectedIndex], // Main content area based on selected index
    );
  }

  // Drawer widget to create a collapsible sidebar
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Employer Name'),
            accountEmail: const Text('employer@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.business, color: Colors.teal),
            ),
            decoration: BoxDecoration(color: Colors.teal),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Job Details'),
            onTap: () {
              setState(() {
                _currentSelectedIndex = 1; // Navigate to the Job Details page
              });
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Tutors'),
            onTap: () {
              setState(() {
                _currentSelectedIndex =
                    2; // Navigate to the Tutors page (if added)
              });
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule'),
            onTap: () {
              setState(() {
                _currentSelectedIndex =
                    3; // Navigate to the Schedule page (if added)
              });
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Messages'),
            onTap: () {
              setState(() {
                _currentSelectedIndex =
                    4; // Navigate to the Messages page (if added)
              });
              Navigator.pop(context); // Close the drawer
            },
          ),
          const Spacer(), // Pushes logout button to the bottom
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Implement your logout logic here
              Navigator.pushReplacementNamed(context,
                  '/employer-login'); // Navigate to login screen (example)
            },
          ),
        ],
      ),
    );
  }
}
