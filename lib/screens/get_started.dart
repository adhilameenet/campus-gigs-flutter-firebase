import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Light background color for the entire screen
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the content vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center the content horizontally
            children: [
              // Large Icon at the top with a light background
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey[
                      50], // Light grey background for the icon circle
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.school, // Suitable icon for a campus-related theme
                  size: 80,
                  color: Color(
                      0xFF0D47A1), // Blue color matching the professional theme
                ),
              ),
              const SizedBox(height: 30),

              // Title and Intro Text without shadow in a light, semi-transparent container
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white, // White background for content
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome to CampusGigs!', // One line title
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1), // Blue color for title
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Find part-time jobs tailored for CETians. Get started below!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey[700], // Light text color
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Login Buttons with a light background
              _buildLoginButton(
                label: 'Login as Student',
                icon: Icons.school,
                onPressed: () {
                  Navigator.pushNamed(context, '/student-login');
                },
              ),
              const SizedBox(height: 20),

              _buildLoginButton(
                label: 'Login as Employer',
                icon: Icons.business_center,
                onPressed: () {
                  Navigator.pushNamed(context, '/employer-login');
                },
              ),
              const SizedBox(height: 20),

              _buildLoginButton(
                label: 'Login as Admin',
                icon: Icons.admin_panel_settings,
                onPressed: () {
                  Navigator.pushNamed(context, '/admin-login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom method for creating login buttons with refined shadow styling
  Widget _buildLoginButton(
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for the button
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Soft shadow for the button
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Color(0xFF0D47A1)), // Blue color for icons
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D47A1), // Blue color for text
          ),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 55),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: Colors.white, // White button background
          shadowColor: Colors.transparent, // Remove default shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
