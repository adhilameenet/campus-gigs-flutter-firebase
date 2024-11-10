import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppliedJobsPage extends StatefulWidget {
  const AppliedJobsPage({Key? key}) : super(key: key);

  @override
  _AppliedJobsPageState createState() => _AppliedJobsPageState();
}

class _AppliedJobsPageState extends State<AppliedJobsPage> {
  String studentId = ""; // Will store the current logged-in user's ID

  @override
  void initState() {
    super.initState();
    // Get the current logged-in student's ID
    studentId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (studentId.isEmpty) {
      // Handle case when the user is not logged in
      // For example, navigate to login screen or show a message
      print('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentId.isEmpty) {
      // Show loading or error state if the studentId is not available
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Applied Jobs'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applicants')
            .where('student_id', isEqualTo: studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No applied jobs.'));
          }

          var appliedJobs = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: appliedJobs.length,
              itemBuilder: (context, index) {
                String jobId = appliedJobs[index]['job_id'];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('jobs')
                      .doc(jobId)
                      .get(),
                  builder: (context, jobSnapshot) {
                    if (jobSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    if (!jobSnapshot.hasData || !jobSnapshot.data!.exists) {
                      return const SizedBox.shrink();
                    }

                    var jobData = jobSnapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildJobDetailTile(jobData),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobDetailTile(DocumentSnapshot jobData) {
    bool isActive = jobData['is_active'] ?? false;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveStatus(isActive),
            const SizedBox(height: 12),
            _buildDetailRow(
                'Job Title', jobData['job_title'] ?? 'N/A', Icons.work),
            const SizedBox(height: 12),
            _buildDetailRow(
                'Location', jobData['location'] ?? 'N/A', Icons.location_on),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveStatus(bool isActive) {
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.remove_circle,
          color: isActive ? Colors.green : Colors.red,
          size: 30,
        ),
        const SizedBox(width: 12),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800])),
            ],
          ),
        ),
      ],
    );
  }
}
