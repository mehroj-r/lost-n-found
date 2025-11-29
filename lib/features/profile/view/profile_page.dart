import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: Colors.white,
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    "My Profile",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Profile card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: (_user!.avatarUrl != null &&
                              _user!.avatarUrl!.isNotEmpty)
                              ? Image.network(
                            _user!.avatarUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _initialsCircle(_user!),
                          )
                              : _initialsCircle(_user!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_user!.firstName} ${_user!.lastName}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user!.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          context.push('/edit-profile');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      _menuItem(
                        icon: Icons.list_alt_outlined,
                        title: 'My posts',
                        onTap: () {
                          context.go('/my-posts');
                        },
                      ),
                      _menuItem(
                        icon: Icons.favorite_border,
                        title: 'My favourites',
                        onTap: () {
                          context.push('/my-favourites');
                        },
                      ),
                      _menuItem(
                        icon: Icons.help_outline,
                        title: 'FAQ',
                        onTap: () {
                          context.push('/faq');
                        },
                      ),
                      _menuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          context.push('/settings');
                        },
                      ),
                      _menuItem(
                        icon: Icons.logout,
                        title: 'Sign out',
                        onTap: () async {
                          await _controller.signOut();
                          if (mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _initialsCircle(AppUser user) {
    final initials = [
      if (user.firstName.isNotEmpty) user.firstName[0],
      if (user.lastName.isNotEmpty) user.lastName[0],
    ].join();

    return Center(
      child: Text(
        (initials.isEmpty ? '?' : initials.toUpperCase()),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey.shade800),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}