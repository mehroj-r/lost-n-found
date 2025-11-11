import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';

class MyPostsController extends ChangeNotifier {
  final IPostRepository _postRepository = ServiceLocator().postRepository;
  
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'All';

  List<Post> get posts => _getFilteredPosts();
  List<Post> get allPosts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedFilter => _selectedFilter;

  List<Post> _getFilteredPosts() {
    if (_selectedFilter.toLowerCase() == 'all') {
      return _posts;
    }
    return _posts.where((post) => 
      post.type.toLowerCase() == _selectedFilter.toLowerCase()
    ).toList();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> fetchMyPosts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postRepository.getMyPosts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchMyPosts();
  }

  Future<void> deletePost(int postId) async {
    try {
      await _postRepository.deletePost(postId.toString());
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId, bool isLiked) async {
    try {
      // Optimistic update
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = Post(
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
        notifyListeners();
      }

      // Make API call
      if (isLiked) {
        await _postRepository.likePost(postId);
      } else {
        await _postRepository.unlikePost(postId);
      }
    } catch (e) {
      // Revert optimistic update on error
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = Post(
          id: post.id,
          title: post.title,
          description: post.description,
          photo: post.photo,
          tags: post.tags,
          type: post.type,
          author: post.author,
          location: post.location,
          likeCount: isLiked ? (post.likeCount > 0 ? post.likeCount - 1 : 0) : post.likeCount + 1,
          isLiked: !isLiked,
          isCompleted: post.isCompleted,
          createdAt: post.createdAt,
        );
        notifyListeners();
      }
      _error = e.toString();
      notifyListeners();
    }
  }
}