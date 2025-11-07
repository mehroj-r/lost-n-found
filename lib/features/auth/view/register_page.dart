import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart';

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
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _email.dispose();
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.green.shade700, width: 1.6),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // call cubit register
    context.read<AuthCubit>().register(
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // match clean look; change background if you want darker frame like screenshot
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Register'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (ctx, state) {
            if (state.user != null) {
              // registration succeeded -> navigate to home (same as login)
              if (context.mounted) context.go('/home');
            } else if (state.error != null) {
              // show error message
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (ctx, state) {
            final isLoading = state.loading;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      // logo card (replace with your asset or network image)
                      Container(
                        width: 220,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Text('findly', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _first,
                                  decoration: _inputDecoration('First Name'),
                                  validator: (v) => _notEmpty(v, 'First name'),
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: _last,
                                  decoration: _inputDecoration('Last Name'),
                                  validator: (v) => _notEmpty(v, 'Last name'),
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: _phone,
                                  decoration: _inputDecoration('Phone Number').copyWith(prefixText: '+998 '),
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: _email,
                                  decoration: _inputDecoration('Email'),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: _password,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: Colors.green.shade700, width: 1.6),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                  obscureText: _obscure,
                                  validator: _validatePassword,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: _confirm,
                                  decoration: _inputDecoration('Confirm Password'),
                                  obscureText: true,
                                  validator: (v) => v == null || v.isEmpty ? 'Confirm password' : null,
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 18),

                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _onSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6FA43B), // green
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          if (context.mounted) context.go('/login');
                        },
                        child: const Text('Already have an account? Sign in'),
                      ),

                      const SizedBox(height: 8),
                      const Text('Tip: use @newuu.uz email to register'),
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
