import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddJobDetailsScreen extends StatefulWidget {
  const AddJobDetailsScreen({super.key});

  @override
  _AddJobDetailsScreenState createState() => _AddJobDetailsScreenState();
}

class _AddJobDetailsScreenState extends State<AddJobDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _qualificationsController =
      TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  DateTime? _deadline; // To store selected date
  bool _isActive = true; // To store whether job is active or not
  String? _selectedHours; // To store selected hours
  String? _selectedSkills; // To store selected skills from dropdown

  // Skills dropdown for part-time jobs
  final List<String> skillsList = [
    'Teaching',
    'Catering',
    'Cleaning',
    'Tutoring',
    'Delivery'
  ];

  // Working hours dropdown (0-9)
  final List<String> hoursList = List.generate(10, (index) => index.toString());

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _qualificationsController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submitJobDetails() {
    if (_formKey.currentState!.validate()) {
      if (_deadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a deadline')),
        );
        return;
      }

      // Store job details in Firestore 'jobs' collection
      FirebaseFirestore.instance.collection('jobs').add({
        'job_title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'salary': _salaryController.text,
        'working_hours': _selectedHours,
        'skills_required': _selectedSkills,
        'deadline': _deadline,
        'is_active': _isActive,
        'qualifications': _qualificationsController.text,
        'published_at': FieldValue
            .serverTimestamp(), // Add published_at field with current timestamp
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job details added successfully!')),
        );
        _clearForm(); // Clear the form after submission
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding job: $error')),
        );
      });
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _salaryController.clear();
    _qualificationsController.clear();
    _skillsController.clear();
    setState(() {
      _deadline = null;
      _isActive = true;
      _selectedHours = null;
      _selectedSkills = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Job Information',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 16),
            // Job Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Enter a job title' : null,
            ),
            const SizedBox(height: 16),
            // Job Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Job Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Enter a job description' : null,
            ),
            const SizedBox(height: 16),
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Enter a location' : null,
            ),
            const SizedBox(height: 16),
            // Salary Range
            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Salary Range',
                border: OutlineInputBorder(),
                hintText: 'e.g. 40,000 - 60,000',
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Enter a salary range' : null,
            ),
            const SizedBox(height: 16),
            // Working Hours (Dropdown)
            DropdownButtonFormField<String>(
              value: _selectedHours,
              decoration: const InputDecoration(
                labelText: 'Working Hours',
                border: OutlineInputBorder(),
              ),
              items: hoursList.map((hours) {
                return DropdownMenuItem<String>(
                  value: hours,
                  child: Text('$hours hours'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHours = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Select working hours' : null,
            ),
            const SizedBox(height: 16),
            // Skills Required (Dropdown)
            DropdownButtonFormField<String>(
              value: _selectedSkills,
              decoration: const InputDecoration(
                labelText: 'Skills Required',
                border: OutlineInputBorder(),
              ),
              items: skillsList.map((skill) {
                return DropdownMenuItem<String>(
                  value: skill,
                  child: Text(skill),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSkills = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Select required skills' : null,
            ),
            const SizedBox(height: 16),
            // Deadline (Date Picker)
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: _deadline == null
                    ? 'Deadline (Select Date)'
                    : 'Deadline: ${_deadline!.toLocal()}'.split(' ')[0],
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _deadline = selectedDate;
                      });
                    }
                  },
                ),
              ),
              validator: (value) =>
                  _deadline == null ? 'Select a deadline' : null,
            ),
            const SizedBox(height: 16),
            // Is Active (Boolean Toggle)
            Row(
              children: [
                const Text('Job Active'),
                Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitJobDetails,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.teal,
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
