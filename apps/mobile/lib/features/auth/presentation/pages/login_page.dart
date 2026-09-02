import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../shared/widgets/buttons.dart';
import '../../../../shared/widgets/input_fields.dart';
import '../state/auth_notifier.dart';

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

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Dev bypass: if Supabase is not configured, skip auth
    if (!Env.isConfigured) {
      context.go('/home');
      return;
    }

    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signIn(
      email: _identifierController.text.trim(),
      password: _passwordController.text,
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
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 22,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'CampusSafe',
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Welcome back',
                      style: AppTypography.displayLgMobile.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sign in to access safety services & alerts.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Inputs
                    AppTextField(
                      label: 'Email or Phone',
                      hint: 'student@campus.edu',
                      controller: _identifierController,
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppPasswordField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onSuffixTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TertiaryButton(
                        label: 'Forgot password?',
                        onPressed: () => context.push('/forgot-password'),
                        isFullWidth: false,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Sign In Action
                    Consumer(
                      builder: (context, ref, _) {
                        final isLoading =
                            ref.watch(authNotifierProvider).isLoading;
                        return SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                              ),
                            ),
                            onPressed: isLoading ? null : _handleLogin,
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 2),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        TertiaryButton(
                          label: 'Register',
                          onPressed: () => context.push('/register'),
                          isFullWidth: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Separator
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppColors.outlineVariant,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'or',
                            style: AppTypography.technicalSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: AppColors.outlineVariant,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Guest Button
                    SecondaryButton(
                      label: 'Continue as Guest',
                      onPressed: () => context.go('/guest'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Compact Emergency Action Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emergency_outlined,
                            color: AppColors.error,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Immediate Emergency?',
                                  style: AppTypography.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onErrorContainer,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Bypass login for SOS dispatch',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onErrorContainer.withValues(alpha: 0.85),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.onError,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                            ),
                            onPressed: () => context.push('/sos'),
                            child: const Text(
                              'SOS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
