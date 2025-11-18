import 'package:flutter/material.dart';
import '../../../shared/widgets/postWidget.dart';
import '../controller/search_controller.dart' as search_ctrl;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late search_ctrl.SearchController _searchController;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _searchController = search_ctrl.SearchController();
    _textController = TextEditingController();
    _focusNode = FocusNode();

    // Load recent posts when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && mounted) {
        _searchController.loadRecentPosts();
        // Don't auto-focus since this is now a bottom tab page
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _searchController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: SizedBox(
          height: 40,
          child: _buildSearchBar(),
        ),
        actions: [
          AnimatedBuilder(
            animation: _searchController,
            builder: (context, child) {
              return _searchController.currentQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textController.clear();
                        _searchController.clearSearch();
                      },
                    )
                  : const SizedBox.shrink();
              },
            ),
          ],
        ),
      body: _disposed ? const SizedBox.shrink() : AnimatedBuilder(
        animation: _searchController,
        builder: (context, child) {
          if (_disposed || !mounted) return const SizedBox.shrink();
          return _buildBody();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Search posts...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
      ),
      textInputAction: TextInputAction.search,
      onChanged: (query) {
        _searchController.search(query);
      },
      onSubmitted: (query) {
        _searchController.instantSearch(query);
      },
    );
  }

  Widget _buildBody() {
    // Show loading indicator during search
    if (_searchController.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    // Show error if search failed
    if (_searchController.error != null) {
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
              'Search failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.instantSearch(_searchController.currentQuery);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show search results
    if (_searchController.hasSearched) {
      return _buildSearchResults();
    }

    // Show recent posts when no search
    if (_searchController.showRecentPosts) {
      return _buildRecentPosts();
    }

    return const SizedBox.shrink();
  }

  Widget _buildSearchResults() {
    if (_searchController.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${_searchController.searchResults.length} result${_searchController.searchResults.length == 1 ? '' : 's'} for "${_searchController.currentQuery}"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100), // Add bottom padding for navbar
            itemCount: _searchController.searchResults.length,
            itemBuilder: (context, index) {
              final post = _searchController.searchResults[index];
              return PostWidget(
                post: post,
                onTap: () {
                  // Navigate to post detail
                  print('Tapped on search result: ${post.title}');
                },
                onLikeToggle: (isLiked) {
                  _searchController.toggleLike(post.id, isLiked);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPosts() {
    if (_searchController.recentPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Search for posts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find lost and found items by searching',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Recent Posts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100), // Add bottom padding for navbar
            itemCount: _searchController.recentPosts.length,
            itemBuilder: (context, index) {
              final post = _searchController.recentPosts[index];
              return PostWidget(
                post: post,
                onTap: () {
                  print('Tapped on recent post: ${post.title}');
                },
                onLikeToggle: (isLiked) {
                  _searchController.toggleLike(post.id, isLiked);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}