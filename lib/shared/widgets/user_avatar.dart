import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// A consistent user avatar widget with fallback to initials.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double? size;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final bool showShadow;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? AppDimensions.avatarM;
    final initial = _getInitial();
    final fontSize = effectiveSize * 0.4;

    Widget avatar = Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.background,
                width: AppDimensions.borderWidthThick,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: AppDimensions.blurRadiusSmall,
                  offset: AppDimensions.shadowOffsetSmall,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: effectiveSize,
                height: effectiveSize,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallback(initial, fontSize, effectiveSize),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoading(effectiveSize);
                },
              )
            : _buildFallback(initial, fontSize, effectiveSize),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  String _getInitial() {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  Widget _buildFallback(String initial, double fontSize, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.5,
          height: size * 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}
