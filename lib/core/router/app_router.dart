import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_n_found/features/auth/view/register_page.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/profile/view/profile_page.dart';

GoRouter buildRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final loggedIn = authCubit.state.user != null;
      final isLoginPage = state.matchedLocation == '/login';
      final isRegisterPage = state.matchedLocation == '/register';

      // If not logged in and trying to access protected routes, redirect to login
      if (!loggedIn && !isLoginPage && !isRegisterPage) {
        return '/login';
      }

      // If logged in and trying to access login/register, redirect to home
      if (loggedIn && (isLoginPage || isRegisterPage)) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
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