import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final email = v.trim();
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 3) return 'Too short';
    return null;
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.primaryLight.withValues(alpha: 0.05),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (ctx, state) {
              if (state.user != null && !state.loading) {
                if (context.mounted) {
                  context.go('/home');
                }
              } else if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusM,
                    ),
                  ),
                );
              }
            },
            builder: (ctx, state) {
              final isLoading = state.loading;
              return Center(
                child: SingleChildScrollView(
                  padding: AppDimensions.allXl,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimensions.maxContentWidth,
                    ),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'logo',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.primaryGradient,
                              ),
                              borderRadius: AppDimensions.borderRadiusXl,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: AppDimensions.borderRadiusXl,
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceXxl),

                        Text(
                          'Welcome Back',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceS),
                        Text(
                          'Sign in to continue',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceXxxl),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppDimensions.borderRadiusXl,
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensions.spaceXxl),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  AppTextField(
                                    controller: _emailCtrl,
                                    label: 'Email',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _validateEmail,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  SizedBox(height: AppDimensions.spaceL),
                                  AppTextField(
                                    controller: _passCtrl,
                                    label: 'Password',
                                    obscureText: true,
                                    validator: _validatePassword,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  SizedBox(height: AppDimensions.spaceXxl),
                                  AppButton.secondary(
                                    text: 'Login',
                                    onPressed: isLoading ? null : _onSubmit,
                                    isLoading: isLoading,
                                    fullWidth: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceXl),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (context.mounted) context.go('/register');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Register',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
