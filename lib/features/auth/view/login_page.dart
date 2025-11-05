import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _f = GlobalKey<FormState>();
  final _e = TextEditingController();
  final _p = TextEditingController();
  @override
  void dispose(){ _e.dispose(); _p.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (c, s) { if (s.user != null) context.go('/home'); },
        builder: (c, s) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _f,
              child: Column(
                children: [
                  TextFormField(controller: _e, decoration: const InputDecoration(labelText: 'Email')),
                  TextFormField(controller: _p, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: s.loading ? null : () => context.read<AuthCubit>().login(_e.text, _p.text),
                    child: Text(s.loading ? '...' : 'Login'),
                  ),
                  if (s.error != null) Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(s.error!, style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tip: use @newuu.uz email to pass mock check')
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
