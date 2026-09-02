import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
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
  final _locationFormKey = GlobalKey<FormState>();
  final _campusBlockController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _emergencyTypes = [
    {
      'icon': Icons.medical_services_rounded,
      'label': 'Medical',
      'subtitle': 'Ambulance & First Aid',
      'color': const Color(0xFFD32F2F),
      'containerColor': const Color(0xFFFFEBEE),
    },
    {
      'icon': Icons.security_rounded,
      'label': 'Security',
      'subtitle': 'Campus Police & Patrol',
      'color': const Color(0xFF1565C0),
      'containerColor': const Color(0xFFE3F2FD),
    },
    {
      'icon': Icons.local_fire_department_rounded,
      'label': 'Fire',
      'subtitle': 'Smoke & Fire Alarm',
      'color': const Color(0xFFE65100),
      'containerColor': const Color(0xFFFFE0B2),
    },
    {
      'icon': Icons.car_crash_rounded,
      'label': 'Accident',
      'subtitle': 'Vehicle or Physical Collision',
      'color': const Color(0xFFF57C00),
      'containerColor': const Color(0xFFFFF3E0),
    },
    {
      'icon': Icons.support_agent_rounded,
      'label': 'Other',
      'subtitle': 'General Campus Hazard',
      'color': const Color(0xFF00695C),
      'containerColor': const Color(0xFFE0F2F1),
    },
  ];

  @override
  void dispose() {
    _campusBlockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Emergency SOS',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.critical,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            ref.read(sosNotifierProvider.notifier).reset();
            context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: _buildBody(sosState),
      ),
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

  // 1. Ready View
  Widget _buildReadyView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.critical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 16, color: AppColors.critical),
                  SizedBox(width: 6),
                  Text(
                    'ASTU EMERGENCY RESPONSE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.critical,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Need Emergency Help?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Press and hold the SOS button below for 3 seconds to initiate instant emergency dispatch.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 36),
            EmergencyButton(
              onPressed: () {
                ref.read(sosNotifierProvider.notifier).startConfirmation();
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Hold for 3 seconds to activate dispatch',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () {
                PhoneLauncherUtil.launchCall(
                  context: context,
                  phoneNumber: '811',
                  contactName: 'Campus Police (Emergency)',
                  isEmergency: true,
                );
              },
              icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: AppColors.critical),
              label: const Text(
                'Direct Dial Campus Police (811)',
                style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: BorderSide(color: AppColors.critical.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Confirm View
  Widget _buildConfirmView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.critical.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  size: 34,
                  color: AppColors.critical,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirm Emergency Alert',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This action will immediately notify ASTU campus police, clinic, and central dispatch with your live location.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTypeIndex = -1;
                    });
                    ref.read(sosNotifierProvider.notifier).startTypeSelection();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Yes, Select Emergency Type',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.critical,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(sosNotifierProvider.notifier).reset();
                    context.go('/home');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel Alert',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Type Selection View (Solid, High-Contrast White Cards on Surface)
  Widget _buildTypeSelectionView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'What type of emergency?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select the category that best describes your immediate situation.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _emergencyTypes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final type = _emergencyTypes[index];
                final isSelected = _selectedTypeIndex == index;
                final typeColor = type['color'] as Color;
                final containerColor = type['containerColor'] as Color;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTypeIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? typeColor : AppColors.outlineVariant.withValues(alpha: 0.7),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? typeColor.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.03),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: containerColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            type['icon'] as IconData,
                            size: 22,
                            color: typeColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type['label'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                type['subtitle'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: AppColors.outlineVariant.withValues(alpha: 0.8),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton(
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
                backgroundColor: AppColors.critical,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.outlineVariant.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 1.5,
              ),
              child: const Text(
                'Continue to Location Confirmation',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Location Confirm View with Retry, Building/Room, and Description inputs
  Widget _buildLocationConfirmView(SosState sosState) {
    final hasCoords = sosState.latitude != null && sosState.longitude != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Form(
        key: _locationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Incident Location & Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasCoords
                  ? 'GPS location acquired. You may optionally specify your room number or notes.'
                  : 'GPS was not detected. Please specify your campus building & room to dispatch help.',
              style: TextStyle(
                fontSize: 13.5,
                color: hasCoords ? AppColors.onSurfaceVariant : const Color(0xFFC62828),
                height: 1.35,
                fontWeight: hasCoords ? FontWeight.normal : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Location Status Card (Solid White with Contrast)
            Card(
              elevation: 1.5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: hasCoords
                      ? AppColors.success.withValues(alpha: 0.4)
                      : const Color(0xFFFFB74D),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (hasCoords ? AppColors.success : AppColors.warning)
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasCoords ? Icons.location_on_rounded : Icons.location_searching_rounded,
                            size: 24,
                            color: hasCoords ? AppColors.success : const Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: hasCoords ? AppColors.success : const Color(0xFFE65100),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    hasCoords ? 'GPS Detected & Locked' : 'GPS Not Detected',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: hasCoords ? AppColors.success : const Color(0xFFE65100),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                hasCoords
                                    ? (sosState.locationAddress ?? 'Lat: ${sosState.latitude!.toStringAsFixed(4)}, Lng: ${sosState.longitude!.toStringAsFixed(4)}')
                                    : 'Campus Center fallback active. Insert room below.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                          tooltip: 'Refetch GPS',
                          onPressed: () {
                            ref.read(sosNotifierProvider.notifier).fetchLocation();
                          },
                        ),
                      ],
                    ),
                    if (sosState.isLocationLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(minHeight: 3),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 1. Campus Building Block & Room (Required if no GPS, Optional if GPS locked)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BUILDING BLOCK & ROOM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: hasCoords
                        ? AppColors.surfaceContainerHigh
                        : AppColors.critical.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    hasCoords ? 'OPTIONAL' : 'REQUIRED (NO GPS)',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: hasCoords ? AppColors.onSurfaceVariant : AppColors.critical,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _campusBlockController,
              validator: (value) {
                if (!hasCoords && (value == null || value.trim().isEmpty)) {
                  return 'Please specify your building block, room, or landmark';
                }
                return null;
              },
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'e.g. Block 4, Room 204 or Engineering East Quad',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                prefixIcon: const Icon(Icons.business_rounded, size: 20, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: !hasCoords ? AppColors.critical.withValues(alpha: 0.6) : AppColors.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: !hasCoords ? AppColors.critical.withValues(alpha: 0.6) : AppColors.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Situation Details / Description (Optional)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SITUATION DETAILS (OPTIONAL)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  'OPTIONAL',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Briefly describe the condition (e.g., student collapsed, fire smoke visible, physical threat)...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Primary Send SOS Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_locationFormKey.currentState!.validate()) {
                    final blockText = _campusBlockController.text.trim();
                    final descText = _descriptionController.text.trim();
                    ref.read(sosNotifierProvider.notifier).sendSOS(
                          campusBlock: blockText.isNotEmpty
                              ? blockText
                              : (hasCoords ? 'ASTU Campus Grounds' : 'ASTU Campus Center'),
                          description: descText.isNotEmpty ? descText : null,
                        );
                  }
                },
                icon: const Icon(Icons.emergency_rounded, size: 20, color: Colors.white),
                label: const Text(
                  'Send SOS Alert Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.critical,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(sosNotifierProvider.notifier).reset();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Sending View / Loading Screen
  Widget _buildSendingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.critical.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: AppColors.critical,
                    strokeWidth: 3.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Transmitting SOS Alert...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connecting to ASTU Campus Central Dispatch & Responders...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Sent View with Contained Incident ID & Direct Map Routing
  Widget _buildSentView(SosState sosState) {
    final incident = sosState.createdIncident;
    final incidentId = incident?.id ?? 'SOS-ACTIVE';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 42,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'SOS Dispatched Successfully',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your emergency alert is active. ASTU campus responders and central command have received your incident.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Contained Incident Reference Card (Zero Overflow)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INCIDENT ID',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '#$incidentId',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DISPATCHED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action 1: Track Active Emergency (Sends directly to Real-time Map)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(sosNotifierProvider.notifier).reset();
                    // Navigate directly to live incident map tracking!
                    context.go('/incident/$incidentId');
                  },
                  icon: const Icon(Icons.map_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Track Active Emergency on Map',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action 2: Return Home
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(sosNotifierProvider.notifier).reset();
                    context.go('/home');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Return to Home',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 7. Received View
  Widget _buildReceivedView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Responder Dispatched',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 8. Failed View
  Widget _buildFailedView(SosState sosState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Failed to Transmit SOS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                sosState.error ?? 'An issue occurred during dispatch transmission. Please call campus police immediately.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    PhoneLauncherUtil.launchCall(
                      context: context,
                      phoneNumber: '811',
                      contactName: 'Campus Police (Emergency)',
                      isEmergency: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.critical,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Call Campus Police (811)',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(sosNotifierProvider.notifier).fetchLocation();
                    ref.read(sosNotifierProvider.notifier).sendSOS();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry SOS Dispatch'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(sosNotifierProvider.notifier).reset();
                  context.go('/home');
                },
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
