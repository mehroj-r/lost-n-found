import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'data/repositories/mock_auth_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authCubit = AuthCubit(MockAuthRepository());
  final router = buildRouter(authCubit);
  runApp(FindlyApp(authCubit: authCubit, router: router));
}

class FindlyApp extends StatelessWidget {
  final AuthCubit authCubit;
  final GoRouter router;
  const FindlyApp({super.key, required this.authCubit, required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authCubit,
      child: MaterialApp.router(
        title: 'Findly',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF1F2434)),
        routerConfig: router,
      ),
    );
  }
}
