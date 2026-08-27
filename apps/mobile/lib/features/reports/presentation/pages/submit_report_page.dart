import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/safety_report.dart';
import '../state/alerts_provider.dart';

class SubmitReportPage extends ConsumerStatefulWidget {
  const SubmitReportPage({super.key});

  @override
  ConsumerState<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends ConsumerState<SubmitReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  ReportType _selectedType = ReportType.safetyConcern;
  bool _isAnonymous = true;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final newReport = SafetyReport(
        id: 'REP-${(1000 + DateTime.now().millisecond * 7)}',
        reporterId: _isAnonymous ? null : 'usr_me',
        isAnonymous: _isAnonymous,
        type: _selectedType,
        status: ReportStatus.submitted,
        description: _descriptionController.text.trim(),
        locationDescription: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : 'Campus Area',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ref.read(userSafetyReportsListProvider.notifier).addReport(newReport);
      ref.read(alertsTabSegmentProvider.notifier).state = AlertsTabMode.myReports;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Submitted Successfully'),
          content: const Text(
            'Thank you for reporting this safety concern. Our campus security and facilities team has been notified.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Report a Safety Concern',
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Help us keep the university safe by reporting hazards, broken facilities, or suspicious activity.',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Anonymous Option Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Submit Anonymously',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Your name and profile will be hidden from reports',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                  value: _isAnonymous,
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Report Type Dropdown
              DropdownButtonFormField<ReportType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Concern Category',
                  prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
                items: ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Location Input
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Campus Location / Building',
                  hintText: 'e.g. Engineering Quad, Room 204 or East Walkway',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) => Validators.required(value, 'Description'),
                decoration: InputDecoration(
                  labelText: 'Details / Description *',
                  hintText: 'Please describe the issue or situation clearly...',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit Button with High Contrast White Text
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Submit Safety Report',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
