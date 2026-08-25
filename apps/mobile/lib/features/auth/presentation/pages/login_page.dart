import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/input_fields.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement login
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.containerMargin,
            AppSpacing.lg,
            AppSpacing.containerMargin,
            AppSpacing.containerMargin,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                          ),
                          child: const Icon(
                            Icons.security,
                            size: 24,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'CampusSafe',
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Welcome back',
                      style: AppTypography.displayLgMobile.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sign in to access campus safety services.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                // Form Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Email or Phone',
                      hint: 'student@campus.edu',
                      controller: _identifierController,
                      keyboardType: TextInputType.text,
                      validator: Validators.email,
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
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
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TertiaryButton(
                        label: 'Forgot password?',
                        onPressed: () => context.push('/forgot-password'),
                        isFullWidth: false,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: 'Sign In',
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New here?",
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        TertiaryButton(
                          label: 'Create account',
                          onPressed: () => context.push('/register'),
                          isFullWidth: false,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Separator
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.outlineVariant,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'Or',
                        style: AppTypography.technicalSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.outlineVariant,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: 'Continue as Guest',
                  onPressed: () => context.go('/guest'),
                ),
                // Emergency Action - Fixed at bottom
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: AppColors.error,
                            size: 28,
                            fill: 1.0,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need emergency help?',
                                  style: AppTypography.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onErrorContainer,
                                  ),
                                ),
                                Text(
                                  'Bypass login for immediate assistance.',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onErrorContainer.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      PrimaryButton(
                        label: 'Send SOS',
                        onPressed: () => context.push('/sos'),
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.onError,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
