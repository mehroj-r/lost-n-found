import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lost_n_found/shared/widgets/postWidget.dart';
import '../controller/MyFavouritePostsController.dart';

class MyFavouritePostsScreen extends StatefulWidget {
  const MyFavouritePostsScreen({super.key});

  @override
  State<MyFavouritePostsScreen> createState() => _MyFavouritePostsScreenState();
}

class _MyFavouritePostsScreenState extends State<MyFavouritePostsScreen> {
  late MyFavouritePostsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MyFavouritePostsController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchFavouritePosts();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'Failed to load favourites',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _controller.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _controller.refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'No favourites yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Like posts on the home feed and they will appear here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _controller.posts.length,
        itemBuilder: (context, index) {
          final post = _controller.posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black12,
                child: PostWidget(
                  post: post,
                  onTap: () {
                    context.push('/posts/${post.id}');
                  },
                  onLikeToggle: (isLiked) {
                    _controller.toggleLike(post.id, isLiked);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My favourites',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => _buildContent(),
      ),
    );
  }
}