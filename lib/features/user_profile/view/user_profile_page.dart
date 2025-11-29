// dart
          import 'package:flutter/material.dart';
          import 'package:flutter_bloc/flutter_bloc.dart';
          import 'package:go_router/go_router.dart';
          import 'package:photo_view/photo_view.dart';
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

          class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {
            late UserProfileController _controller;
            late TabController _tabController;

            @override
            void initState() {
              super.initState();
              _tabController = TabController(length: 2, vsync: this);
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
              _tabController.dispose();
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

                    return Column(
                      children: [
                        // App Bar with gradient and avatar
                        _buildTopSection(context, user, colorScheme),

                        // Tab Bar
                        _buildTabBar(context, colorScheme),

                        // Tab Views
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Details Tab
                              _buildDetailsTab(context, user, colorScheme, isOwnProfile),
                              
                              // Posts Tab
                              _buildPostsTab(context, colorScheme),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }

            Widget _buildTopSection(BuildContext context, AppUser user, ColorScheme colorScheme) {
              return Container(
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
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  context.go('/home');
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
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
                          ],
                        ),
                      ),
                      // Avatar and Name
                      Stack(
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Column(
                              children: [
                                _buildLargeAvatar(user, colorScheme),
                                const SizedBox(height: 16),
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
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget _buildTabBar(BuildContext context, ColorScheme colorScheme) {
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.person_outline),
                      text: 'Details',
                    ),
                    Tab(
                      icon: Icon(Icons.grid_view_rounded),
                      text: 'Posts',
                    ),
                  ],
                ),
              );
            }

            Widget _buildDetailsTab(
              BuildContext context,
              AppUser user,
              ColorScheme colorScheme,
              bool isOwnProfile,
            ) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildProfileInfo(context, user, colorScheme, isOwnProfile),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            }

            Widget _buildPostsTab(BuildContext context, ColorScheme colorScheme) {
              if (_controller.isLoadingPosts) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (_controller.posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 100),
                itemCount: _controller.posts.length,
                itemBuilder: (context, index) {
                  final post = _controller.posts[index];
                  return PostWidget(
                    post: post,
                    onTap: () {
                      context.push('/posts/${post.id}', extra: post);
                    },
                    onLikeToggle: (isLiked) {
                      // Handle like toggle if needed
                    },
                  );
                },
              );
            }

            Widget _buildLargeAvatar(AppUser user, ColorScheme colorScheme) {
              final hasAvatar = user.avatar?.url != null && user.avatar!.url.isNotEmpty;
              
              return GestureDetector(
                onTap: hasAvatar ? () => _openAvatarViewer(user) : null,
                child: Hero(
                  tag: 'user-avatar-${user.id}',
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: hasAvatar
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
                  ),
                ),
              );
            }

            void _openAvatarViewer(AppUser user) {
              if (user.avatar?.url == null || user.avatar!.url.isEmpty) return;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => _AvatarViewerPage(
                    imageUrl: user.avatar!.url,
                    userName: _getFullName(user),
                    userId: user.id,
                  ),
                ),
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
                      fontSize: 52,
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        if (user.username.isNotEmpty) ...[
                          _buildInfoRow(
                            Icons.alternate_email_rounded,
                            '@${user.username}',
                            colorScheme,
                            isTitle: true,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Email
                        _buildInfoRow(
                          Icons.email_outlined,
                          user.email,
                          colorScheme,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        if (user.phoneNumber.isNotEmpty) ...[
                          _buildInfoRow(
                            Icons.phone_outlined,
                            user.phoneNumber,
                            colorScheme,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Gender
                        if (user.gender.isNotEmpty) ...[
                          _buildInfoRow(
                            Icons.person_outline,
                            user.gender[0].toUpperCase() + user.gender.substring(1),
                            colorScheme,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }

            Widget _buildInfoRow(
              IconData icon,
              String text,
              ColorScheme colorScheme, {
              bool isTitle = false,
            }) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: isTitle ? 16 : 15,
                        fontWeight: isTitle ? FontWeight.w600 : FontWeight.w500,
                        color: isTitle ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                        letterSpacing: isTitle ? 0.15 : 0,
                      ),
                    ),
                  ),
                ],
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

          // Avatar viewer page
          class _AvatarViewerPage extends StatelessWidget {
            final String imageUrl;
            final String userName;
            final int userId;

            const _AvatarViewerPage({
              required this.imageUrl,
              required this.userName,
              required this.userId,
            });

            @override
            Widget build(BuildContext context) {
              return Scaffold(
                backgroundColor: Colors.black,
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  title: Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                body: Hero(
                  tag: 'user-avatar-$userId',
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    initialScale: PhotoViewComputedScale.contained,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    loadingBuilder: (context, event) => Center(
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    errorBuilder: (context, error, stackTrace) => Center(
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
                            'Failed to load avatar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          }