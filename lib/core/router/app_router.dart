import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_n_found/features/auth/view/register_page.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/profile/view/profile_page.dart';
import '../../features/splash/view/splash_page.dart';

GoRouter buildRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final isInitializing = authCubit.state.initializing;
      final loggedIn = authCubit.state.user != null;
      final currentLocation = state.matchedLocation;
      
      // Show splash screen while initializing
      if (isInitializing && currentLocation != '/splash') {
        return '/splash';
      }
      
      // After initialization, handle auth-based redirects
      if (!isInitializing) {
        final isLoginPage = currentLocation == '/login';
        final isRegisterPage = currentLocation == '/register';
        final isSplashPage = currentLocation == '/splash';

        // If on splash page and initialization is done, redirect based on auth state
        if (isSplashPage) {
          return loggedIn ? '/home' : '/login';
        }

        // If not logged in and trying to access protected routes, redirect to login
        if (!loggedIn && !isLoginPage && !isRegisterPage) {
          return '/login';
        }

        // If logged in and trying to access login/register, redirect to home
        if (loggedIn && (isLoginPage || isRegisterPage)) {
          return '/home';
        }
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) =>  ProfilePage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const HomePage(), // TODO: Create this page
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListener());
  }

  late final VoidCallback notifyListener;
  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}