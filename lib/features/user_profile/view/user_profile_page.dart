// dart
          import 'package:flutter/material.dart';
          import 'package:flutter_bloc/flutter_bloc.dart';
          import 'package:go_router/go_router.dart';
          import '../../../data/models/user.dart';
          import '../../../data/models/post.dart';
          import '../../../shared/widgets/postWidget.dart';
          import '../../../features/auth/cubit/auth_cubit.dart';
          import '../controller/user_profile_controller.dart';

          class UserProfilePage extends StatefulWidget {
            final int userId;
            final AppUser? initialUser; // Optional initial user data from post

            const UserProfilePage({
              super.key,
              required this.userId,
              this.initialUser,
            });

            @override
            State<UserProfilePage> createState() => _UserProfilePageState();
          }

          class _UserProfilePageState extends State<UserProfilePage> {
            late UserProfileController _controller;

            @override
            void initState() {
              super.initState();
              _controller = UserProfileController(
                userId: widget.userId,
                initialUser: widget.initialUser,
              );

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _controller.loadUserProfile();
                _controller.loadUserPosts();
              });
            }

            @override
            void dispose() {
              _controller.dispose();
              super.dispose();
            }

            @override
            Widget build(BuildContext context) {
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;
              final currentUser = context.watch<AuthCubit>().state.user;
              final isOwnProfile = currentUser?.id == widget.userId;

              return Scaffold(
                backgroundColor: colorScheme.surface,
                body: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    if (_controller.isLoading && _controller.user == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (_controller.error != null && _controller.user == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load profile',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _controller.error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                _controller.loadUserProfile();
                                _controller.loadUserPosts();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final user = _controller.user ?? widget.initialUser;
                    if (user == null) {
                      return const Center(
                        child: Text('User not found'),
                      );
                    }

                    return CustomScrollView(
                      slivers: [
                        // App Bar with gradient
                        _buildSliverAppBar(context, user, colorScheme),

                        // Profile Content
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Info Section
                              _buildProfileInfo(context, user, colorScheme, isOwnProfile),

                              const SizedBox(height: 24),

                              // Stats Section
                              _buildStatsSection(context, user, colorScheme),

                              const SizedBox(height: 24),

                              // Posts Section Header
                              _buildPostsHeader(context, colorScheme),

                              const SizedBox(height: 16),

                              // Posts List
                              _buildPostsList(context, colorScheme),

                              const SizedBox(height: 100), // Bottom padding for navbar
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }

            Widget _buildSliverAppBar(BuildContext context, AppUser user, ColorScheme colorScheme) {
              return SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                elevation: 0,
                backgroundColor: colorScheme.surface,
                leading: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.7),
                          colorScheme.secondary.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Pattern overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ProfilePatternPainter(
                              Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        // Content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              // Avatar
                              _buildLargeAvatar(user, colorScheme),
                              const SizedBox(height: 16),
                              // Name
                              Text(
                                _getFullName(user),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            Widget _buildLargeAvatar(AppUser user, ColorScheme colorScheme) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: user.avatar?.url != null && user.avatar!.url.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.avatar!.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(user, colorScheme),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildAvatarFallback(user, colorScheme);
                          },
                        ),
                      )
                    : _buildAvatarFallback(user, colorScheme),
              );
            }

            Widget _buildAvatarFallback(AppUser user, ColorScheme colorScheme) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                    ),
                  ),
                ),
              );
            }

            String _getFullName(AppUser user) {
              final parts = <String>[];
              if (user.firstName.isNotEmpty && user.firstName != '.') {
                parts.add(user.firstName);
              }
              if (user.lastName.isNotEmpty && user.lastName != '.') {
                parts.add(user.lastName);
              }
              if (user.patronymic != null && user.patronymic!.isNotEmpty && user.patronymic != '.') {
                parts.add(user.patronymic!);
              }
              final fullName = parts.join(' ');
              return fullName.isNotEmpty ? fullName : (user.username.isNotEmpty ? user.username : 'User');
            }

            Widget _buildProfileInfo(
              BuildContext context,
              AppUser user,
              ColorScheme colorScheme,
              bool isOwnProfile,
            ) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        if (user.username.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.alternate_email_rounded,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '@${user.username}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Email
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        if (user.phoneNumber.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.phoneNumber,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Gender
                        if (user.gender.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.gender[0].toUpperCase() + user.gender.substring(1),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }

            Widget _buildStatsSection(BuildContext context, AppUser user, ColorScheme colorScheme) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Posts',
                        _controller.posts.length.toString(),
                        Icons.post_add_rounded,
                        colorScheme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Active',
                        _controller.posts.where((p) => !p.isCompleted).length.toString(),
                        Icons.radio_button_checked_rounded,
                        colorScheme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Resolved',
                        _controller.posts.where((p) => p.isCompleted).length.toString(),
                        Icons.check_circle_rounded,
                        colorScheme,
                      ),
                    ),
                  ],
                ),
              );
            }

            Widget _buildStatCard(
              BuildContext context,
              String label,
              String value,
              IconData icon,
              ColorScheme colorScheme,
            ) {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        size: 28,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget _buildPostsHeader(BuildContext context, ColorScheme colorScheme) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _controller.posts.length.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            Widget _buildPostsList(BuildContext context, ColorScheme colorScheme) {
              if (_controller.isLoadingPosts) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (_controller.posts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.post_add_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This user hasn\'t created any posts',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: _controller.posts.map((post) {
                  return PostWidget(
                    post: post,
                    onTap: () {
                      context.push('/posts/${post.id}', extra: post);
                    },
                    onLikeToggle: (isLiked) {
                      // Handle like toggle if needed
                    },
                  );
                }).toList(),
              );
            }
          }

          // Custom painter for profile pattern
          class _ProfilePatternPainter extends CustomPainter {
            final Color color;

            _ProfilePatternPainter(this.color);

            @override
            void paint(Canvas canvas, Size size) {
              final paint = Paint()..color = color..style = PaintingStyle.fill;

              final spacing = 30.0;
              final dotSize = 2.0;

              for (double x = 0; x < size.width; x += spacing) {
                for (double y = 0; y < size.height; y += spacing) {
                  canvas.drawCircle(
                    Offset(x + ((y / spacing).round() % 2) * spacing / 2, y),
                    dotSize,
                    paint,
                  );
                }
              }
            }

            @override
            bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
          }