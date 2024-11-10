import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

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

  DateTime? _deadline;
  bool _isActive = true;
  String? _selectedHours;
  Map<String, bool> _selectedSkillsMap = {}; // Changed to a Map

  final List<String> skillsList = [
    'Teaching',
    'Catering',
    'Cleaning',
    'Tutoring',
    'Delivery'
  ];

  final List<String> hoursList = List.generate(10, (index) => index.toString());

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _qualificationsController.dispose();
    super.dispose();
  }

  void _submitJobDetails() async {
    if (_formKey.currentState!.validate()) {
      if (_deadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a deadline'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Get the logged-in user's employee ID (UID)
      String? employeeId = FirebaseAuth.instance.currentUser?.uid;
      if (employeeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User is not authenticated.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitting job details...'),
          backgroundColor: Colors.teal,
        ),
      );

      try {
        // Convert skills map to a comma-separated string
        String skillsString = _selectedSkillsMap.keys.join(', ');

        await FirebaseFirestore.instance.collection('jobs').add({
          'job_title': _titleController.text,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'salary': _salaryController.text,
          'working_hours': _selectedHours,
          'skills_required':
              skillsString, // Store skills as a comma-separated string
          'deadline': _deadline,
          'is_active': _isActive,
          'qualifications': _qualificationsController.text,
          'published_at': FieldValue.serverTimestamp(),
          'employee_id': employeeId, // Save employee_id (UID)
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job details added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding job: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _salaryController.clear();
    _qualificationsController.clear();
    setState(() {
      _deadline = null;
      _isActive = true;
      _selectedHours = null;
      _selectedSkillsMap.clear(); // Clear the skills map
    });
  }

  @override
  Widget build(BuildContext context) {
    const OutlineInputBorder formBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      borderSide: BorderSide(color: Colors.teal),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Job Active',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField('Job Title', _titleController),
                const SizedBox(height: 16),
                _buildTextField('Job Description', _descriptionController,
                    maxLines: 5),
                const SizedBox(height: 16),
                _buildTextField('Location', _locationController),
                const SizedBox(height: 16),
                _buildTextField(
                  'Salary Range',
                  _salaryController,
                  hintText: 'e.g. 40,000 - 60,000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  'Working Hours',
                  hoursList,
                  _selectedHours,
                  (value) => setState(() => _selectedHours = value),
                ),
                const SizedBox(height: 16),
                _buildSkillSelector(),
                const SizedBox(height: 16),
                _buildDeadlineField(),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitJobDetails,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.teal,
                      elevation: 5,
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hintText, TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.teal),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.teal),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((item) =>
              DropdownMenuItem(value: item, child: Text('$item hours')))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select $label' : null,
    );
  }

  Widget _buildSkillSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          hint: const Text('Select a Skill'),
          decoration: const InputDecoration(
            labelText: 'Skills Required',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.teal),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: skillsList
              .map(
                  (skill) => DropdownMenuItem(value: skill, child: Text(skill)))
              .toList(),
          onChanged: (value) {
            if (value != null && !_selectedSkillsMap.containsKey(value)) {
              setState(() {
                _selectedSkillsMap[value] = true; // Add skill as a map entry
              });
            }
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedSkillsMap.keys
              .map((skill) => Chip(
                    label: Text(skill),
                    onDeleted: () {
                      setState(() {
                        _selectedSkillsMap.remove(skill);
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDeadlineField() {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null && pickedDate != _deadline) {
          setState(() {
            _deadline = pickedDate;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
              text: _deadline == null
                  ? ''
                  : DateFormat('yyyy-MM-dd').format(_deadline!)),
          decoration: const InputDecoration(
            labelText: 'Deadline',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.teal),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) => value!.isEmpty ? 'Select a deadline' : null,
        ),
      ),
    );
  }
}
