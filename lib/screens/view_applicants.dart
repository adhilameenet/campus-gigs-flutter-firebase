// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ViewApplicantsPage extends StatefulWidget {
//   const ViewApplicantsPage({Key? key}) : super(key: key);

//   @override
//   _ViewApplicantsPageState createState() => _ViewApplicantsPageState();
// }

// class _ViewApplicantsPageState extends State<ViewApplicantsPage> {
//   String? _selectedJobId;
//   List<String> _jobIds = [];
//   String jobTitle = "";
//   String location = "";
//   List<Map<String, dynamic>> applicantDetails = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchJobIds(); // Fetch job ids for the dropdown
//   }

//   Future<void> _fetchJobIds() async {
//     var jobSnapshot = await FirebaseFirestore.instance.collection('jobs').get();
//     setState(() {
//       _jobIds = jobSnapshot.docs.map((doc) => doc.id).toList();
//     });
//   }

//   Future<void> _fetchJobDetails(String jobId) async {
//     var jobSnapshot =
//         await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
//     if (jobSnapshot.exists) {
//       setState(() {
//         jobTitle = jobSnapshot['job_title'] ?? 'N/A';
//         location = jobSnapshot['location'] ?? 'N/A';
//       });
//     }
//   }

//   Future<void> _fetchApplicants() async {
//     if (_selectedJobId == null) return;

//     var applicantsSnapshot = await FirebaseFirestore.instance
//         .collection('applicants')
//         .where('job_id', isEqualTo: _selectedJobId)
//         .get();

//     List<Map<String, dynamic>> applicantList = [];

//     // For each applicant, fetch the student details from the 'students' collection
//     for (var applicant in applicantsSnapshot.docs) {
//       var studentId = applicant['student_id'];
//       var studentSnapshot = await FirebaseFirestore.instance
//           .collection('students')
//           .doc(studentId)
//           .get();

//       if (studentSnapshot.exists) {
//         applicantList.add({
//           'firstName': studentSnapshot['firstName'] ?? 'N/A',
//           'lastName': studentSnapshot['lastName'] ?? 'N/A',
//           'email': studentSnapshot['email'] ?? 'N/A',
//           'resume': studentSnapshot['resume'] ?? 'No resume available',
//         });
//       }
//     }

//     setState(() {
//       applicantDetails = applicantList;
//     });
//   }

//   Future<void> _downloadResume(String resumeUrl) async {
//     if (await canLaunch(resumeUrl)) {
//       await launch(resumeUrl);
//     } else {
//       throw 'Could not launch $resumeUrl';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Select a Job:',
//                 style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 8,
//                   ),
//                 ],
//               ),
//               child: DropdownButton<String>(
//                 value: _selectedJobId,
//                 hint: const Text('Select Job'),
//                 isExpanded: true,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedJobId = newValue;
//                   });
//                   if (newValue != null) {
//                     _fetchJobDetails(newValue);
//                   }
//                 },
//                 items: _jobIds
//                     .map((jobId) => DropdownMenuItem<String>(
//                           value: jobId,
//                           child:
//                               Text(jobId, style: const TextStyle(fontSize: 16)),
//                         ))
//                     .toList(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed:
//                   _selectedJobId == null ? null : () => _fetchApplicants(),
//               child: const Text('Fetch Applicants'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     _selectedJobId == null ? Colors.grey : Colors.blueAccent,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 textStyle:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_selectedJobId != null)
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 10),
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 2,
//                       blurRadius: 6,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Job Title: $jobTitle',
//                         style: Theme.of(context).textTheme.titleLarge),
//                     const SizedBox(height: 10),
//                     Text('Location: $location',
//                         style: Theme.of(context).textTheme.bodyMedium),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 20),
//             if (applicantDetails.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: applicantDetails.length,
//                   itemBuilder: (context, index) {
//                     var applicant = applicantDetails[index];
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.all(16),
//                         title: Text(
//                             '${applicant['firstName']} ${applicant['lastName']}'),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Email: ${applicant['email']}'),
//                             const SizedBox(height: 5),
//                             Text('Resume:'),
//                             Row(
//                               children: [
//                                 TextButton(
//                                   onPressed: () {
//                                     if (applicant['resume'] !=
//                                         'No resume available') {
//                                       _downloadResume(applicant['resume']);
//                                     }
//                                   },
//                                   child: Text(
//                                     applicant['resume'] != 'No resume available'
//                                         ? 'Download Resume'
//                                         : 'No Resume Available',
//                                     style: TextStyle(
//                                       color: applicant['resume'] !=
//                                               'No resume available'
//                                           ? Colors.blueAccent
//                                           : Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             else
//               const Center(
//                 child: Text('No applicants found for the selected job.'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewApplicantsPage extends StatefulWidget {
  const ViewApplicantsPage({Key? key}) : super(key: key);

  @override
  _ViewApplicantsPageState createState() => _ViewApplicantsPageState();
}

