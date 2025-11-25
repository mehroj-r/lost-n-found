import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_n_found/features/auth/view/register_page.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/my_posts/view/my_posts.dart';
import '../../features/profile/view/profile_page.dart';
import '../../features/search/view/search_page.dart';
import '../../features/settings/view/SettingsPage.dart';
import '../../features/upload/view/upload_page.dart';
import '../../features/splash/view/splash_page.dart';
import '../../features/notifications/view/notifications_page.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/chat_list/chat_list_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/profile/view/edit_profile.dart';
import '../../features/user_profile/view/user_profile_page.dart';
import '../../data/models/user.dart';
import 'page_transitions.dart';
import 'navigation_history.dart';

GoRouter buildRouter(AuthCubit authCubit) {
  final navigationHistory = NavigationHistory();

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final isInitializing = authCubit.state.initializing;
      final loggedIn = authCubit.state.user != null;
      final currentLocation = state.matchedLocation;
      
      // Track navigation for history
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationHistory.push(currentLocation);
      });

      // Show splash screen while initializing
      if (isInitializing && currentLocation != '/splash') {
        return '/splash';
      }

      final isSplashPage = currentLocation == '/splash';
      final isLoginPage = currentLocation == '/login';
      final isRegisterPage = currentLocation == '/register';

      // After initialization, redirect appropriately
      if (!isInitializing) {
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
        pageBuilder: (context, state) => PageTransitions.fade(
          const SplashPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          const LoginPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          const RegisterPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      
      // Bottom navigation routes with proper transitions
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _buildNavbarPage(
          context: context,
          state: state,
          child: const HomePage(),
          currentPath: '/home',
          navigationHistory: navigationHistory,
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => _buildNavbarPage(
          context: context,
          state: state,
          child: const SearchPage(),
          currentPath: '/search',
          navigationHistory: navigationHistory,
        ),
      ),
      GoRoute(
        path: '/upload',
        pageBuilder: (context, state) => _buildNavbarPage(
          context: context,
          state: state,
          child: const UploadPage(),
          currentPath: '/upload',
          navigationHistory: navigationHistory,
        ),
      ),
      GoRoute(
        path: '/chat-list',
        pageBuilder: (context, state) => _buildNavbarPage(
          context: context,
          state: state,
          child: const ChatListScreen(),
          currentPath: '/chat-list',
          navigationHistory: navigationHistory,
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildNavbarPage(
          context: context,
          state: state,
          child: ProfilePage(),
          currentPath: '/profile',
          navigationHistory: navigationHistory,
        ),
      ),
      
      // Detail pages with slide animations
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => PageTransitions.slideFromBottom(
          const NotificationsPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          MainScaffold(
            currentPath: '/profile',
            child: const EditProfilePage(),
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: '/my-posts',
        pageBuilder: (context, state) => PageTransitions.slideFromRight(
          MainScaffold(
            currentPath: '/profile',
            child: const MyPostsScreen(),
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: '/edit-post',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final postId = args?['postId'] as int?;
          
          if (postId == null) {
            return PageTransitions.slideFromRight(
              Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid post ID'),
                ),
              ),
              state: state,
            );
          }
          
          return PageTransitions.slideFromRight(
            MainScaffold(
              currentPath: '/profile',
              child: UploadPage(postId: postId),
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/user-profile',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final userId = args?['userId'] as int?;
          final user = args?['user'] as AppUser?;
          
          if (userId == null) {
            return PageTransitions.slideFromRight(
              Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid user ID'),
                ),
              ),
              state: state,
            );
          }
          
          return PageTransitions.slideFromRight(
            UserProfilePage(
              userId: userId,
              initialUser: user,
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final postId = args?['postId'] as int?;
          final chatId = args?['chatId'] as String?;
          
          if (postId == null && chatId == null) {
            return PageTransitions.slideFromRight(
              Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Invalid chat parameters'),
                ),
              ),
              state: state,
            );
          }
          
          return PageTransitions.slideFromRight(
            ChatScreen(postId: postId, chatId: chatId),
            state: state,
          );
        },
      ),
    ],
  );
}

/// Helper function to build navbar pages with appropriate transitions
Page _buildNavbarPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required String currentPath,
  required NavigationHistory navigationHistory,
}) {
  final previousPath = navigationHistory.previousPath;
  final navigationType = previousPath != null 
    ? navigationHistory.getNavigationType(previousPath, currentPath)
    : NavigationType.navbar;

  final wrappedChild = MainScaffold(
    currentPath: currentPath,
    child: child,
  );

  switch (navigationType) {
    case NavigationType.back:
      return PageTransitions.slideFromLeft(wrappedChild, state: state);
    case NavigationType.forward:
      return PageTransitions.slideFromRight(wrappedChild, state: state);
    case NavigationType.navbar:
    case NavigationType.modal:
      return PageTransitions.fade(
        wrappedChild, 
        state: state,
        duration: const Duration(milliseconds: 200),
      );
  }
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