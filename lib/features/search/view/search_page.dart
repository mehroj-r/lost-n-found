import 'package:flutter/material.dart';
import '../../../shared/widgets/postWidget.dart';
import '../controller/search_controller.dart' as search_ctrl;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late search_ctrl.SearchController _searchController;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late AnimationController _filterAnimationController;
  bool _disposed = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = search_ctrl.SearchController();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Load recent posts when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && mounted) {
        _searchController.loadRecentPosts();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _searchController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Modern search header
            _buildSearchHeader(),
            
            // Filter section
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showFilters ? _buildFilterSection() : const SizedBox.shrink(),
            ),
            
            // Results section
            Expanded(
              child: _disposed ? const SizedBox.shrink() : AnimatedBuilder(
                animation: _searchController,
                builder: (context, child) {
                  if (_disposed || !mounted) return const SizedBox.shrink();
                  return _buildBody();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar row
          Row(
            children: [
              Expanded(child: _buildModernSearchBar()),
              const SizedBox(width: 12),
              _buildFilterButton(),
            ],
          ),
          
          // Active filters indicator
          if (_searchController.hasActiveFilters) ...[
            const SizedBox(height: 12),
            _buildActiveFiltersRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus 
            ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
            : Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: _focusNode.hasFocus ? [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search lost & found items...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: _focusNode.hasFocus 
                ? Theme.of(context).primaryColor
                : Colors.grey[400],
              size: 22,
            ),
          ),
          suffixIcon: AnimatedBuilder(
            animation: _searchController,
            builder: (context, child) {
              return _searchController.currentQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      _textController.clear();
                      _searchController.clearSearch();
                    },
                  )
                : const SizedBox.shrink();
            },
          ),
        ),
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 15),
        onChanged: (query) {
          _searchController.search(query);
        },
        onSubmitted: (query) {
          _searchController.instantSearch(query);
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return AnimatedBuilder(
      animation: _searchController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleFilters,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _showFilters || _searchController.hasActiveFilters
                  ? Theme.of(context).primaryColor
                  : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showFilters || _searchController.hasActiveFilters
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: _showFilters || _searchController.hasActiveFilters
                      ? Colors.white
                      : Colors.grey[700],
                    size: 20,
                  ),
                  if (_searchController.hasActiveFilters) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveFiltersRow() {
    return AnimatedBuilder(
      animation: _searchController,
      builder: (context, child) {
        List<Widget> filterChips = [];
        
        if (_searchController.selectedType != null) {
          filterChips.add(_buildFilterChip(
            label: _searchController.selectedType!.toUpperCase(),
            color: _searchController.selectedType == 'lost' 
              ? Colors.orange 
              : Colors.green,
            onRemove: () => _searchController.setTypeFilter(null),
          ));
        }
        
        if (_searchController.dateStart != null) {
          final date = _searchController.dateStart!;
          filterChips.add(_buildFilterChip(
            label: 'From: ${date.day}/${date.month}/${date.year}',
            color: Colors.blue,
            onRemove: () => _searchController.setDateStartFilter(null),
          ));
        }
        
        if (_searchController.dateEnd != null) {
          final date = _searchController.dateEnd!;
          filterChips.add(_buildFilterChip(
            label: 'To: ${date.day}/${date.month}/${date.year}',
            color: Colors.blue[600]!,
            onRemove: () => _searchController.setDateEndFilter(null),
          ));
        }
        
        if (_searchController.orderBy != null) {
          final orderByLabel = _searchController.orderBy == 'created_at' ? 'Recent' : 'Popular';
          filterChips.add(_buildFilterChip(
            label: 'Sort: $orderByLabel',
            color: Colors.purple,
            onRemove: () => _searchController.setOrderByFilter(null),
          ));
        }
        
        if (filterChips.isEmpty) return const SizedBox.shrink();
        
        return Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterChips.map((chip) => 
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: chip,
                    )
                  ).toList(),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _searchController.clearFilters,
              icon: Icon(
                Icons.clear_all_rounded,
                size: 16,
                color: Colors.grey[600],
              ),
              label: Text(
                'Clear all',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: AnimatedBuilder(
        animation: _searchController,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Type filter
          Text(
            'Post Type',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterOption(
                  label: 'Lost',
                  isSelected: _searchController.selectedType == 'lost',
                  color: Colors.orange,
                  onTap: () {
                    _searchController.setTypeFilter(
                      _searchController.selectedType == 'lost' ? null : 'lost'
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterOption(
                  label: 'Found',
                  isSelected: _searchController.selectedType == 'found',
                  color: Colors.green,
                  onTap: () {
                    _searchController.setTypeFilter(
                      _searchController.selectedType == 'found' ? null : 'found'
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Date range filter
          Text(
            'Date Range',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Start date
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _searchController.dateStart ?? DateTime.now().subtract(const Duration(days: 30)),
                      firstDate: DateTime(2020),
                      lastDate: _searchController.dateEnd ?? DateTime.now(),
                      helpText: 'Select start date',
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: Colors.blue,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      _searchController.setDateStartFilter(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _searchController.dateStart != null 
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _searchController.dateStart != null
                          ? Colors.blue
                          : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: _searchController.dateStart != null
                            ? Colors.blue
                            : Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _searchController.dateStart != null
                              ? '${_searchController.dateStart!.day}/${_searchController.dateStart!.month}/${_searchController.dateStart!.year}'
                              : 'Start date',
                            style: TextStyle(
                              color: _searchController.dateStart != null
                                ? Colors.blue[700]
                                : Colors.grey[600],
                              fontSize: 13,
                              fontWeight: _searchController.dateStart != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_searchController.dateStart != null)
                          GestureDetector(
                            onTap: () => _searchController.setDateStartFilter(null),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // End date
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _searchController.dateEnd ?? DateTime.now(),
                      firstDate: _searchController.dateStart ?? DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      helpText: 'Select end date',
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: Colors.blue,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      _searchController.setDateEndFilter(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _searchController.dateEnd != null 
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _searchController.dateEnd != null
                          ? Colors.blue
                          : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: _searchController.dateEnd != null
                            ? Colors.blue
                            : Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _searchController.dateEnd != null
                              ? '${_searchController.dateEnd!.day}/${_searchController.dateEnd!.month}/${_searchController.dateEnd!.year}'
                              : 'End date',
                            style: TextStyle(
                              color: _searchController.dateEnd != null
                                ? Colors.blue[700]
                                : Colors.grey[600],
                              fontSize: 13,
                              fontWeight: _searchController.dateEnd != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_searchController.dateEnd != null)
                          GestureDetector(
                            onTap: () => _searchController.setDateEndFilter(null),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.blue[700],
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
          
          const SizedBox(height: 24),
          
          // Order by filter
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterOption(
                  label: 'Recent',
                  isSelected: _searchController.orderBy == 'created_at',
                  color: Colors.blue,
                  onTap: () {
                    _searchController.setOrderByFilter(
                      _searchController.orderBy == 'created_at' ? null : 'created_at'
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterOption(
                  label: 'Popular',
                  isSelected: _searchController.orderBy == 'like_count',
                  color: Colors.purple,
                  onTap: () {
                    _searchController.setOrderByFilter(
                      _searchController.orderBy == 'like_count' ? null : 'like_count'
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Quick date range filters
          const SizedBox(height: 16),
          Text(
            'Quick Filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickFilterChip(
                label: 'Today',
                onTap: () => _searchController.setTodayFilter(),
              ),
              _buildQuickFilterChip(
                label: 'Last Week',
                onTap: () => _searchController.setLastWeekFilter(),
              ),
              _buildQuickFilterChip(
                label: 'Last Month',
                onTap: () => _searchController.setLastMonthFilter(),
              ),
            ],
            ),
        ],
          );
        },
      ),
    );
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.blue[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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