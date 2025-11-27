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
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
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
                      // Logo
                      Container(
                        width: 220,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppDimensions.borderRadiusM,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.06),
                              blurRadius: AppDimensions.blurRadiusSmall,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: AppDimensions.allM,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXxl),

                      // Form card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderRadiusL,
                        ),
                        elevation: AppDimensions.cardElevation,
                        color: AppColors.background,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceL + 2,
                            vertical: AppDimensions.spaceXl,
                          ),
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
                                SizedBox(height: AppDimensions.spaceM),
                                AppTextField(
                                  controller: _passCtrl,
                                  label: 'Password',
                                  obscureText: true,
                                  validator: _validatePassword,
                                  textInputAction: TextInputAction.done,
                                ),
                                SizedBox(height: AppDimensions.spaceL + 2),
                                AppButton.secondary(
                                  text: 'Login',
                                  onPressed: isLoading ? null : _onSubmit,
                                  isLoading: isLoading,
                                  fullWidth: true,
                                ),
                                if (!isLoading && state.error != null) ...[
                                  SizedBox(height: AppDimensions.spaceS),
                                  Text(
                                    state.error!,
                                    style: AppTypography.captionMedium.copyWith(
                                      color: AppColors.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceL),

                      TextButton(
                        onPressed: () {
                          if (context.mounted) context.go('/register');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text(
                          "Don't have an account? Register",
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXs),
                      Text(
                        'Use: admin@newuu.uz / 12345',
                        style: AppTypography.captionSmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
