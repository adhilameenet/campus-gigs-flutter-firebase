import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_edit_profile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  int _currentSelectedIndex = 0;
  bool _isCollapsed = true; // State for sidebar collapse/expand
  final _pages = [
    // StudentProfilePage(studentId: FirebaseAuth.instance.currentUser!.uid),
    const EditProfilePage(),
    // SchedulePage(),
    // MessagesPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Finder'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          _pages[_currentSelectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.green,
        currentIndex: _currentSelectedIndex,
        onTap: (newIndex) {
          setState(() {
            _currentSelectedIndex = newIndex;
            if (newIndex == 2) {
              _isCollapsed = !_isCollapsed;
            } else {
              _isCollapsed = true;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tutors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
        ],
      ),
    );
  }
}
