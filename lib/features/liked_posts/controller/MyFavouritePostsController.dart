import 'package:flutter/foundation.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';

class MyFavouritePostsController extends ChangeNotifier {
  final IPostRepository _postRepository = ServiceLocator().postRepository;

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFavouritePosts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postRepository.getLikedPosts();
    } catch (e, st) {
      _error = e.toString();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchFavouritePosts();
  }

  Future<void> toggleLike(int postId, bool isLiked) async {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];

        final updated = post.copyWith(
          isLiked: isLiked,
          likeCount: isLiked
              ? post.likeCount + 1
              : (post.likeCount > 0 ? post.likeCount - 1 : 0),
        );

        _posts[index] = updated;

        if (!isLiked) {
          _posts.removeAt(index);
        }

        notifyListeners();
      }

      if (isLiked) {
        await _postRepository.likePost(postId);
      } else {
        await _postRepository.unlikePost(postId);
      }
    } catch (e, st) {
      _error = e.toString();
      notifyListeners();

    }
  }
}