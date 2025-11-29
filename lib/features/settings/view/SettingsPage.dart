import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../auth/cubit/auth_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _pushNotifications = prefs.getBool('push_notifications') ?? true;
          _emailNotifications = prefs.getBool('email_notifications') ?? false;
          final themeIndex = prefs.getInt('theme_mode') ?? 0;
          _themeMode = ThemeMode.values[themeIndex];
        });
      }
    } catch (e) {
      // Silently fail if SharedPreferences is not available
    }
  }

  Future<void> _savePushNotifications(bool value) async {
    setState(() => _pushNotifications = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications', value);
    } catch (e) {
      // Silently fail if SharedPreferences is not available
    }
  }

  Future<void> _saveEmailNotifications(bool value) async {
    setState(() => _emailNotifications = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('email_notifications', value);
    } catch (e) {
      // Silently fail if SharedPreferences is not available
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
    } catch (e) {
      // Silently fail if SharedPreferences is not available
    }
  }

  void _onThemeChanged(ThemeMode? mode) {
    if (mode == null) return;
    _saveThemeMode(mode);
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error, size: 28),
            SizedBox(width: AppDimensions.spaceM),
            Text(
              'Delete Account',
              style: AppTypography.h4.copyWith(color: AppColors.error),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete your account and all associated data. '
          'You will be logged out immediately.\n\nAre you sure you want to continue?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusM,
              ),
            ),
            child: Text('Delete Account', style: AppTypography.labelMedium),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      await context.read<AuthCubit>().logout();
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          'Settings',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppDimensions.allL,
        children: [
          _buildSection(
            title: 'Account',
            children: [
              if (user != null) 
                _buildGroupedCards([
                  _buildProfileCardContent(user),
                  _buildSettingCardContent(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () => context.push('/change-password'),
                  ),
                ]),
            ],
          ),
          
          SizedBox(height: AppDimensions.spaceXl),
          
          _buildSection(
            title: 'Notifications',
            children: [
              _buildGroupedCards([
                _buildSwitchCardContent(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Get alerts about your items',
                  value: _pushNotifications,
                  onChanged: _savePushNotifications,
                ),
                _buildSwitchCardContent(
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Receive updates by email',
                  value: _emailNotifications,
                  onChanged: _saveEmailNotifications,
                ),
              ]),
            ],
          ),
          
          SizedBox(height: AppDimensions.spaceXl),
          
          _buildSection(
            title: 'App',
            children: [
              _buildGroupedCards([
                _buildSettingCardContent(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: _getThemeText(),
                  onTap: _showThemeSelector,
                ),
                _buildSettingCardContent(
                  icon: Icons.help_outline_rounded,
                  title: 'FAQ',
                  subtitle: 'Frequently asked questions',
                  onTap: () => context.push('/faq'),
                ),
                _buildSettingCardContent(
                  icon: Icons.info_outline_rounded,
                  title: 'About Findly',
                  subtitle: 'Version 1.0.0',
                  onTap: _showAboutDialog,
                ),
              ]),
            ],
          ),
          
          SizedBox(height: AppDimensions.spaceXl),
          
          _buildDangerSection(),
          
          SizedBox(height: AppDimensions.spaceXxl),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppDimensions.spaceS, bottom: AppDimensions.spaceM),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildGroupedCards(List<Widget> cards) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimensions.borderRadiusL,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: AppColors.border.withValues(alpha: 0.3),
          indent: AppDimensions.spaceL,
          endIndent: AppDimensions.spaceL,
        ),
        itemBuilder: (context, index) => cards[index],
      ),
    );
  }

  Widget _buildProfileCardContent(dynamic user) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/edit-profile'),
        child: Padding(
          padding: AppDimensions.allL,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                    ? Text(
                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                        style: AppTypography.h3.copyWith(color: Colors.white),
                      )
                    : null,
              ),
              SizedBox(width: AppDimensions.spaceL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: AppTypography.h5.copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: AppDimensions.spaceXs),
                    Text(
                      user.email,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCardContent({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppDimensions.allL,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              SizedBox(width: AppDimensions.spaceL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.labelLarge),
                    SizedBox(height: AppDimensions.spaceXs),
                    Text(
                      subtitle,
                      style: AppTypography.captionMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCardContent({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: AppDimensions.allL,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              SizedBox(width: AppDimensions.spaceL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.labelLarge),
                    SizedBox(height: AppDimensions.spaceXs),
                    Text(
                      subtitle,
                      style: AppTypography.captionMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppDimensions.spaceS, bottom: AppDimensions.spaceM),
          child: Text(
            'DANGER ZONE',
            style: AppTypography.overline.copyWith(
              color: AppColors.error,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: AppDimensions.borderRadiusL,
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppDimensions.borderRadiusL,
              onTap: _confirmDeleteAccount,
              child: Padding(
                padding: AppDimensions.allL,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.2),
                        borderRadius: AppDimensions.borderRadiusM,
                      ),
                      child: Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 24),
                    ),
                    SizedBox(width: AppDimensions.spaceL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Account',
                            style: AppTypography.labelLarge.copyWith(color: AppColors.error),
                          ),
                          SizedBox(height: AppDimensions.spaceXs),
                          Text(
                            'Permanently delete your account and data',
                            style: AppTypography.captionMedium.copyWith(
                              color: AppColors.error.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.error),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getThemeText() {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
    }
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: AppDimensions.borderRadiusXl.topLeft),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppDimensions.spaceM),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppDimensions.borderRadiusRound,
              ),
            ),
            Padding(
              padding: AppDimensions.allL,
              child: Text('Choose Theme', style: AppTypography.h4),
            ),
            _buildThemeOption(ThemeMode.system, 'System Default', Icons.brightness_auto_rounded),
            _buildThemeOption(ThemeMode.light, 'Light Mode', Icons.light_mode_rounded),
            _buildThemeOption(ThemeMode.dark, 'Dark Mode', Icons.dark_mode_rounded),
            SizedBox(height: AppDimensions.spaceL),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String title, IconData icon) {
    final isSelected = _themeMode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          _onThemeChanged(mode);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceL,
            vertical: AppDimensions.spaceM,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
              SizedBox(width: AppDimensions.spaceL),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Findly',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Findly\nLost & Found Made Simple',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: Icon(Icons.search_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}