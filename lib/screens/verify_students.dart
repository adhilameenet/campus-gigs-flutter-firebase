import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerifyStudentsPage extends StatefulWidget {
  const VerifyStudentsPage({Key? key}) : super(key: key);

  @override
  _VerifyStudentsPageState createState() => _VerifyStudentsPageState();
}

class _VerifyStudentsPageState extends State<VerifyStudentsPage> {
  String verifiedSearchQuery = '';
  String notVerifiedSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;
          final verifiedStudents = students
              .where((student) =>
                  (student.data() as Map<String, dynamic>)['isVerified'] ==
                      true &&
                  _matchesQuery((student.data() as Map<String, dynamic>),
                      verifiedSearchQuery))
              .toList();
          final notVerifiedStudents = students
              .where((student) =>
                  (student.data() as Map<String, dynamic>)['isVerified'] ==
                      false &&
                  _matchesQuery((student.data() as Map<String, dynamic>),
                      notVerifiedSearchQuery))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              // Verified Section
              _buildSectionHeader('Verified', Colors.black),
              _buildSearchField(
                hintText: 'Search verified students...',
                onChanged: (value) => setState(() {
                  verifiedSearchQuery = value;
                }),
              ),
              const SizedBox(height: 10),
              verifiedStudents.isEmpty
                  ? const Center(child: Text('No results found'))
                  : Column(
                      children: verifiedStudents
                          .map((studentDoc) =>
                              _buildStudentTile(studentDoc, true))
                          .toList(),
                    ),
              const SizedBox(height: 20),

              // Not Verified Section
              _buildSectionHeader('Not Verified', Colors.black),
              _buildSearchField(
                hintText: 'Search not verified students...',
                onChanged: (value) => setState(() {
                  notVerifiedSearchQuery = value;
                }),
              ),
              const SizedBox(height: 10),
              notVerifiedStudents.isEmpty
                  ? const Center(child: Text('No results found'))
                  : Column(
                      children: notVerifiedStudents
                          .map((studentDoc) =>
                              _buildStudentTile(studentDoc, false))
                          .toList(),
                    ),
            ],
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style:
            TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
      ),
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

  bool _matchesQuery(Map<String, dynamic> student, String query) {
    final name = '${student['firstName']} ${student['lastName']}'.toLowerCase();
    final registrationNo = student['registrationNo'].toString().toLowerCase();
    return name.contains(query.toLowerCase()) ||
        registrationNo.contains(query.toLowerCase());
  }

  Widget _buildStudentTile(DocumentSnapshot studentDoc, bool isVerified) {
    final student = studentDoc.data() as Map<String, dynamic>;
    final tileColor = isVerified ? Colors.green[100] : Colors.red[100];
    final icon = isVerified ? Icons.check_circle_outline : Icons.error_outline;

    return GestureDetector(
      onTap: () => _showStudentDetails(studentDoc),
      child: Card(
        color: tileColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: Icon(icon,
              color: isVerified ? Colors.green : Colors.red, size: 36),
          title: Text(
            '${student['firstName']} ${student['lastName']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registration No: ${student['registrationNo']}'),
              Text('Email: ${student['email']}'),
              Text('Status: ${isVerified ? "Verified" : "Not Verified"}'),
            ],
          ),
          trailing: const Icon(Icons.info_outline, color: Colors.black54),
        ),
      ),
    );
  }

  void _showStudentDetails(DocumentSnapshot studentDoc) {
    final student = studentDoc.data() as Map<String, dynamic>;
    bool isVerified = student['isVerified'] ?? false;

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
                  '${student['firstName']} ${student['lastName']}',
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
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: student['profilePicture'] != null
                          ? NetworkImage(student['profilePicture'])
                          : const AssetImage('assets/user.png')
                              as ImageProvider,
                      onBackgroundImageError: (_, __) =>
                          const AssetImage('assets/user.png'),
                    ),
                    const SizedBox(height: 20),

                    // Additional Details
                    _buildDetailRow(
                        'Registration No:', student['registrationNo']),
                    _buildDetailRow('Email:', student['email']),
                    _buildDetailRow('Course:', student['course']),
                    _buildDetailRow('Start Year:', student['startYear']),
                    _buildDetailRow('End Year:', student['endYear']),
                    _buildDetailRow(
                        'Skills:', (student['skills'] as List).join(', ')),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Verified Status:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Switch(
                          value: isVerified,
                          onChanged: (bool value) async {
                            await FirebaseFirestore.instance
                                .collection('students')
                                .doc(studentDoc.id)
                                .update({'isVerified': value});
                            setState(() {
                              isVerified = value;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
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
                      child: const Text('Close'),
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
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
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
