import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_typography.dart';

/// Enumeration for button sizes
enum AppButtonSize { small, medium, large }

/// Enumeration for button styles
enum AppButtonStyle { primary, secondary, outline, text, danger }

/// A consistent, reusable button widget following the app's design system.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final AppButtonStyle style;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.padding,
  });

  /// Primary button - most common style
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.padding,
  }) : style = AppButtonStyle.primary;

  /// Secondary button - accent color
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.padding,
  }) : style = AppButtonStyle.secondary;

  /// Outline button - transparent with border
  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.padding,
  }) : style = AppButtonStyle.outline;

  /// Text button - no background
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.padding,
  }) : style = AppButtonStyle.text;

  /// Danger button - for destructive actions
  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.padding,
  }) : style = AppButtonStyle.danger;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: _getButtonStyle(isDisabled),
        child: isLoading ? _buildLoadingIndicator() : _buildContent(),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppDimensions.buttonHeightMedium;
      case AppButtonSize.large:
        return AppDimensions.buttonHeightLarge;
    }
  }

  EdgeInsets _getPadding() {
    if (padding != null) return padding!;
    
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonPaddingSmall;
      case AppButtonSize.medium:
        return AppDimensions.buttonPaddingMedium;
      case AppButtonSize.large:
        return AppDimensions.buttonPaddingLarge;
    }
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle;
    switch (size) {
      case AppButtonSize.small:
        baseStyle = AppTypography.buttonSmall;
        break;
      case AppButtonSize.medium:
        baseStyle = AppTypography.buttonMedium;
        break;
      case AppButtonSize.large:
        baseStyle = AppTypography.buttonLarge;
        break;
    }

    // Adjust color based on style
    Color textColor;
    switch (style) {
      case AppButtonStyle.primary:
        textColor = AppColors.textWhite;
        break;
      case AppButtonStyle.secondary:
        textColor = AppColors.textWhite;
        break;
      case AppButtonStyle.danger:
        textColor = AppColors.textWhite;
        break;
      case AppButtonStyle.outline:
        textColor = AppColors.primary;
        break;
      case AppButtonStyle.text:
        textColor = AppColors.primary;
        break;
    }

    return baseStyle.copyWith(color: textColor);
  }

  ButtonStyle _getButtonStyle(bool isDisabled) {
    Color backgroundColor;
    Color? foregroundColor;
    Color? borderColor;
    double elevation;

    switch (style) {
      case AppButtonStyle.primary:
        backgroundColor = isDisabled ? AppColors.textDisabled : AppColors.primary;
        elevation = 0;
        break;
      case AppButtonStyle.secondary:
        backgroundColor = isDisabled ? AppColors.textDisabled : AppColors.accent;
        elevation = 0;
        break;
      case AppButtonStyle.danger:
        backgroundColor = isDisabled ? AppColors.textDisabled : AppColors.error;
        elevation = 0;
        break;
      case AppButtonStyle.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? AppColors.textDisabled : AppColors.primary;
        borderColor = isDisabled ? AppColors.textDisabled : AppColors.primary;
        elevation = 0;
        break;
      case AppButtonStyle.text:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? AppColors.textDisabled : AppColors.primary;
        elevation = 0;
        break;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: AppColors.textDisabled,
      disabledForegroundColor: AppColors.textWhite,
      elevation: elevation,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusRound,
        side: borderColor != null
            ? BorderSide(color: borderColor, width: AppDimensions.borderWidthNormal)
            : BorderSide.none,
      ),
    );
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: AppDimensions.spaceS),
          Text(text, style: _getTextStyle()),
        ],
      );
    }
    return Text(text, style: _getTextStyle());
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.iconXs;
      case AppButtonSize.medium:
        return AppDimensions.iconS;
      case AppButtonSize.large:
        return AppDimensions.iconM;
    }
  }

  Widget _buildLoadingIndicator() {
    double size;
    switch (this.size) {
      case AppButtonSize.small:
        size = 16;
        break;
      case AppButtonSize.medium:
        size = 20;
        break;
      case AppButtonSize.large:
        size = 24;
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          style == AppButtonStyle.outline || style == AppButtonStyle.text
              ? AppColors.primary
              : AppColors.textWhite,
        ),
      ),
    );
  }
}
