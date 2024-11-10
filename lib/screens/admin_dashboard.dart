import 'package:flutter/material.dart';
import 'admin_login.dart';
import 'view_students.dart';
import 'view_employers.dart';
import 'verify_students.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  int? _currentSelectedIndex; // No default selection
  bool _isCollapsed = true; // Initial state for sidebar

  final _pages = [
    // ViewStudentsPage(),
    VerifyStudentsPage(),
    ListEmployersPage(),

    // Add more pages here as needed
  ];

  final List<String> _pageTitles = [
    'View Students',
    'View Employers',
  ];

  // Toggle sidebar collapse/expand
  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  void _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminLoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentSelectedIndex != null
              ? _pageTitles[_currentSelectedIndex!]
              : 'Dashboard',
        ),
        backgroundColor: Colors.blue, // Use a standard blue color for appbar
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleSidebar,
        ),
      ),
      body: Stack(
        children: [
          _currentSelectedIndex != null
              ? _pages[_currentSelectedIndex!] // Display selected page
              : const Center(
                  child: Text(
                    'Welcome to Admin Dashboard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
          if (!_isCollapsed) _buildDropdownSidebar(), // Overlay sidebar
        ],
      ),
    );
  }

  // Sidebar widget as an overlay dropdown
  Widget _buildDropdownSidebar() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isCollapsed ? 0 : 240, // Increase width for visibility
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container for the profile section at the top
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue, // Changed to blue for consistency
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings,
                        color: Colors.blue), // Admin icon
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Admin',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('CampusGigs', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            // Sidebar Menu
            Expanded(
              child: ListView(
                children: [
                  _buildSidebarItem(Icons.schedule, 'View Students', 0),
                  _buildSidebarItem(Icons.business, 'View Employers', 1),
                ],
              ),
            ),
            // Logout button after admin options
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _logout,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor:
                      Colors.grey.shade200, // Black text for contrast
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar item widget
  Widget _buildSidebarItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue), // Blue color for icons
      title: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
      selected: _currentSelectedIndex == index,
      selectedTileColor:
          Colors.blue.shade100, // Light blue background when selected
      onTap: () {
        setState(() {
          _currentSelectedIndex = index;
          _isCollapsed = true; // Collapse sidebar after selection
        });
      },
    );
  }
}
