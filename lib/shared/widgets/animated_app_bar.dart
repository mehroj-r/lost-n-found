import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/navigation_history.dart';

/// Custom app bar that handles proper back navigation
class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;
  final VoidCallback? onBack;

  const AnimatedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      elevation: elevation,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      automaticallyImplyLeading: false, // We'll handle this manually
      leading: _buildLeading(context),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (!automaticallyImplyLeading) return null;

    final navigationHistory = NavigationHistory();
    final canGoBack = navigationHistory.canGoBack();
    
    if (!canGoBack) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded),
      onPressed: () => _handleBack(context),
    );
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }

    final navigationHistory = NavigationHistory();
    final backDestination = navigationHistory.getBackDestination();
    
    if (backDestination != null) {
      navigationHistory.pop();
      context.go(backDestination);
    } else {
      // Fallback
      context.go('/home');
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Helper mixin for pages that need back navigation
mixin BackNavigationMixin<T extends StatefulWidget> on State<T> {
  
  /// Handle back navigation with animation consideration
  void handleBackNavigation() {
    final navigationHistory = NavigationHistory();
    final backDestination = navigationHistory.getBackDestination();
    
    if (backDestination != null) {
      navigationHistory.pop();
      context.go(backDestination);
    } else {
      context.go('/home');
    }
  }

  /// Check if back navigation is available
  bool canNavigateBack() {
    return NavigationHistory().canGoBack();
  }

  /// Get the back destination without navigating
  String? getBackDestination() {
    return NavigationHistory().getBackDestination();
  }
}