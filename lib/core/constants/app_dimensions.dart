import 'package:flutter/material.dart';

/// Centralized dimensions for consistent spacing, sizing, and border radii.
/// Use these constants instead of hardcoding values throughout the app.
class AppDimensions {
  AppDimensions._(); // Private constructor to prevent instantiation
  
  // ============================================================================
  // SPACING - Use these for consistent padding, margins, and gaps
  // ============================================================================
  
  static const double spaceXs = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double spaceL = 16.0;
  static const double spaceXl = 20.0;
  static const double spaceXxl = 24.0;
  static const double spaceXxxl = 32.0;
  static const double spaceHuge = 48.0;
  
  // ============================================================================
  // BORDER RADIUS - Use these for consistent rounded corners
  // ============================================================================
  
  static const double radiusXs = 6.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusXxxl = 32.0;
  static const double radiusRound = 999.0; // For fully rounded elements
  
  // Predefined BorderRadius objects for convenience
  static BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static BorderRadius borderRadiusS = BorderRadius.circular(radiusS);
  static BorderRadius borderRadiusM = BorderRadius.circular(radiusM);
  static BorderRadius borderRadiusL = BorderRadius.circular(radiusL);
  static BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static BorderRadius borderRadiusXxl = BorderRadius.circular(radiusXxl);
  static BorderRadius borderRadiusXxxl = BorderRadius.circular(radiusXxxl);
  static BorderRadius borderRadiusRound = BorderRadius.circular(radiusRound);
  
  // ============================================================================
  // BUTTON SIZES
  // ============================================================================
  
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: spaceM,
    vertical: spaceS,
  );
  
  static const EdgeInsets buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: spaceL,
    vertical: spaceM,
  );
  
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: spaceXl,
    vertical: spaceL,
  );
  
  // ============================================================================
  // ICON SIZES
  // ============================================================================
  
  static const double iconXs = 14.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;
  static const double iconXxxl = 64.0;
  
  // ============================================================================
  // AVATAR SIZES
  // ============================================================================
  
  static const double avatarXs = 24.0;
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 48.0;
  static const double avatarXl = 64.0;
  static const double avatarXxl = 80.0;
  
  // ============================================================================
  // CARD & CONTAINER DIMENSIONS
  // ============================================================================
  
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;
  
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(spaceM);
  static const EdgeInsets cardPaddingMedium = EdgeInsets.all(spaceL);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(spaceXl);
  
  static const double cardImageHeight = 200.0;
  static const double cardImageHeightLarge = 340.0;
  
  // ============================================================================
  // PAGE PADDING
  // ============================================================================
  
  static const EdgeInsets pageHorizontalPadding = EdgeInsets.symmetric(
    horizontal: spaceL,
  );
  
  static const EdgeInsets pageAllPadding = EdgeInsets.all(spaceL);
  
  static const EdgeInsets pagePaddingWithBottom = EdgeInsets.only(
    left: spaceL,
    right: spaceL,
    top: spaceL,
    bottom: 100.0, // Extra bottom padding for navigation bar
  );
  
  // ============================================================================
  // INPUT FIELD DIMENSIONS
  // ============================================================================
  
  static const double inputHeight = 48.0;
  static const double inputBorderWidth = 1.0;
  static const double inputBorderWidthFocused = 1.6;
  
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: spaceL,
    vertical: 14.0,
  );
  
  // ============================================================================
  // CHIP & TAG DIMENSIONS
  // ============================================================================
  
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: spaceM,
    vertical: spaceXs,
  );
  
  static const EdgeInsets chipPaddingLarge = EdgeInsets.symmetric(
    horizontal: spaceL,
    vertical: spaceS,
  );
  
  // ============================================================================
  // APPBAR DIMENSIONS
  // ============================================================================
  
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;
  
  // ============================================================================
  // BORDER WIDTHS
  // ============================================================================
  
  static const double borderWidthThin = 0.5;
  static const double borderWidthNormal = 1.0;
  static const double borderWidthThick = 2.0;
  static const double borderWidthXThick = 3.0;
  
  // ============================================================================
  // SHADOW & BLUR
  // ============================================================================
  
  static const double blurRadiusSmall = 8.0;
  static const double blurRadiusMedium = 12.0;
  static const double blurRadiusLarge = 20.0;
  
  static const Offset shadowOffsetSmall = Offset(0, 2);
  static const Offset shadowOffsetMedium = Offset(0, 4);
  static const Offset shadowOffsetLarge = Offset(0, 8);
  
  // ============================================================================
  // CONSTRAINTS
  // ============================================================================
  
  static const double maxContentWidth = 420.0; // For forms and centered content
  static const double maxPageWidth = 1200.0; // For wide screens
  
  // ============================================================================
  // COMMON EDGE INSETS
  // ============================================================================
  
  static const EdgeInsets allS = EdgeInsets.all(spaceS);
  static const EdgeInsets allM = EdgeInsets.all(spaceM);
  static const EdgeInsets allL = EdgeInsets.all(spaceL);
  static const EdgeInsets allXl = EdgeInsets.all(spaceXl);
  static const EdgeInsets allXxl = EdgeInsets.all(spaceXxl);
  
  static const EdgeInsets horizontalL = EdgeInsets.symmetric(horizontal: spaceL);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: spaceXl);
  static const EdgeInsets verticalL = EdgeInsets.symmetric(vertical: spaceL);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: spaceXl);
  
  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================
  
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationSlow = Duration(milliseconds: 300);
  static const Duration animationXSlow = Duration(milliseconds: 400);
}
