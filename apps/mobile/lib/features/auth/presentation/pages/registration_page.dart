import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/input_fields.dart';
import '../state/auth_notifier.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;
  String? _selectedRole = 'student';
  String _selectedCampus = 'main_campus';

  static const _totalSteps = 4;
  static const _stepLabels = ['Account', 'Campus', 'Role', 'Prefs'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _buildingController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      if (!_formKey.currentState!.validate()) return;

      // Dev bypass: if Supabase is not configured skip auth
      if (!Env.isConfigured) {
        context.go('/home');
        return;
      }

      final notifier = ref.read(authNotifierProvider.notifier);
      await notifier.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: _selectedRole,
        campusBlock: _buildingController.text.trim().isEmpty
            ? null
            : _buildingController.text.trim(),
      );

      if (!mounted) return;
      final authState = ref.read(authNotifierProvider);
      if (authState.isAuthenticated) {
        context.go('/home');
      } else if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _formKey.currentState?.validate() ?? true;
    }
    return true;
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.containerMargin,
              vertical: AppSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _handleBack,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 18,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'CampusSafe',
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Title & Description
                    Text(
                      'Create Account',
                      style: AppTypography.displayLgMobile.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Join the campus safety network for instant emergency response.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Stepper Indicator
                    _buildStepper(),
                    const SizedBox(height: AppSpacing.lg),

                    // Step Form Content
                    _buildStepContent(),
                    const SizedBox(height: AppSpacing.lg),

                    // Navigation Buttons
                    Row(
                      children: [
                        if (_currentStep > 0) ...[
                          Expanded(
                            child: SecondaryButton(
                              label: 'Back',
                              onPressed: _handleBack,
                              leadingIcon: Icons.arrow_back,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Expanded(
                          child: PrimaryButton(
                            label: _currentStep == _totalSteps - 1 ? 'Create Account' : 'Continue',
                            onPressed: _handleNext,
                            trailingIcon: _currentStep == _totalSteps - 1 ? null : Icons.arrow_forward,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Return to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        TertiaryButton(
                          label: 'Sign in',
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/login');
                            }
                          },
                          isFullWidth: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCurrent = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? AppColors.primary
                              : isCompleted
                                  ? AppColors.success
                                  : AppColors.surfaceContainerHigh,
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.primary
                                : isCompleted
                                    ? AppColors.success
                                    : AppColors.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.onPrimary,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: AppTypography.labelMd.copyWith(
                                    fontSize: 11,
                                    color: isCurrent
                                        ? AppColors.onPrimary
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepLabels[index],
                        style: AppTypography.technicalSm.copyWith(
                          fontSize: 11,
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index < _totalSteps - 1)
                  Container(
                    width: 16,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.outlineVariant,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAccountStep();
      case 1:
        return _buildCampusStep();
      case 2:
        return _buildRoleStep();
      case 3:
        return _buildPrefsStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAccountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Full Name',
          hint: 'Jane Doe',
          controller: _fullNameController,
          validator: (value) => Validators.required(value, 'Full name'),
          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'University Email',
          hint: 'jane@university.edu',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Phone Number',
          hint: '(555) 123-4567',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPasswordField(
          label: 'Password',
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: Validators.password,
          onSuffixTap: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppPasswordField(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: (value) => Validators.confirmPassword(
            value,
            _passwordController.text,
          ),
          onSuffixTap: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCampusStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedCampus,
          decoration: InputDecoration(
            labelText: 'Campus Location',
            prefixIcon: const Icon(Icons.school_outlined, color: AppColors.onSurfaceVariant, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'main_campus', child: Text('Main Campus')),
            DropdownMenuItem(value: 'north_campus', child: Text('North Campus')),
            DropdownMenuItem(value: 'south_campus', child: Text('South Campus')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCampus = value;
              });
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Campus Block / Building (Optional)',
          hint: 'e.g. Engineering Block B',
          controller: _buildingController,
          prefixIcon: const Icon(Icons.business_outlined, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Room / Office Number (Optional)',
          hint: 'e.g. Room 204',
          controller: _roomController,
          prefixIcon: const Icon(Icons.meeting_room_outlined, size: 20),
        ),
      ],
    );
  }

  Widget _buildRoleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select your primary affiliation:',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._buildRoleOptions(),
      ],
    );
  }

  List<Widget> _buildRoleOptions() {
    final roles = [
      {'value': 'student', 'label': 'Student', 'icon': Icons.school_outlined, 'color': AppColors.primary},
      {'value': 'medical_responder', 'label': 'Medical Responder', 'icon': Icons.medical_services_outlined, 'color': AppColors.error},
      {'value': 'security_responder', 'label': 'Security Responder', 'icon': Icons.local_police_outlined, 'color': AppColors.secondary},
      {'value': 'staff', 'label': 'Staff / Faculty', 'icon': Icons.badge_outlined, 'color': AppColors.success},
    ];

    return roles.map((role) {
      final isSelected = _selectedRole == role['value'];
      final roleColor = role['color'] as Color;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedRole = role['value'] as String;
            });
          },
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? roleColor.withValues(alpha: 0.08)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              border: Border.all(
                color: isSelected
                    ? roleColor
                    : AppColors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? roleColor.withValues(alpha: 0.15)
                        : AppColors.surfaceContainerHigh,
                    border: Border.all(
                      color: isSelected
                          ? roleColor
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      role['icon'] as IconData,
                      color: isSelected
                          ? roleColor
                          : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    role['label'] as String,
                    style: AppTypography.labelMd.copyWith(
                      color: isSelected
                          ? roleColor
                          : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: roleColor,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPrefsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Notification Settings',
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPreferenceTile(
          title: 'Push Notifications',
          subtitle: 'Receive real-time alerts for emergencies',
          value: true,
          onChanged: (value) {},
        ),
        _buildPreferenceTile(
          title: 'SMS Alerts',
          subtitle: 'Receive SMS for high-priority campus incidents',
          value: false,
          onChanged: (value) {},
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Location Services',
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPreferenceTile(
          title: 'Share Location during SOS',
          subtitle: 'Allow responders to track your GPS during active alerts',
          value: true,
          onChanged: (value) {},
        ),
        _buildPreferenceTile(
          title: 'Nearby Incidents Alert',
          subtitle: 'Get notified of safety incidents near your current area',
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            activeThumbColor: AppColors.onPrimary,
          ),
        ],
      ),
    );
  }
}
