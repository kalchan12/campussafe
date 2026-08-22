import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/emergency_button.dart';
import '../state/sos_state.dart';

class SOSPage extends ConsumerStatefulWidget {
  const SOSPage({super.key});

  @override
  ConsumerState<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends ConsumerState<SOSPage> {
  SosState _sosState = const SosState();
  int _selectedTypeIndex = -1;

  final List<Map<String, dynamic>> _emergencyTypes = [
    {'icon': Icons.medical_services, 'label': 'Medical', 'color': Colors.red},
    {'icon': Icons.security, 'label': 'Security', 'color': Colors.blue},
    {'icon': Icons.local_fire_department, 'label': 'Fire', 'color': Colors.orange},
    {'icon': Icons.car_crash, 'label': 'Accident', 'color': Colors.amber},
    {'icon': Icons.help_outline, 'label': 'Other', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: AppColors.sosRed,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_sosState.status) {
      case SosStatus.ready:
        return _buildReadyView();
      case SosStatus.confirming:
        return _buildConfirmView();
      case SosStatus.selectingType:
        return _buildTypeSelectionView();
      case SosStatus.confirmingLocation:
        return _buildLocationConfirmView();
      case SosStatus.sending:
        return _buildSendingView();
      case SosStatus.sent:
        return _buildSentView();
      case SosStatus.received:
        return _buildReceivedView();
      case SosStatus.failed:
        return _buildFailedView();
    }
  }

  Widget _buildReadyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Press the button for emergency',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          EmergencyButton(
            onPressed: () {
              setState(() {
                _sosState = _sosState.copyWith(
                  status: SosStatus.confirming,
                );
              });
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Hold for 3 seconds to confirm',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber,
              size: 64,
              color: AppColors.warning,
            ),
            const SizedBox(height: 24),
            const Text(
              'Confirm Emergency',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to send an SOS alert?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _sosState = _sosState.copyWith(
                      status: SosStatus.selectingType,
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sosRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Yes, Send SOS'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _sosState = const SosState();
                  });
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelectionView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'What type of emergency?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the type that best describes your emergency',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _emergencyTypes.length,
              itemBuilder: (context, index) {
                final type = _emergencyTypes[index];
                final isSelected = _selectedTypeIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTypeIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (type['color'] as Color).withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? type['color'] as Color
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type['icon'] as IconData,
                          size: 40,
                          color: type['color'] as Color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          type['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: type['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedTypeIndex >= 0
                ? () {
                    setState(() {
                      _sosState = _sosState.copyWith(
                        status: SosStatus.confirmingLocation,
                        emergencyType:
                            _emergencyTypes[_selectedTypeIndex]['label']
                                .toString()
                                .toLowerCase(),
                      );
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sosRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationConfirmView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Confirm Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your location will be shared with responders',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Getting your location...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coordinates: Lat 0.00, Lng 0.00',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sosState = _sosState.copyWith(
                  status: SosStatus.sending,
                );
              });
              // Simulate sending
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _sosState = _sosState.copyWith(
                      status: SosStatus.sent,
                    );
                  });
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sosRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS Now'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _sosState = _sosState.copyWith(
                  status: SosStatus.selectingType,
                );
              });
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildSendingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.sosRed,
            strokeWidth: 4,
          ),
          SizedBox(height: 24),
          Text(
            'Sending SOS Alert...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we contact emergency services',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
              child: const Icon(
                Icons.check,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SOS Sent Successfully',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your emergency has been reported. A responder will be assigned shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Incident ID: SOS-2024-001',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Return Home'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to incident detail
                },
                child: const Text('View Incident Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Waiting for responder...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to Send SOS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _sosState.error ?? 'An error occurred. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _sosState = const SosState();
                  });
                },
                child: const Text('Try Again'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Return Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
