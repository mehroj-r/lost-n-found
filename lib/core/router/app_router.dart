import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_n_found/features/auth/view/register_page.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/my_posts/view/my_posts.dart';
import '../../features/profile/view/profile_page.dart';
import '../../features/search/view/search_page.dart';
import '../../features/upload/view/upload_page.dart';
import '../../features/splash/view/splash_page.dart';
import '../../features/notifications/view/notifications_page.dart';
import '../../features/chat/chat_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/profile/view/edit_profile.dart';

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
      
      // Bottom navigation routes wrapped in MainScaffold
      GoRoute(
        path: '/home',
        builder: (context, state) => MainScaffold(
          currentPath: '/home',
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => MainScaffold(
          currentPath: '/search',
          child: const SearchPage(),
        ),
      ),
      GoRoute(
        path: '/upload',
        builder: (context, state) => MainScaffold(
          currentPath: '/upload',
          child: const UploadPage(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => MainScaffold(
          currentPath: '/profile',
          child: ProfilePage(),
        ),
      ),
      
      // Standalone pages without bottom navigation
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => MainScaffold(
          currentPath: '/profile',
          child: const EditProfilePage(),
        ),
      ),
      GoRoute(
        path: '/my-posts',
        builder: (context, state) => MainScaffold(
          currentPath: '/profile',
          child: const MyPostsScreen(),
        ),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final postId = args?['postId'] as int?;
          
          if (postId == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Invalid chat parameters'),
              ),
            );
          }
          
          return ChatScreen(postId: postId);
        },
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