import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/user.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    final authCubit = context.read<AuthCubit>();
    _controller = ProfileController(authCubit);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AppUser? get _user => _controller.user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.isLoading && _user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_controller.error != null && _user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _controller.refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (_user == null) {
              return Center(
                child: Text(
                  'No user data',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.only(
                top: AppDimensions.spaceXl,
                left: AppDimensions.spaceL,
                right: AppDimensions.spaceL,
                bottom: 120,
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: AppDimensions.spaceS,
                    bottom: AppDimensions.spaceL,
                  ),
                  child: Text(
                    "My Profile",
                    style: AppTypography.h1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                _buildProfileCard(),

                SizedBox(height: AppDimensions.spaceXl),

                Padding(
                  padding: EdgeInsets.only(
                    left: AppDimensions.spaceS,
                    bottom: AppDimensions.spaceM,
                  ),
                  child: Text(
                    'ACCOUNT',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                _buildGroupedCards([
                  _buildMenuItem(
                    icon: Icons.list_alt_rounded,
                    title: 'My Posts',
                    onTap: () => context.go('/my-posts'),
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite_rounded,
                    title: 'My Favourites',
                    onTap: () => context.push('/my-favourites'),
                  ),
                ]),

                SizedBox(height: AppDimensions.spaceXl),

                Padding(
                  padding: EdgeInsets.only(
                    left: AppDimensions.spaceS,
                    bottom: AppDimensions.spaceM,
                  ),
                  child: Text(
                    'SUPPORT',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                _buildGroupedCards([
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQ',
                    onTap: () => context.push('/faq'),
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                ]),

                SizedBox(height: AppDimensions.spaceXl),

                _buildSignOutCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimensions.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDimensions.borderRadiusXl,
          onTap: () => context.push('/edit-profile'),
          child: Padding(
            padding: AppDimensions.allXl,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  backgroundImage: _user!.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
                      ? NetworkImage(_user!.avatarUrl!)
                      : null,
                  child: _user!.avatarUrl == null || _user!.avatarUrl!.isEmpty
                      ? Text(
                          _getInitials(_user!),
                          style: AppTypography.h2.copyWith(color: Colors.white),
                        )
                      : null,
                ),
                SizedBox(width: AppDimensions.spaceL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_user!.firstName} ${_user!.lastName}",
                        style: AppTypography.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXs),
                      Text(
                        _user!.email,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(AppDimensions.spaceS),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppDimensions.borderRadiusM,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedCards(List<Widget> items) {
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
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: AppColors.border.withValues(alpha: 0.3),
          indent: AppDimensions.spaceL,
          endIndent: AppDimensions.spaceL,
        ),
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: AppDimensions.spaceL),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDimensions.borderRadiusL,
          onTap: () async {
            await _controller.signOut();
            if (mounted) {
              context.go('/login');
            }
          },
          child: Padding(
            padding: AppDimensions.allL,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: AppDimensions.borderRadiusM,
                  ),
                  child: Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                ),
                SizedBox(width: AppDimensions.spaceL),
                Expanded(
                  child: Text(
                    'Sign Out',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(AppUser user) {
    final initials = [
      if (user.firstName.isNotEmpty) user.firstName[0],
      if (user.lastName.isNotEmpty) user.lastName[0],
    ].join();
    return (initials.isEmpty ? '?' : initials.toUpperCase());
  }
}