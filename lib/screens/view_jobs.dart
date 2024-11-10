import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // For sending emails

class JobDetailsViewPage extends StatefulWidget {
  const JobDetailsViewPage({Key? key}) : super(key: key);

  @override
  _JobDetailsViewPageState createState() => _JobDetailsViewPageState();
}

class _JobDetailsViewPageState extends State<JobDetailsViewPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, String?> _filters =
      {}; // Make sure it's String? to allow null values
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
                Icons.calendar_today),
            const SizedBox(height: 12),
            _buildDetailRow('Qualifications',
                jobData['qualifications'] ?? 'N/A', Icons.assignment),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isApplied
                        ? null
                        : () {
                            setState(() {
                              isApplied = true;
                            });
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
            color: Colors.blueAccent),
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
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                softWrap: true,
              ),
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
        const SizedBox(width: 20),
        Expanded(child: _buildDetailRow(title2, value2, Icons.attach_money)),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Jobs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: _filters['job_title'],
                onChanged: (value) {
                  setState(() {
                    _filters['job_title'] = value;
                  });
                },
                items: _jobTitles
                    .map((title) => DropdownMenuItem<String>(
                          value: title,
                          child: Text(title),
                        ))
                    .toList(),
                hint: const Text('Select Job Title'),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                isExpanded: true,
                value: _filters['location'],
                onChanged: (value) {
                  setState(() {
                    _filters['location'] = value;
                  });
                },
                items: _locations
                    .map((location) => DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                hint: const Text('Select Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filters.clear();
                });
                Navigator.pop(context);
              },
              child: const Text('Clear Filters'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        );
      },
    );
  }
}
