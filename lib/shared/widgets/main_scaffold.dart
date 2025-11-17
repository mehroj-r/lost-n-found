import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/navigation_history.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int get _selectedIndex {
    switch (widget.currentPath) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/upload':
        return 2;
      case '/chat-list':
        return 3;
      case '/profile':
        return 4;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Animate button press
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/upload');
        break;
      case 3:
        context.go('/chat-list');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationHistory = NavigationHistory();
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // Get appropriate back destination
        final backDestination = navigationHistory.getBackDestination();
        
        if (backDestination != null && backDestination != widget.currentPath) {
          // Go back to previous page
          navigationHistory.pop();
          context.go(backDestination);
        } else if (widget.currentPath != '/home') {
          // Default fallback to home
          context.go('/home');
        } else {
          // On home page, allow app exit
          return;
        }
      },
      child: Scaffold(
        body: widget.child,
        extendBody: true,
        bottomNavigationBar: _ModernBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          scaleAnimation: _scaleAnimation,
        ),
      ),
    );
  }
}

class _ModernBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Animation<double> scaleAnimation;

  const _ModernBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 60, // Reduced from 70 since no text
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Slightly reduced from 25
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            index: 0,
            selectedIndex: selectedIndex,
            onTap: onItemTapped,
            scaleAnimation: scaleAnimation,
          ),
          _NavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search_rounded,
            index: 1,
            selectedIndex: selectedIndex,
            onTap: onItemTapped,
            scaleAnimation: scaleAnimation,
          ),
          _FloatingNavItem(
            icon: Icons.add,
            index: 2,
            selectedIndex: selectedIndex,
            onTap: onItemTapped,
            scaleAnimation: scaleAnimation,
          ),
          _NavItem(
            icon: Icons.chat_outlined,
            activeIcon: Icons.chat_rounded,
            index: 3,
            selectedIndex: selectedIndex,
            onTap: onItemTapped,
            scaleAnimation: scaleAnimation,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            index: 4,
            selectedIndex: selectedIndex,
            onTap: onItemTapped,
            scaleAnimation: scaleAnimation,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;
  final Animation<double> scaleAnimation;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    required this.scaleAnimation,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _colorAnim = ColorTween(
      begin: Colors.grey[600],
      end: const Color(0xFF4F46E5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.selectedIndex == widget.index) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == widget.index) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedIndex == widget.index;

    return GestureDetector(
      onTap: () => widget.onTap(widget.index),
      child: AnimatedBuilder(
        animation: widget.scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? widget.scaleAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4F46E5).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnim.value,
                    child: Icon(
                      isSelected ? widget.activeIcon : widget.icon,
                      color: _colorAnim.value,
                      size: 26,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FloatingNavItem extends StatefulWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;
  final Animation<double> scaleAnimation;

  const _FloatingNavItem({
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    required this.scaleAnimation,
  });

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnim = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.selectedIndex == widget.index) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_FloatingNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == widget.index) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedIndex == widget.index;

    return GestureDetector(
      onTap: () => widget.onTap(widget.index),
      child: AnimatedBuilder(
        animation: widget.scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? widget.scaleAnimation.value : 1.0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4F46E5),
                    const Color(0xFF7C3AED),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnim.value * 2 * 3.14159,
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}