class _ViewApplicantsPageState extends State<ViewApplicantsPage> {
  String? _selectedJobId;
  List<String> _jobIds = [];
  String jobTitle = "";
  String location = "";
  List<Map<String, dynamic>> applicantDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchJobIds(); // Fetch job ids for the dropdown
  }

  Future<void> _fetchJobIds() async {
    var jobSnapshot = await FirebaseFirestore.instance.collection('jobs').get();
    setState(() {
      _jobIds = jobSnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _fetchJobDetails(String jobId) async {
    var jobSnapshot =
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
    if (jobSnapshot.exists) {
      setState(() {
        jobTitle = jobSnapshot['job_title'] ?? 'N/A';
        location = jobSnapshot['location'] ?? 'N/A';
      });
    }
  }

  Future<void> _fetchApplicants() async {
    if (_selectedJobId == null) return;

    var applicantsSnapshot = await FirebaseFirestore.instance
        .collection('applicants')
        .where('job_id', isEqualTo: _selectedJobId)
        .get();

    List<Map<String, dynamic>> applicantList = [];

    // For each applicant, fetch the student details from the 'students' collection
    for (var applicant in applicantsSnapshot.docs) {
      var studentId = applicant['student_id'];
      var studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      if (studentSnapshot.exists) {
        applicantList.add({
          'firstName': studentSnapshot['firstName'] ?? 'N/A',
          'lastName': studentSnapshot['lastName'] ?? 'N/A',
          'email': studentSnapshot['email'] ?? 'N/A',
          'resume': studentSnapshot['resume'] ?? 'No resume available',
          'phoneno': studentSnapshot['phoneno'] ?? 'No phone number available',
        });
      }
    }

    setState(() {
      applicantDetails = applicantList;
    });
  }

  Future<void> _downloadResume(String resumeUrl) async {
    if (await canLaunch(resumeUrl)) {
      await launch(resumeUrl);
    } else {
      throw 'Could not launch $resumeUrl';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a Job:',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: _selectedJobId,
                hint: const Text('Select Job'),
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedJobId = newValue;
                  });
                  if (newValue != null) {
                    _fetchJobDetails(newValue);
                  }
                },
                items: _jobIds
                    .map((jobId) => DropdownMenuItem<String>(
                          value: jobId,
                          child:
                              Text(jobId, style: const TextStyle(fontSize: 16)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _selectedJobId == null ? null : () => _fetchApplicants(),
              child: const Text('Fetch Applicants'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedJobId == null ? Colors.grey : Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedJobId != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Job Title: $jobTitle',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text('Location: $location',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (applicantDetails.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: applicantDetails.length,
                  itemBuilder: (context, index) {
                    var applicant = applicantDetails[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                            '${applicant['firstName']} ${applicant['lastName']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${applicant['email']}'),
                            const SizedBox(height: 5),
                            Text('Phone: '),
                            TextButton(
                              onPressed: () {
                                String phoneNumber = applicant['phoneno'] ?? '';
                                if (phoneNumber.isNotEmpty &&
                                    phoneNumber !=
                                        'No phone number available') {
                                  _makePhoneCall(phoneNumber);
                                }
                              },
                              child: Text(
                                applicant['phoneno'] !=
                                        'No phone number available'
                                    ? applicant['phoneno']
                                    : 'No Phone Available',
                                style: TextStyle(
                                  color: applicant['phoneno'] !=
                                          'No phone number available'
                                      ? Colors.blueAccent
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('Resume:'),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    if (applicant['resume'] !=
                                        'No resume available') {
                                      _downloadResume(applicant['resume']);
                                    }
                                  },
                                  child: Text(
                                    applicant['resume'] != 'No resume available'
                                        ? 'Download Resume'
                                        : 'No Resume Available',
                                    style: TextStyle(
                                      color: applicant['resume'] !=
                                              'No resume available'
                                          ? Colors.blueAccent
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Center(
                child: Text('No applicants found for the selected job.'),
              ),
          ],
        ),
      ),
    );
  }
}
