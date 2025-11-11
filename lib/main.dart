import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'features/auth/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize service locator (DI container)
  await ServiceLocator().init();
  
  final authCubit = AuthCubit(ServiceLocator().authRepository);
  final router = buildRouter(authCubit);
  
  // Start the app and then check authentication status
  // This allows the splash screen to be shown during auth check
  runApp(FindlyApp(authCubit: authCubit, router: router));
  
  // Check authentication status after app starts
  authCubit.checkAuthStatus();
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
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
