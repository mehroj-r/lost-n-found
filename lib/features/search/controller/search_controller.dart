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
  
  // Getters
  List<Post> get searchResults => _searchResults;
  List<Post> get recentPosts => _recentPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;
  bool get hasSearched => _hasSearched;
  bool get showRecentPosts => !_hasSearched && _currentQuery.isEmpty;

  // Search with debounce
  void search(String query) {
    _currentQuery = query.trim();
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (_currentQuery.isEmpty) {
      _searchResults.clear();
      _hasSearched = false;
      _error = null;
      notifyListeners();
      return;
    }

    // Add debounce delay for progressive search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_currentQuery);
    });
  }

  // Perform actual search
  Future<void> _performSearch(String query) async {
    if (query.isEmpty || query != _currentQuery) return;

    _isLoading = true;
    _error = null;
    _hasSearched = true;
    notifyListeners();

    try {
      final results = await _postRepository.searchPosts(query);
      
      // Only update if this is still the current query (user didn't type something else)
      if (query == _currentQuery && !_disposed) {
        _searchResults = results;
      }
    } catch (e) {
      if (query == _currentQuery && !_disposed) {
        _error = e.toString();
      }
    } finally {
      if (query == _currentQuery && !_disposed) {
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
    _currentQuery = '';
    _searchResults.clear();
    _hasSearched = false;
    _error = null;
    _debounceTimer?.cancel();
    notifyListeners();
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
      print('Error toggling like: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }
}