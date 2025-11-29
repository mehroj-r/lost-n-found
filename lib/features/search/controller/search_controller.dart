import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';

class SearchController extends ChangeNotifier {
  final IPostRepository _postRepository = ServiceLocator().postRepository;
  
  List<Post> _searchResults = [];
  List<Post> _recentPosts = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';
  Timer? _debounceTimer;
  bool _hasSearched = false;
  bool _disposed = false;
  
  // Filter parameters
  String? _selectedType; // 'lost' or 'found'
  DateTime? _dateStart;
  DateTime? _dateEnd;
  String? _orderBy; // 'like_count' or 'created_at'
  
  // Getters
  List<Post> get searchResults => _searchResults;
  List<Post> get recentPosts => _recentPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;
  bool get hasSearched => _hasSearched;
  bool get showRecentPosts => !_hasSearched && _currentQuery.isEmpty;
  String? get selectedType => _selectedType;
  DateTime? get dateStart => _dateStart;
  DateTime? get dateEnd => _dateEnd;
  String? get orderBy => _orderBy;
  bool get hasActiveFilters => _selectedType != null || _dateStart != null || _dateEnd != null || _orderBy != null;

  // Set filters
  void setTypeFilter(String? type) {
    if (_selectedType != type) {
      _selectedType = type;
      notifyListeners(); // Immediate UI update
      _performFilterOrReloadRecent();
    }
  }

  void setDateStartFilter(DateTime? dateStart) {
    if (_dateStart != dateStart) {
      _dateStart = dateStart;
      notifyListeners(); // Immediate UI update
      _performFilterOrReloadRecent();
    }
  }

  void setDateEndFilter(DateTime? dateEnd) {
    if (_dateEnd != dateEnd) {
      _dateEnd = dateEnd;
      notifyListeners(); // Immediate UI update
      _performFilterOrReloadRecent();
    }
  }

  void setOrderByFilter(String? orderBy) {
    if (_orderBy != orderBy) {
      _orderBy = orderBy;
      notifyListeners(); // Immediate UI update
      _performFilterOrReloadRecent();
    }
  }

  void setDateRangeFilter(DateTime? dateStart, DateTime? dateEnd) {
    bool changed = _dateStart != dateStart || _dateEnd != dateEnd;
    if (changed) {
      _dateStart = dateStart;
      _dateEnd = dateEnd;
      notifyListeners(); // Immediate UI update
      _performFilterOrReloadRecent();
    }
  }

  // Convenience methods for common date ranges
  void setLastWeekFilter() {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    setDateRangeFilter(lastWeek, now);
  }

  void setLastMonthFilter() {
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));
    setDateRangeFilter(lastMonth, now);
  }

  void setTodayFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    setDateRangeFilter(today, tomorrow);
  }

  void clearFilters() {
    bool hasFilters = _selectedType != null || _dateStart != null || _dateEnd != null || _orderBy != null;
    _selectedType = null;
    _dateStart = null;
    _dateEnd = null;
    _orderBy = null;
    if (hasFilters) {
      notifyListeners(); // Immediate UI update
      // If we have a search query, perform filtered search, otherwise reload recent posts
      if (_currentQuery.isNotEmpty) {
        _performFilteredSearch();
      } else {
        // Clear filters with no query should reload recent posts
        _searchResults.clear();
        _hasSearched = false;
        _error = null;
        loadRecentPosts();
      }
    }
  }

  void _performFilteredSearch() {
    if (_currentQuery.isNotEmpty || hasActiveFilters) {
      _debounceTimer?.cancel();
      _performSearch(_currentQuery);
    }
  }

  void _performFilterOrReloadRecent() {
    if (_currentQuery.isNotEmpty || hasActiveFilters) {
      // There's a search query or active filters - perform search
      _debounceTimer?.cancel();
      _performSearch(_currentQuery);
    } else {
      // No search query and no filters - reload recent posts
      _searchResults.clear();
      _hasSearched = false;
      _error = null;
      loadRecentPosts();
    }
  }

  // Search with debounce
  void search(String query) {
    _currentQuery = query.trim();
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (_currentQuery.isEmpty && !hasActiveFilters) {
      _searchResults.clear();
      _hasSearched = false;
      _error = null;
      notifyListeners();
      return;
    }

    // Add debounce delay for progressive search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_disposed && query == _currentQuery) {
        _performSearch(_currentQuery);
      }
    });
  }

  // Perform actual search
  Future<void> _performSearch(String query) async {
    // Allow search even with empty query if we have filters
    if (query != _currentQuery && query.isNotEmpty) return;
    if (query.isEmpty && !hasActiveFilters) {
      // If no query and no filters, show recent posts
      _searchResults.clear();
      _hasSearched = false;
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _hasSearched = true;
    notifyListeners();

    try {
      final results = await _postRepository.searchPosts(
        query, 
        type: _selectedType,
        dateStart: _dateStart,
        dateEnd: _dateEnd,
        orderBy: _orderBy,
      );
      
      // Only update if this is still the current query or filters match
      if ((query == _currentQuery || query.isEmpty) && !_disposed) {
        _searchResults = results;
      }
    } catch (e) {
      if ((query == _currentQuery || query.isEmpty) && !_disposed) {
        _error = e.toString();
      }
    } finally {
      if ((query == _currentQuery || query.isEmpty) && !_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Load recent posts for when search is empty
  Future<void> loadRecentPosts() async {
    if (_disposed) return;
    
    try {
      _recentPosts = await _postRepository.getPosts(limit: 10);
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for recent posts
    }
  }

  // Clear search
  void clearSearch() {
    if (_disposed) return;
    
    _currentQuery = '';
    _searchResults.clear();
    _hasSearched = false;
    _error = null;
    _debounceTimer?.cancel();
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Instant search (without debounce) - for search button press
  Future<void> instantSearch(String query) async {
    _debounceTimer?.cancel();
    _currentQuery = query.trim();
    
    if (_currentQuery.isEmpty) {
      clearSearch();
      return;
    }

    await _performSearch(_currentQuery);
  }

  Future<void> toggleLike(int postId, bool isLiked) async {
    try {
      // Update in search results
      final searchIndex = _searchResults.indexWhere((post) => post.id == postId);
      if (searchIndex != -1) {
        final post = _searchResults[searchIndex];
        _searchResults[searchIndex] = Post(
          id: post.id,
          title: post.title,
          description: post.description,
          photo: post.photo,
          tags: post.tags,
          type: post.type,
          author: post.author,
          location: post.location,
          likeCount: isLiked ? post.likeCount + 1 : (post.likeCount > 0 ? post.likeCount - 1 : 0),
          isLiked: isLiked,
          isCompleted: post.isCompleted,
          createdAt: post.createdAt,
        );
      }

      // Update in recent posts
      final recentIndex = _recentPosts.indexWhere((post) => post.id == postId);
      if (recentIndex != -1) {
        final post = _recentPosts[recentIndex];
        _recentPosts[recentIndex] = Post(
          id: post.id,
          title: post.title,
          description: post.description,
          photo: post.photo,
          tags: post.tags,
          type: post.type,
          author: post.author,
          location: post.location,
          likeCount: isLiked ? post.likeCount + 1 : (post.likeCount > 0 ? post.likeCount - 1 : 0),
          isLiked: isLiked,
          isCompleted: post.isCompleted,
          createdAt: post.createdAt,
        );
      }

      notifyListeners();

      // Make API call
      if (isLiked) {
        await _postRepository.likePost(postId);
      } else {
        await _postRepository.unlikePost(postId);
      }
    } catch (e) {
      // Could revert changes on error

    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }
}