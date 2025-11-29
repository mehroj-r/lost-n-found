import 'package:flutter/foundation.dart';

/// Navigation history tracker for proper back navigation
class NavigationHistory extends ChangeNotifier {
  static final NavigationHistory _instance = NavigationHistory._internal();
  factory NavigationHistory() => _instance;
  NavigationHistory._internal();

  final List<String> _history = [];
  String? _currentPath;

  /// Get current navigation stack
  List<String> get history => List.unmodifiable(_history);
  
  /// Get current path
  String? get currentPath => _currentPath;

  /// Get previous path
  String? get previousPath => _history.length > 1 ? _history[_history.length - 2] : null;

  /// Add a new route to history
  void push(String path) {
    // Don't add duplicate consecutive paths
    if (_currentPath != path) {
      if (_currentPath != null) {
        _history.add(_currentPath!);
      }
      _currentPath = path;
      
      // Limit history size to prevent memory issues
      if (_history.length > 20) {
        _history.removeAt(0);
      }
      
      notifyListeners();
    }
  }

  /// Remove last route from history (when going back)
  String? pop() {
    if (_history.isNotEmpty) {
      final previous = _history.removeLast();
      _currentPath = previous;
      notifyListeners();
      return previous;
    }
    return null;
  }

  /// Replace current route (for redirects)
  void replace(String path) {
    _currentPath = path;
    notifyListeners();
  }

  /// Clear history (for logout)
  void clear() {
    _history.clear();
    _currentPath = null;
    notifyListeners();
  }

  /// Get appropriate back destination
  String? getBackDestination() {
    // If we have previous path, go there
    if (previousPath != null) {
      return previousPath;
    }
    
    // Otherwise, go to appropriate default based on current path
    if (_currentPath == null) return '/home';
    
    // Auth pages go to home if logged in, otherwise stay
    if (_currentPath!.startsWith('/login') || _currentPath!.startsWith('/register')) {
      return null; // Let system handle
    }
    
    // Detail pages go to home
    if (_currentPath!.startsWith('/chat') || 
        _currentPath!.startsWith('/edit-profile') ||
        _currentPath!.startsWith('/my-posts') ||
        _currentPath!.startsWith('/notifications')) {
      return '/home';
    }
    
    // Navbar pages stay (no back action)
    final navbarRoutes = ['/home', '/search', '/upload', '/chat-list', '/profile'];
    if (navbarRoutes.contains(_currentPath)) {
      return '/home'; // Default to home
    }
    
    return '/home';
  }

  /// Check if we can go back
  bool canGoBack() {
    return previousPath != null || _shouldAllowSystemBack();
  }

  /// Check if system back should be allowed
  bool _shouldAllowSystemBack() {
    if (_currentPath == null) return false;
    
    // Allow system back on auth pages
    if (_currentPath!.startsWith('/login') || _currentPath!.startsWith('/register')) {
      return true;
    }
    
    // Don't allow system back on main pages (prevent app exit)
    final mainPages = ['/home', '/search', '/upload', '/chat-list', '/profile'];
    return !mainPages.contains(_currentPath);
  }

  /// Determine navigation type for animations
  NavigationType getNavigationType(String from, String to) {
    final navbarRoutes = ['/home', '/search', '/upload', '/chat-list', '/profile'];
    
    // Navbar to navbar navigation
    if (navbarRoutes.contains(from) && navbarRoutes.contains(to)) {
      return NavigationType.navbar;
    }
    
    // Going to detail page
    if (navbarRoutes.contains(from) && !navbarRoutes.contains(to)) {
      return NavigationType.forward;
    }
    
    // Coming back from detail page
    if (!navbarRoutes.contains(from) && navbarRoutes.contains(to)) {
      return NavigationType.back;
    }
    
    // Detail to detail
    if (!navbarRoutes.contains(from) && !navbarRoutes.contains(to)) {
      // Check if it's in history (back navigation)
      if (_history.contains(to)) {
        return NavigationType.back;
      }
      return NavigationType.forward;
    }
    
    return NavigationType.forward;
  }
}

/// Types of navigation for animation purposes
enum NavigationType {
  forward,  // Right to left slide
  back,     // Left to right slide  
  navbar,   // Fade transition
  modal,    // Scale or slide from bottom
}