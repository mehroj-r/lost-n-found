import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import 'dart:async';

class HomeController extends ChangeNotifier {
  final IPostRepository _postRepository = ServiceLocator().postRepository;
  final INotificationRepository _notificationRepository = ServiceLocator().notificationRepository;
  
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  int _unreadNotificationCount = 0;
  late StreamSubscription _notificationSubscription;

  HomeController() {
    _notificationSubscription = NotificationService().notificationUpdates.listen((_) {
      refreshNotificationCount();
    });
  }

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get unreadNotificationCount => _unreadNotificationCount;

  Future<void> fetchPosts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _posts.clear();
      _hasMore = true;
      _error = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch both posts and notification count concurrently
      final results = await Future.wait([
        _postRepository.getPosts(page: _currentPage, limit: 20),
        _fetchUnreadNotificationCount(),
      ]);
      
      final newPosts = results[0] as List<Post>;
      
      if (refresh) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }

      _hasMore = newPosts.length == 20; // If we get less than 20, no more posts
      if (newPosts.isNotEmpty) {
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await fetchPosts();
  }

  Future<void> refresh() async {
    await fetchPosts(refresh: true);
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
      // Could show error message here

    }
  }

  Future<void> _fetchUnreadNotificationCount() async {
    try {
      final count = await _notificationRepository.getUnreadCount();
      _unreadNotificationCount = count;
    } catch (e) {
      // Silently fail for notification count - don't show error for this

      _unreadNotificationCount = 0;
    }
  }

  Future<void> refreshNotificationCount() async {
    await _fetchUnreadNotificationCount();
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }
}