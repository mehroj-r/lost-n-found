import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for different navigation scenarios
class PageTransitions {
  
  /// Slide transition from right to left (forward navigation)
  static CustomTransitionPage<T> slideFromRight<T extends Object?>(
    Widget child, {
    required GoRouterState state,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.fastEaseInToSlowEaseOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Slide transition from left to right (back navigation)
  static CustomTransitionPage<T> slideFromLeft<T extends Object?>(
    Widget child, {
    required GoRouterState state,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.fastEaseInToSlowEaseOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Fade transition for navbar navigation
  static CustomTransitionPage<T> fade<T extends Object?>(
    Widget child, {
    required GoRouterState state,
    String? name,
    Object? arguments,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  /// Scale transition for modal-like pages
  static CustomTransitionPage<T> scale<T extends Object?>(
    Widget child, {
    required GoRouterState state,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        const curve = Curves.easeInOut;

        final scaleTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        final fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide from bottom for upload/modal pages
  static CustomTransitionPage<T> slideFromBottom<T extends Object?>(
    Widget child, {
    required GoRouterState state,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.fastEaseInToSlowEaseOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// No transition for instant navigation
  static Page<T> noTransition<T extends Object?>(
    Widget child, {
    required GoRouterState state,
    String? name,
    Object? arguments,
  }) {
    return NoTransitionPage<T>(
      key: state.pageKey,
      name: name,
      child: child,
    );
  }
}

/// Custom page with no transition
class NoTransitionPage<T> extends Page<T> {
  const NoTransitionPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, _) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

/// Navigation helper to determine appropriate transition
class NavigationHelper {
  static bool isNavbarRoute(String path) {
    final navbarRoutes = ['/home', '/search', '/upload', '/chat-list', '/profile'];
    return navbarRoutes.contains(path);
  }

  static bool isModalRoute(String path) {
    final modalRoutes = ['/upload', '/notifications'];
    return modalRoutes.contains(path);
  }

  static bool isAuthRoute(String path) {
    final authRoutes = ['/login', '/register'];
    return authRoutes.contains(path);
  }

  static bool isDetailRoute(String path) {
    final detailRoutes = ['/chat', '/edit-profile', '/my-posts'];
    return detailRoutes.any((route) => path.startsWith(route));
  }
}