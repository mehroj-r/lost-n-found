import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/user.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';

class UserProfileController extends ChangeNotifier {
  final int userId;
  final AppUser? initialUser;
  final IPostRepository _postRepository = ServiceLocator().postRepository;

  AppUser? _user;
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isLoadingPosts = false;
  String? _error;

  UserProfileController({
    required this.userId,
    this.initialUser,
  }) {
    _user = initialUser;
  }

  AppUser? get user => _user;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingPosts => _isLoadingPosts;
  String? get error => _error;

  Future<void> loadUserProfile() async {
    // If we have initial user data, use it
    if (_user != null && _user!.id == userId) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use initial user if available
      if (initialUser != null && initialUser!.id == userId) {
        _user = initialUser;
      } else {
        // If no initial user, we'll need to fetch from posts
        // This is a limitation - ideally there should be a user detail endpoint
        _error = 'User profile not available';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPosts() async {
    if (_isLoadingPosts) return;

    _isLoadingPosts = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postRepository.getPosts(userId: userId, page: 1, limit: 50);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      loadUserProfile(),
      loadUserPosts(),
    ]);
  }
}

