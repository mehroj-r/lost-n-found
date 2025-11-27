import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
/// All colors used throughout the app should reference these constants.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation
  
  // ============================================================================
  // PRIMARY & BRAND COLORS
  // ============================================================================
  
  /// Main brand color - used for primary buttons, active states, and key UI elements
  static const Color primary = Color(0xFF5B4FFE);
  static const Color primaryDark = Color(0xFF4A3FE5);
  static const Color primaryLight = Color(0xFF7B6FFF);
  
  /// Secondary/Accent colors
  static const Color accent = Color(0xFF6BBF59);
  static const Color accentDark = Color(0xFF5AAF48);
  
  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  
  /// Success states - completed items, confirmations
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  
  /// Warning states
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  
  /// Error states - lost items, errors, destructive actions
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  
  /// Info states - found items, informational messages
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDCEDFF);
  
  // ============================================================================
  // TEXT COLORS
  // ============================================================================
  
  /// Primary text color for headings and important content
  static const Color textPrimary = Color(0xFF111827);
  
  /// Secondary text color for body text
  static const Color textSecondary = Color(0xFF374151);
  
  /// Muted text color for less important information
  static const Color textMuted = Color(0xFF6B7280);
  
  /// Disabled text color
  static const Color textDisabled = Color(0xFF9CA3AF);
  
  /// White text for dark backgrounds
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================
  
  /// Main background color for pages
  static const Color background = Color(0xFFFFFFFF);
  
  /// Secondary background for cards and elevated surfaces
  static const Color backgroundSecondary = Color(0xFFF9FAFB);
  
  /// Tertiary background for input fields and chips
  static const Color backgroundTertiary = Color(0xFFF3F4F6);
  
  /// Page background (slightly tinted)
  static const Color pageBackground = Color(0xFFF5F6F8);
  
  /// Dark background for splash and special screens
  static const Color backgroundDark = Color(0xFF1F2434);
  
  // ============================================================================
  // UI ELEMENT COLORS
  // ============================================================================
  
  /// Borders and dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFE6E8F0);
  
  /// Chip and pill backgrounds
  static const Color chipBackground = Color(0xFFF3F4F8);
  static const Color pillBackground = Color(0xFFF5F6FA);
  
  /// Overlay colors (for modals, shadows, etc.)
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  
  /// Shadow colors (use with opacity)
  static const Color shadow = Color(0xFF000000);
  
  // ============================================================================
  // SPECIAL COLORS
  // ============================================================================
  
  /// Rating stars
  static const Color rating = Color(0xFFF6A623);
  
  /// Like/Favorite
  static const Color favorite = Color(0xFFEF4444);
  static const Color favoriteLight = Color(0xFFFEE2E2);
  
  /// Online status indicator
  static const Color online = Color(0xFF10B981);
  
  /// Unread notification badge
  static const Color badge = Color(0xFFEF4444);
  
  // ============================================================================
  // GRADIENT COLORS
  // ============================================================================
  
  static const List<Color> primaryGradient = [
    Color(0xFF5B4FFE),
    Color(0xFF7B6FFF),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF6BBF59),
    Color(0xFF5AAF48),
  ];
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get status color based on post type and completion status
  static Color getStatusColor({required String type, required bool isCompleted}) {
    if (isCompleted) return success;
    return type == 'lost' ? error : info;
  }
  
  /// Get light version of status color
  static Color getStatusColorLight({required String type, required bool isCompleted}) {
    if (isCompleted) return successLight;
    return type == 'lost' ? errorLight : infoLight;
  }
}

