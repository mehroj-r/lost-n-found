import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';

/// A consistent section header widget for dividing content into sections.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onActionTap;
  final String? actionLabel;
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onActionTap,
    this.actionLabel,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? AppDimensions.horizontalL,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppDimensions.iconM,
              color: AppColors.primary,
            ),
            SizedBox(width: AppDimensions.spaceS),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h4,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppDimensions.spaceXs),
                  Text(
                    subtitle!,
                    style: AppTypography.captionLarge,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onActionTap != null && actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple page title widget
class PageTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceXl,
        vertical: AppDimensions.spaceXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.h1,
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppDimensions.spaceS),
            Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
