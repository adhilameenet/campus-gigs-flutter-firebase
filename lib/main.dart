import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login.dart';
import 'screens/admin_login.dart';
import 'screens/get_started.dart';
import 'screens/student_signup.dart';
import 'screens/employer_signup.dart';
import 'screens/student_dashboard.dart';
import 'screens/employer_dashboard.dart';
import 'screens/employer_edit_profile.dart';
import 'screens/add_job_details.dart';
import 'screens/view_jobs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAppCheck.instance.activate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const GetStartedScreen(),
      theme: ThemeData(fontFamily: 'Poppins'),
      routes: {
        '/student-login': (context) => const LoginPage(role: 'Student'),
        '/employer-login': (context) => const LoginPage(role: 'Employer'),
        '/admin-login': (context) => const AdminLoginPage(),
        '/student-signup': (context) => const StudentSignUpPage(),
        '/employer-signup': (context) => const EmployerSignUpScreen(),
        '/student-dashboard': (context) => const StudentDashboard(),
        '/employer-dashboard': (context) => const EmployerDashboard(),
        '/employer-edit-profile': (context) => EditEmployerProfilePage(),
        '/add-job-details': (context) => AddJobDetailsScreen(),
        '/view-jobs': (context) => JobDetailsViewPage()
      },
    );
  }
}
