import 'package:flutter/material.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job details added successfully!')),
      );
    }
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Enter a job title' : null,
            ),
            const SizedBox(height: 16),
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
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Enter a location' : null,
            ),
            const SizedBox(height: 16),
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
            TextFormField(
              controller: _qualificationsController,
              decoration: const InputDecoration(
                labelText: 'Required Qualifications',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Enter required qualifications' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Preferred Skills',
                border: OutlineInputBorder(),
                hintText: 'e.g. Flutter, Firebase, UX Design',
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Enter preferred skills' : null,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _submitJobDetails,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
