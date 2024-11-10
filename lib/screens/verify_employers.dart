import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerifyEmployersPage extends StatefulWidget {
  const VerifyEmployersPage({Key? key}) : super(key: key);

  @override
  _VerifyEmployersPageState createState() => _VerifyEmployersPageState();
}

class _VerifyEmployersPageState extends State<VerifyEmployersPage> {
  String verifiedSearchQuery = '';
  String notVerifiedSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('employers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final employers = snapshot.data!.docs;
          final verifiedEmployers = employers
              .where((employer) =>
                  (employer.data() as Map<String, dynamic>)['isVerified'] ==
                      true &&
                  _matchesQuery((employer.data() as Map<String, dynamic>),
                      verifiedSearchQuery))
              .toList();
          final notVerifiedEmployers = employers
              .where((employer) =>
                  (employer.data() as Map<String, dynamic>)['isVerified'] ==
                      false &&
                  _matchesQuery((employer.data() as Map<String, dynamic>),
                      notVerifiedSearchQuery))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              // Verified Section
              _buildSectionHeader('Verified', Colors.black),
              _buildSearchField(
                hintText: 'Search verified employers...',
                onChanged: (value) => setState(() {
                  verifiedSearchQuery = value;
                }),
              ),
              const SizedBox(height: 10),
              verifiedEmployers.isEmpty
                  ? const Center(child: Text('No results found'))
                  : Column(
                      children: verifiedEmployers
                          .map((employerDoc) =>
                              _buildEmployerTile(employerDoc, true))
                          .toList(),
                    ),
              const SizedBox(height: 20),

              // Not Verified Section
              _buildSectionHeader('Not Verified', Colors.black),
              _buildSearchField(
                hintText: 'Search not verified employers...',
                onChanged: (value) => setState(() {
                  notVerifiedSearchQuery = value;
                }),
              ),
              const SizedBox(height: 10),
              notVerifiedEmployers.isEmpty
                  ? const Center(child: Text('No results found'))
                  : Column(
                      children: notVerifiedEmployers
                          .map((employerDoc) =>
                              _buildEmployerTile(employerDoc, false))
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

  bool _matchesQuery(Map<String, dynamic> employer, String query) {
    final companyName = employer['company_name'].toString().toLowerCase();
    final registrationNo = employer['registrationNo'].toString().toLowerCase();
    return companyName.contains(query.toLowerCase()) ||
        registrationNo.contains(query.toLowerCase());
  }

  Widget _buildEmployerTile(DocumentSnapshot employerDoc, bool isVerified) {
    final employer = employerDoc.data() as Map<String, dynamic>;
    final tileColor = isVerified ? Colors.green[100] : Colors.red[100];
    final icon = isVerified ? Icons.check_circle_outline : Icons.error_outline;

    return GestureDetector(
      onTap: () => _showEmployerDetails(employerDoc),
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
            employer['company_name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registration No: ${employer['registrationNo']}'),
              Text('Email: ${employer['email']}'),
              Text('Status: ${isVerified ? "Verified" : "Not Verified"}'),
            ],
          ),
          trailing: const Icon(Icons.info_outline, color: Colors.black54),
        ),
      ),
    );
  }

  void _showEmployerDetails(DocumentSnapshot employerDoc) {
    final employer = employerDoc.data() as Map<String, dynamic>;
    bool isVerified = employer['isVerified'] ?? false;

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
                  employer['company_name'],
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
                    // Logo (if available)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: employer['logo'] != null
                          ? NetworkImage(employer['logo'])
                          : const AssetImage('assets/default_logo.png')
                              as ImageProvider,
                      onBackgroundImageError: (_, __) =>
                          const AssetImage('assets/default_logo.png'),
                    ),
                    const SizedBox(height: 20),

                    // Additional Details
                    _buildDetailRow(
                        'Registration No:', employer['registrationNo']),
                    _buildDetailRow('Email:', employer['email']),
                    _buildDetailRow('Description:', employer['description']),
                    _buildDetailRow('Location:', employer['location']),
                    _buildDetailRow('Website:', employer['website']),
                    _buildDetailRow('Verified Status:',
                        isVerified ? "Verified" : "Not Verified"),

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
                                .collection('employers')
                                .doc(employerDoc.id)
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
