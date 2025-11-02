import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/profile/view/profile_page.dart';

GoRouter buildRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final loggedIn = authCubit.state.user != null;
      final loggingIn = state.matchedLocation == '/login';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/profile';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
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
  void dispose() { _sub.cancel(); super.dispose(); }
}
