import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/postWidget.dart';
import '../controller/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _scrollController = ScrollController();
    
    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
    
    // Load initial posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchPosts(refresh: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          hasNotifications: true,
          onNotificationTap: () {
            context.go('/notifications');
          },
          onProfileTap: () {
            context.go('/profile');
          },
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostWidget(
            post: posts[index],
              onTap: () {
                print('Post clicked: ${posts[index].id}');
                context.go(
                  '/posts/${posts[index].id}',
                  extra: posts[index], // pass the whole Post object
                );
              },
            onLikeToggle: (isLiked) {
              // Handle like toggle
              print('Post liked: $isLiked');
            },
          );
        },
      ),
    );
  }

  Widget _buildBannersSection() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Main promotional banner
        _buildMainBanner(),
        const SizedBox(height: 12),
        // Statistics banners
        _buildStatsBanners(),
        const SizedBox(height: 16),
        // Section divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Posts',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMainBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                backgroundBlendMode: BlendMode.overlay,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Find What Matters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect with your community\nto reunite lost items',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBanners() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight( // Use IntrinsicHeight instead of fixed height
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.inventory_2_outlined,
                title: 'Lost Items',
                subtitle: 'Help find them',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite_outline,
                title: 'Found Items',
                subtitle: 'Reunite owners',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline,
                title: 'Community',
                subtitle: 'Growing daily',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8), // Reduced from 12 to 8
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Add this to minimize space
        children: [
          Icon(
            icon,
            color: color,
            size: 20, // Reduced from 24 to 20
          ),
          const SizedBox(height: 3), // Reduced from 4 to 3
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11, // Reduced from 12 to 11
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 9, // Reduced from 10 to 9
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}