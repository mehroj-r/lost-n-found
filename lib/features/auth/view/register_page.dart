import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _patronymic = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String? _gender;
  bool _obscure = true;
  bool _canSubmit = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_first, _last, _phone, _email, _password, _confirm, _username, _patronymic]) {
      c.addListener(_recomputeCanSubmit);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _recomputeCanSubmit());
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _username.dispose();
    _email.dispose();
    _patronymic.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _notEmpty(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final email = v.trim();
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    if (!email.endsWith('@newuu.uz')) return 'Use your university email (@newuu.uz)';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required';
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return 'Enter a valid phone number';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _recomputeCanSubmit() {
    final emailOk = _validateEmail(_email.text) == null;
    final phoneOk = _validatePhone(_phone.text) == null;
    final passOk = _validatePassword(_password.text) == null;
    final namesOk = _first.text.trim().isNotEmpty;
    final confirmOk = _confirm.text.isNotEmpty && _confirm.text == _password.text;
    final genderOk = _gender != null && _gender!.isNotEmpty;
    final can = emailOk && phoneOk && passOk && namesOk && confirmOk && genderOk;
    if (can != _canSubmit) setState(() => _canSubmit = can);
  }

  void _onSubmit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
      }
      return;
    }
    if (_gender == null || _gender!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select gender')),
        );
      }
      return;
    }
    context.read<AuthCubit>().register(
      firstName: _first.text.trim(),
      lastName: _last.text.trim().isEmpty ? null : _last.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      username: _username.text.trim().isEmpty ? null : _username.text.trim(),
      patronymic: _patronymic.text.trim().isEmpty ? null : _patronymic.text.trim(),
      gender: _gender!,
    );
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
              if (state.registrationSuccess) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Registration successful! Please login.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusM,
                      ),
                    ),
                  );
                  context.go('/login');
                }
              } else if (state.error != null) {
                if (context.mounted) {
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
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                              onPressed: () => context.go('/login'),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.spaceM),
                        Hero(
                          tag: 'logo',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.primaryGradient,
                              ),
                              borderRadius: AppDimensions.borderRadiusL,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: AppDimensions.borderRadiusL,
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceXxl),
                        Text(
                          'Create Account',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceS),
                        Text(
                          'Join us to find your lost items',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceXxl),
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
                              autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    controller: _first,
                                    label: 'First Name',
                                    validator: (v) => _notEmpty(v, 'First name'),
                                    textInputAction: TextInputAction.next,
                                  ),
                                  SizedBox(height: AppDimensions.spaceM),
                                  AppTextField(
                                    controller: _last,
                                    label: 'Last Name (optional)',
                                    textInputAction: TextInputAction.next,
                                  ),
                                  SizedBox(height: AppDimensions.spaceM),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppTextField(
                                        controller: _email,
                                        label: 'Email',
                                        keyboardType: TextInputType.emailAddress,
                                        validator: _validateEmail,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      SizedBox(height: AppDimensions.spaceXs),
                                      Text(
                                        'Use your university email (@newuu.uz)',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppDimensions.spaceM),
                                  AppTextField(
                                    controller: _phone,
                                    label: 'Phone Number',
                                    keyboardType: TextInputType.phone,
                                    validator: _validatePhone,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  SizedBox(height: AppDimensions.spaceM),
                                  AppTextField(
                                    controller: _username,
                                    label: 'Username (optional)',
                                    textInputAction: TextInputAction.next,
                                  ),
                                  SizedBox(height: AppDimensions.spaceM),
                                  DropdownButtonFormField<String>(
                                    value: _gender,
                                    items: const [
                                      DropdownMenuItem(value: 'male', child: Text('Male')),
                                      DropdownMenuItem(value: 'female', child: Text('Female')),
                                    ],
                                    onChanged: (v) {
                                      setState(() => _gender = v);
                                      _recomputeCanSubmit();
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      hintText: 'Select gender',
                                      filled: true,
                                      fillColor: AppColors.backgroundTertiary,
                                      border: OutlineInputBorder(
                                        borderRadius: AppDimensions.borderRadiusM,
                                        borderSide: BorderSide(color: AppColors.border),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: AppDimensions.borderRadiusM,
                                        borderSide: BorderSide(color: AppColors.border),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: AppDimensions.borderRadiusM,
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: AppDimensions.inputBorderWidthFocused,
                                        ),
                                      ),
                                      contentPadding: AppDimensions.inputPadding,
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Please select gender' : null,
                                  ),
                                  SizedBox(height: AppDimensions.spaceM),
                                  AppTextField(
                                    controller: _patronymic,
                                    label: 'Patronymic (optional)',
                                    textInputAction: TextInputAction.next,
                                  ),
                                  SizedBox(height: AppDimensions.spaceM),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppTextField(
                                        controller: _password,
                                        label: 'Password',
                                        obscureText: _obscure,
                                        validator: _validatePassword,
                                        textInputAction: TextInputAction.next,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscure ? Icons.visibility_off : Icons.visibility,
                                            color: AppColors.textMuted,
                                          ),
                                          onPressed: () => setState(() => _obscure = !_obscure),
                                        ),
                                      ),
                                      SizedBox(height: AppDimensions.spaceXs),
                                      Text(
                                        'Password must be at least 6 characters',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppDimensions.spaceM),
                                  AppTextField(
                                    controller: _confirm,
                                    label: 'Confirm Password',
                                    obscureText: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Confirm password';
                                      if (v != _password.text) return 'Passwords do not match';
                                      return null;
                                    },
                                    textInputAction: TextInputAction.done,
                                  ),
                                  SizedBox(height: AppDimensions.spaceXxl),
                                  AppButton.secondary(
                                    text: 'Register',
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
                              'Already have an account? ',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (context.mounted) context.go('/login');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign in',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.spaceXxxl),
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
