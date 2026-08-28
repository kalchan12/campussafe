import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../shared/widgets/emergency_button.dart';
import '../state/sos_notifier.dart';
import '../state/sos_state.dart';

class SOSPage extends ConsumerStatefulWidget {
  const SOSPage({super.key});

  @override
  ConsumerState<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends ConsumerState<SOSPage> {
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
    final sosState = ref.watch(sosNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: AppColors.sosRed,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(sosNotifierProvider.notifier).reset();
            context.go('/home');
          },
        ),
      ),
      body: _buildBody(sosState),
    );
  }

  Widget _buildBody(SosState sosState) {
    switch (sosState.status) {
      case SosStatus.ready:
        return _buildReadyView();
      case SosStatus.confirming:
        return _buildConfirmView();
      case SosStatus.selectingType:
        return _buildTypeSelectionView();
      case SosStatus.confirmingLocation:
        return _buildLocationConfirmView(sosState);
      case SosStatus.sending:
        return _buildSendingView();
      case SosStatus.sent:
        return _buildSentView(sosState);
      case SosStatus.received:
        return _buildReceivedView();
      case SosStatus.failed:
        return _buildFailedView(sosState);
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
              ref.read(sosNotifierProvider.notifier).startConfirmation();
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
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () {
              PhoneLauncherUtil.launchCall(
                context: context,
                phoneNumber: '911',
                contactName: 'Campus Police (Emergency)',
                isEmergency: true,
              );
            },
            icon: const Icon(Icons.phone_in_talk, size: 16, color: AppColors.sosRed),
            label: const Text(
              'Direct Dial Campus Police (911)',
              style: TextStyle(color: AppColors.sosRed, fontWeight: FontWeight.bold),
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
                  ref.read(sosNotifierProvider.notifier).reset();
                  setState(() {
                    _selectedTypeIndex = -1;
                  });
                  // Move to type selection
                  ref.read(sosNotifierProvider.notifier).startConfirmation();
                  // We transition locally to selectingType
                  // By default selectingType view
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sosRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Yes, Select Emergency Type'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(sosNotifierProvider.notifier).reset();
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
                    final selectedType =
                        _emergencyTypes[_selectedTypeIndex]['label'] as String;
                    ref
                        .read(sosNotifierProvider.notifier)
                        .selectType(selectedType);
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

  Widget _buildLocationConfirmView(SosState sosState) {
    final hasCoords = sosState.latitude != null && sosState.longitude != null;

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
            'Your live location will be shared immediately with responders.',
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
                  if (sosState.isLocationLoading) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Acquiring high-accuracy GPS...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Text(
                      hasCoords ? 'GPS Location Locked' : 'Location Pending',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sosState.locationAddress ??
                          (hasCoords
                              ? 'Lat: ${sosState.latitude!.toStringAsFixed(4)}, Lng: ${sosState.longitude!.toStringAsFixed(4)}'
                              : 'Coordinates pending permission check'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              ref.read(sosNotifierProvider.notifier).sendSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sosRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Send SOS Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              ref.read(sosNotifierProvider.notifier).reset();
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
            'Please wait while we alert campus responders',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentView(SosState sosState) {
    final incident = sosState.createdIncident;
    final incidentId = incident?.id ?? 'SOS-LIVE-ALERT';

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
              'Your emergency has been dispatched. Nearby campus responders have been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Incident ID: $incidentId',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(sosNotifierProvider.notifier).reset();
                  context.go('/emergency/active/$incidentId');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Track Active Emergency'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(sosNotifierProvider.notifier).reset();
                  context.go('/home');
                },
                child: const Text('Return Home'),
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

  Widget _buildFailedView(SosState sosState) {
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
              sosState.error ?? 'An error occurred while contacting emergency services. Please call 911 or campus security directly.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  PhoneLauncherUtil.launchCall(
                    context: context,
                    phoneNumber: '911',
                    contactName: 'Campus Police (Emergency)',
                    isEmergency: true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.critical,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.phone_in_talk, size: 20),
                label: const Text(
                  'Call Campus Police Now (911)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(sosNotifierProvider.notifier).fetchLocation();
                  ref.read(sosNotifierProvider.notifier).sendSOS();
                },
                child: const Text('Retry App SOS Dispatch'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  ref.read(sosNotifierProvider.notifier).reset();
                  context.go('/home');
                },
                child: const Text('Return Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
