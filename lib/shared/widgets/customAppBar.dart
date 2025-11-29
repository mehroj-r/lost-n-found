import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';
import '../../features/auth/cubit/auth_cubit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final bool hasNotifications;

  const CustomAppBar({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
    this.onSearchTap,
    this.hasNotifications = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceL,
            vertical: AppDimensions.spaceM,
          ),
          child: Row(
            children: [
              // App Logo/Name
              _AppLogo(onTap: onSearchTap),
              
              const Spacer(),

              // Search Button
              _ModernIconButton(
                icon: Icons.search_rounded,
                onTap: onSearchTap,
                tooltip: 'Search',
              ),
              SizedBox(width: AppDimensions.spaceM),

              // Notification Button
              _ModernIconButton(
                icon: Icons.notifications_none_rounded,
                hasIndicator: hasNotifications,
                onTap: onNotificationTap,
                tooltip: 'Notifications',
              ),
              SizedBox(width: AppDimensions.spaceM),

              // Profile Button
              _ModernProfileButton(onTap: onProfileTap),
            ],
          ),
        ),
      ),
    );
  }
}


class _AppLogo extends StatelessWidget {
  final VoidCallback? onTap;

  const _AppLogo({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppDimensions.borderRadiusM,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.textWhite,
              size: 20,
            ),
          ),
          SizedBox(width: AppDimensions.spaceM),
          // App Name
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: AppColors.primaryGradient,
            ).createShader(bounds),
            child: Text(
              'Findly',
              style: AppTypography.h3.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ModernIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasIndicator;
  final String? tooltip;

  const _ModernIconButton({
    required this.icon,
    this.onTap,
    this.hasIndicator = false,
    this.tooltip,
  });

  @override
  State<_ModernIconButton> createState() => _ModernIconButtonState();
}

class _ModernIconButtonState extends State<_ModernIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: AnimatedContainer(
          duration: AppDimensions.animationFast,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isPressed 
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.backgroundTertiary,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                widget.icon,
                color: AppColors.textPrimary,
                size: 22,
              ),
              if (widget.hasIndicator)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ModernProfileButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _ModernProfileButton({this.onTap});

  @override
  State<_ModernProfileButton> createState() => _ModernProfileButtonState();
}

class _ModernProfileButtonState extends State<_ModernProfileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    
    final initial = user?.firstName.isNotEmpty == true 
        ? user!.firstName[0].toUpperCase() 
        : 'U';
    
    // Get avatar URL - try avatarUrl first, then avatar.url as fallback
    final String? avatarUrl = user?.avatarUrl ?? user?.avatar?.url;
    final bool hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: AppDimensions.animationFast,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: hasAvatar
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackAvatar(initial),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingAvatar();
                    },
                  )
                : _buildFallbackAvatar(initial),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String initial) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTypography.h5.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}