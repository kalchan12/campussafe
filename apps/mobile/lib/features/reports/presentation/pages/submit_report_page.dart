import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';

class SubmitReportPage extends ConsumerStatefulWidget {
  const SubmitReportPage({super.key});

  @override
  ConsumerState<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends ConsumerState<SubmitReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedType = 'safety_concern';
  bool _isAnonymous = true;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement report submission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Submitted'),
          content: const Text('Thank you for your report. It will be reviewed by our team.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Safety Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Report a Safety Concern',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help us keep the campus safe by reporting any concerns',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              // Anonymous Toggle
              SwitchListTile(
                title: const Text('Submit Anonymously'),
                subtitle: const Text(
                  'Your identity will not be shared',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Report Type
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Report Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'suspicious_activity',
                    child: Text('Suspicious Activity'),
                  ),
                  DropdownMenuItem(
                    value: 'security_concern',
                    child: Text('Security Concern'),
                  ),
                  DropdownMenuItem(
                    value: 'fire_hazard',
                    child: Text('Fire/Hazard'),
                  ),
                  DropdownMenuItem(
                    value: 'safety_concern',
                    child: Text('Safety Concern'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) => Validators.required(value, 'Description'),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Please provide details about your concern...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              // Location
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Add Location'),
                  subtitle: const Text('Optional'),
                  trailing: const Icon(Icons.add_location),
                  onTap: () {
                    // TODO: Implement location picker
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Photo
              Card(
                child: ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Add Photo'),
                  subtitle: const Text('Optional'),
                  trailing: const Icon(Icons.add_a_photo),
                  onTap: () {
                    // TODO: Implement photo picker
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Submit
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
