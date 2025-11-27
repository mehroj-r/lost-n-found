import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// A consistent card widget for containing content with consistent styling.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? AppDimensions.cardPaddingMedium;
    final effectiveMargin = margin;
    final effectiveColor = color ?? AppColors.background;
    final effectiveBorderRadius = borderRadius ?? AppDimensions.borderRadiusXl;

    final cardChild = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: AppDimensions.blurRadiusLarge,
            offset: AppDimensions.shadowOffsetMedium,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.02),
            blurRadius: AppDimensions.blurRadiusSmall,
            offset: AppDimensions.shadowOffsetSmall,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: effectiveMargin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: effectiveBorderRadius,
            child: cardChild,
          ),
        ),
      );
    }

    return Container(
      margin: effectiveMargin,
      child: cardChild,
    );
  }
}

/// A simple card with default padding and styling
class SimpleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SimpleCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusL,
      ),
      elevation: AppDimensions.cardElevation,
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusL,
        child: Padding(
          padding: AppDimensions.cardPaddingMedium,
          child: child,
        ),
      ),
    );
  }
}
