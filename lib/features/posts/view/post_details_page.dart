import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/post.dart';
import '../cubit/post_detail_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Post _post;
  bool _likeInProgress = false;
  final bool _loadingDetails = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(_post.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  String _getAuthorInitial() {
    if (_post.author.firstName.isNotEmpty) {
      return _post.author.firstName[0].toUpperCase();
    }
    if (_post.author.username.isNotEmpty) {
      return _post.author.username[0].toUpperCase();
    }
    return '?';
  }

  void _openAuthorProfile() {
    context.push('/user-profile/${_post.author.id}', extra: _post.author);
  }

  void _openChat() {
    final currentUser = context.read<AuthCubit>().state.user;
    if (currentUser == null) return;

    context.push('/chat', extra: {
      'postId': _post.id,
    });
  }

  Future<void> _toggleLike() async {
    if (_likeInProgress) return;

    setState(() {
      _likeInProgress = true;
      _post = _post.copyWith(
        isLiked: !_post.isLiked,
        likeCount: _post.isLiked
            ? (_post.likeCount > 0 ? _post.likeCount - 1 : 0)
            : _post.likeCount + 1,
      );
    });

    try {
      final postRepository = ServiceLocator().postRepository;
      if (_post.isLiked) {
        await postRepository.likePost(_post.id);
      } else {
        await postRepository.unlikePost(_post.id);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _post = _post.copyWith(
          isLiked: !_post.isLiked,
          likeCount: !_post.isLiked
              ? (_post.likeCount > 0 ? _post.likeCount - 1 : 0)
              : _post.likeCount + 1,
        );
      });
    } finally {
      setState(() {
        _likeInProgress = false;
      });
    }
  }

  bool get _canMessage {
    final currentUser = context.read<AuthCubit>().state.user;
    return currentUser != null && currentUser.id != _post.author.id;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _post.isCompleted
        ? Colors.green
        : (_post.type == 'lost' ? Colors.orange : Colors.blue);

    return BlocProvider(
      create: (context) => PostDetailCubit(ServiceLocator().postRepository),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Top image section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 340,
              child: Stack(
                children: [
                  // Image
                  _post.photo?.url != null && _post.photo!.url.isNotEmpty
                      ? Image.network(
                    _post.photo!.url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(statusColor),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholder(statusColor);
                    },
                  )
                      : _buildPlaceholder(statusColor),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back button - top left corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Material(
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Author avatar - clickable
                  Positioned(
                    left: 20,
                    bottom: 32,
                    child: GestureDetector(
                      onTap: _openAuthorProfile,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 23,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            backgroundImage: _post.author.avatar?.url != null &&
                                _post.author.avatar!.url.isNotEmpty
                                ? NetworkImage(_post.author.avatar!.url)
                                : null,
                            child: _post.author.avatar?.url == null ||
                                _post.author.avatar!.url.isEmpty
                                ? Text(
                              _getAuthorInitial(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.primary,
                              ),
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Author name below avatar
                  Positioned(
                    left: 20,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: _openAuthorProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_post.author.firstName} ${_post.author.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White rounded detail sheet
            Positioned(
              left: 0,
              right: 0,
              top: 340,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _titleRow(statusColor),
                            const SizedBox(height: 16),
                            _infoRow(),
                            const SizedBox(height: 20),
                            const Divider(color: AppColors.divider, height: 1),
                            const SizedBox(height: 20),
                            _descriptionSection(),
                            const SizedBox(height: 24),
                            if (_post.tags.isNotEmpty) ...[
                              _categorySection(),
                              const SizedBox(height: 24),
                            ],
                            _locationAndMessageRow(context, _canMessage),
                            const SizedBox(height: 24),
                            _homeIndicator(),
                          ],
                        ),
                      ),
                      if (_loadingDetails)
                        const Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color statusColor) {
    return Container(
      color: statusColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          _post.type == 'lost' ? Icons.search_rounded : Icons.location_on_rounded,
          size: 64,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _titleRow(Color statusColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _post.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status badge - moved here next to title
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _post.isCompleted
                              ? Icons.check_circle_rounded
                              : (_post.type == 'lost'
                              ? Icons.search_rounded
                              : Icons.location_on_rounded),
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _post.isCompleted
                              ? 'Resolved'
                              : (_post.type == 'lost' ? 'Lost' : 'Found'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getTimeAgo(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Like button
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _post.isLiked
                    ? Colors.red.shade50
                    : AppColors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _likeInProgress ? null : _toggleLike,
                icon: Icon(
                  _post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _post.isLiked ? Colors.red : AppColors.textMuted,
                  size: 28,
                ),
              ),
            ),
            if (_post.likeCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_post.likeCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _post.isLiked ? Colors.red : AppColors.textMuted,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.distancePill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _post.location.isNotEmpty ? _post.location : 'Not specified',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _post.description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _categorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.label_outline_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _post.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _locationAndMessageRow(BuildContext context, bool canMessage) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _post.location.isNotEmpty ? _post.location : 'Not specified',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (canMessage) ...[
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                onPressed: _openChat,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'MESSAGE',
                      style: TextStyle(
                        letterSpacing: 0.8,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _homeIndicator() {
    return Center(
      child: Container(
        width: 120,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

