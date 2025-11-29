import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
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

  void _openImageViewer() {
    if (_post.photo?.url == null || _post.photo!.url.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerPage(
          imageUrl: _post.photo!.url,
          title: _post.title,
        ),
      ),
    );
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
        backgroundColor: AppColors.pageBackground,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(statusColor),
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFFF8F9FA),
                child: Column(
                  children: [
                    _buildContentCard(statusColor),
                    const SizedBox(height: 16),
                    if (_post.tags.isNotEmpty) ...[
                      _buildTagsCard(),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _canMessage ? _buildMessageButton() : null,
      ),
    );
  }

  Widget _buildSliverAppBar(Color statusColor) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: Colors.white,
            onPressed: () {
              context.go('/home');
            },
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: _openImageViewer,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _post.photo?.url != null && _post.photo!.url.isNotEmpty
                  ? Hero(
                      tag: 'post-image-${_post.id}',
                      child: Image.network(
                        _post.photo!.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(statusColor),
                      ),
                    )
                  : _buildPlaceholder(statusColor),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: GestureDetector(
                onTap: _openAuthorProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
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
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_post.author.firstName} ${_post.author.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _getTimeAgo(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color statusColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.2),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _post.type == 'lost' ? Icons.search_rounded : Icons.location_on_rounded,
          size: 80,
          color: statusColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildContentCard(Color statusColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _post.location.isNotEmpty
                                    ? _post.location
                                    : 'Location not specified',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _likeInProgress ? null : _toggleLike,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _post.isLiked
                              ? Colors.red.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _post.isLiked
                                ? Colors.red.shade200
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _post.isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _post.isLiked ? Colors.red : Colors.grey.shade600,
                              size: 22,
                            ),
                            if (_post.likeCount > 0) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${_post.likeCount}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _post.isLiked ? Colors.red : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.3)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _post.description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.label_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _post.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, right: 4),
      child: FloatingActionButton(
        onPressed: _openChat,
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(
          Icons.chat_bubble_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _ImageViewerPage({
    required this.imageUrl,
    required this.title,
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
          title,
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
        tag: 'post-image-${imageUrl.hashCode}',
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
              color: AppColors.primary,
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
                  'Failed to load image',
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

