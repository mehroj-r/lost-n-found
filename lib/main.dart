import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/splash/view/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start the app first, then initialize services in background
  runApp(const FindlyBootstrap());
}

class FindlyBootstrap extends StatefulWidget {
  const FindlyBootstrap({super.key});

  @override
  State<FindlyBootstrap> createState() => _FindlyBootstrapState();
}

class _FindlyBootstrapState extends State<FindlyBootstrap> {
  bool _isInitialized = false;
  String? _initError;
  late AuthCubit _authCubit;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final startTime = DateTime.now();
      
      await ServiceLocator().init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Initialization timeout - please check your network connection');
        },
      );
      
      setupDependencyInjection();
      
      _authCubit = AuthCubit(ServiceLocator().authRepository);
      _router = buildRouter(_authCubit);
      
      ServiceLocator().setUnauthorizedCallback(() async {
        await _authCubit.logout();
        _router.go('/login');
      });
      
      await _authCubit.checkAuthStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );
      
      final elapsed = DateTime.now().difference(startTime);
      final remainingDelay = const Duration(seconds: 3) - elapsed;
      
      if (remainingDelay.inMilliseconds > 0) {
        await Future.delayed(remainingDelay);
      }
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _initError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFEF4444)),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _initError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initError = null;
                      });
                      _initializeApp();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4FFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
      );
    }

    return FindlyApp(authCubit: _authCubit, router: _router);
  }
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
