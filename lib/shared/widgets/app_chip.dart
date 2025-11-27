import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';

/// A consistent chip widget for displaying tags, categories, and status badges.
class AppChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;

  const AppChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.onTap,
    this.onDelete,
    this.selected = false,
  });

  /// Tag chip - for post tags
  const AppChip.tag({
    super.key,
    required this.label,
    this.onTap,
    this.onDelete,
  })  : backgroundColor = null,
        textColor = null,
        borderColor = null,
        icon = null,
        selected = false;

  /// Status chip - for post status (lost, found, completed)
  factory AppChip.status({
    Key? key,
    required String label,
    required Color color,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return AppChip(
      key: key,
      label: label,
      backgroundColor: color.withValues(alpha: 0.1),
      textColor: color,
      borderColor: color.withValues(alpha: 0.3),
      icon: icon,
      onTap: onTap,
    );
  }

  /// Category chip - for filtering/categorization
  const AppChip.category({
    super.key,
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
  })  : backgroundColor = null,
        textColor = null,
        borderColor = null,
        onDelete = null;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = _getBackgroundColor();
    final effectiveTextColor = _getTextColor();
    final effectiveBorderColor = _getBorderColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusM,
        child: Container(
          padding: AppDimensions.chipPadding,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: AppDimensions.borderRadiusM,
            border: Border.all(
              color: effectiveBorderColor,
              width: AppDimensions.borderWidthThin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppDimensions.iconXs,
                  color: effectiveTextColor,
                ),
                SizedBox(width: AppDimensions.spaceXs),
              ],
              Text(
                label,
                style: AppTypography.chip.copyWith(color: effectiveTextColor),
              ),
              if (onDelete != null) ...[
                SizedBox(width: AppDimensions.spaceXs),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close,
                    size: AppDimensions.iconXs,
                    color: effectiveTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;
    if (selected) return AppColors.primary.withValues(alpha: 0.1);
    return AppColors.chipBackground;
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;
    if (selected) return AppColors.primary;
    return AppColors.textPrimary;
  }

  Color _getBorderColor() {
    if (borderColor != null) return borderColor!;
    if (selected) return AppColors.primary.withValues(alpha: 0.3);
    return AppColors.border;
  }
}

/// A compact overlay chip for use on images
class AppOverlayChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AppOverlayChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.6),
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(
          color: (textColor ?? Colors.white).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: textColor ?? Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
