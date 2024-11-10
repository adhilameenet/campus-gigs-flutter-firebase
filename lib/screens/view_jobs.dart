import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobDetailsViewPage extends StatefulWidget {
  const JobDetailsViewPage({Key? key}) : super(key: key);

  @override
  _JobDetailsViewPageState createState() => _JobDetailsViewPageState();
}

class _JobDetailsViewPageState extends State<JobDetailsViewPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, String?> _filters = {}; // Allows null values
  List<String> _jobTitles = ['Developer', 'Designer', 'Manager', 'Analyst'];
  List<String> _locations = ['Remote', 'New York', 'San Francisco', 'London'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Job Listings'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .where('job_title', isGreaterThanOrEqualTo: _searchQuery)
                  .where('job_title', isLessThan: _searchQuery + 'z')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No jobs available.'));
                }

                var jobDataList = snapshot.data!.docs;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: jobDataList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildJobDetailTile(jobDataList[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetailTile(QueryDocumentSnapshot jobData) {
    bool isApplied = false;

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
            _buildActiveStatus(jobData['is_active']),
            const SizedBox(height: 12),
            _buildPublishedDate(jobData['published_at']),
            const SizedBox(height: 12),
            _buildDetailRow(
                'Job Title', jobData['job_title'] ?? 'N/A', Icons.work),
            const SizedBox(height: 12),
            _buildDetailRow('Job Description', jobData['description'] ?? 'N/A',
                Icons.description),
            const SizedBox(height: 12),
            _buildTwoFieldsRow('Location', jobData['location'] ?? 'N/A',
                'Salary Range', jobData['salary'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Deadline',
              jobData['deadline'] != null
                  ? (jobData['deadline'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .toString()
                  : 'N/A',
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Qualifications',
                jobData['qualifications'] ?? 'N/A', Icons.assignment),
            const SizedBox(height: 12),
            _buildSkillsChips(jobData['skills_required'] ?? ''),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isApplied
                        ? null
                        : () {
                            _showApplyDialog(jobData.id);
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Apply'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isApplied ? Colors.grey : Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () async {
                      String employerEmail =
                          await _getEmployerEmail(jobData['employee_id']);
                      if (await canLaunch('mailto:$employerEmail')) {
                        await launch(
                            'mailto:$employerEmail?subject=Job Application&body=I am interested in the job listing for ${jobData['job_title']} and have attached my resume.');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not send email.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.email, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Contact Employer'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getEmployerEmail(String employeeId) async {
    DocumentSnapshot employerDoc = await FirebaseFirestore.instance
        .collection('employers')
        .doc(employeeId)
        .get();
    return employerDoc['email'] ?? '';
  }

  void _showApplyDialog(String jobId) {
    String studentId = FirebaseAuth.instance.currentUser!.uid;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Application'),
          content: Text('Job ID: $jobId\nStudent ID: $studentId'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveApplication(jobId, studentId);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveApplication(String jobId, String studentId) {
    FirebaseFirestore.instance.collection('applicants').add({
      'job_id': jobId,
      'student_id': studentId,
      'applied_at': Timestamp.now(),
    });
  }

  Widget _buildPublishedDate(Timestamp? publishedAt) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        publishedAt != null
            ? 'Published on: ${publishedAt.toDate().toLocal()}'
            : 'Published on: N/A',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildActiveStatus(bool? isActive) {
    return Row(
      children: [
        Icon(
          isActive != null && isActive
              ? Icons.check_circle
              : Icons.remove_circle,
          color: isActive != null && isActive ? Colors.green : Colors.red,
          size: 30,
        ),
        const SizedBox(width: 12),
        Text(
          isActive != null && isActive ? 'Active' : 'Inactive',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive != null && isActive ? Colors.green : Colors.red),
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

  Widget _buildTwoFieldsRow(
      String title1, String value1, String title2, String value2) {
    return Row(
      children: [
        Expanded(child: _buildDetailRow(title1, value1, Icons.location_on)),
        const SizedBox(width: 16),
        Expanded(child: _buildDetailRow(title2, value2, Icons.attach_money)),
      ],
    );
  }

  Widget _buildSkillsChips(String skills) {
    List<String> skillList = skills.split(', ');
    return Wrap(
      spacing: 8,
      children: skillList
          .map((skill) => Chip(
                label: Text(skill),
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
              ))
          .toList(),
    );
  }

  void _showFilterDialog() {
    // Implement the filter dialog based on _jobTitles, _locations, etc.
  }
}
