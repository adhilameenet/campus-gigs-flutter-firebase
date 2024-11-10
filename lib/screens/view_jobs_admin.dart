import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewJobsPage extends StatefulWidget {
  const ViewJobsPage({Key? key}) : super(key: key);

  @override
  _ViewJobsPageState createState() => _ViewJobsPageState();
}

class _ViewJobsPageState extends State<ViewJobsPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data!.docs;
          final filteredJobs = jobs
              .where((job) => (job.data() as Map<String, dynamic>)['job_title']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              _buildSearchField(
                hintText: 'Search jobs...',
                onChanged: (value) => setState(() {
                  searchQuery = value;
                }),
              ),
              const SizedBox(height: 20),
              filteredJobs.isEmpty
                  ? const Center(child: Text('No results found'))
                  : Column(
                      children: filteredJobs
                          .map((jobDoc) => _buildJobTile(jobDoc))
                          .toList(),
                    ),
            ],
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildSearchField(
      {required String hintText, required ValueChanged<String> onChanged}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildJobTile(DocumentSnapshot jobDoc) {
    final job = jobDoc.data() as Map<String, dynamic>;
    final jobTitle = job['job_title'];
    final isActive = job['is_active'] ?? false;

    return GestureDetector(
      onTap: () => _showJobDetails(jobDoc),
      child: Card(
        color: isActive ? Colors.green[100] : Colors.red[100],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(
            jobTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Job ID: ${jobDoc.id}'),
              Text('Status: ${isActive ? "Active" : "Inactive"}'),
              _buildDummyApplicantsCount(),
            ],
          ),
          trailing: const Icon(Icons.info_outline, color: Colors.black54),
        ),
      ),
    );
  }

  // Function to display a dummy count of applicants
  Widget _buildDummyApplicantsCount() {
    return Text('Applicants: 5'); // Dummy count of 5 applicants
  }

  void _showJobDetails(DocumentSnapshot jobDoc) {
    final job = jobDoc.data() as Map<String, dynamic>;
    final jobTitle = job['job_title'];
    final isActive = job['is_active'] ?? false;
    final description = job['description'];
    final location = job['location'];
    final salary = job['salary'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(20),
              title: Center(
                child: Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('Job ID:', jobDoc.id),
                    _buildDetailRow('Description:', description),
                    _buildDetailRow('Location:', location),
                    _buildDetailRow('Salary:', salary.toString()),
                    _buildDetailRow(
                        'Status:', isActive ? "Active" : "Inactive"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: const Text('Close',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
