import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'features/auth/cubit/auth_cubit.dart';

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
      // Add a small delay to allow the UI to render first
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Initialize service locator with timeout
      await ServiceLocator().init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Initialization timeout - please check your network connection');
        },
      );
      
      // Initialize auth cubit and router
      _authCubit = AuthCubit(ServiceLocator().authRepository);
      _router = buildRouter(_authCubit);
      
      // Register logout callback for unauthorized responses
      ServiceLocator().setUnauthorizedCallback(() async {
        await _authCubit.logout();
        _router.go('/login');
      });
      
      // Check authentication status with timeout
      await _authCubit.checkAuthStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Continue even if auth check times out
          print('Auth check timeout - continuing with default state');
        },
      );
      
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to initialize app', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_initError!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initError = null;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1F2434),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Findly',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lost & Found Made Simple',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Initializing...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
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
