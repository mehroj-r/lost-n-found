// `lib/features/user_profile/controller/user_profile_controller.dart`
import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/user.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';

class UserProfileController extends ChangeNotifier {
  final int userId;
  final AppUser? initialUser;
  final IPostRepository _postRepository = ServiceLocator().postRepository;
  final IUserRepository _userRepository = ServiceLocator().userRepository;

  AppUser? _user;
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isLoadingPosts = false;
  String? _error;

  UserProfileController({required this.userId, this.initialUser}) {
    _user = initialUser;
  }

  AppUser? get user => _user;

  List<Post> get posts => _posts;

  bool get isLoading => _isLoading;

  bool get isLoadingPosts => _isLoadingPosts;

  String? get error => _error;

  Future<void> loadUserProfile() async {
    // If we already have the correct user, skip fetching
    if (_user != null && _user!.id == userId) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (initialUser != null && initialUser!.id == userId) {
        _user = initialUser;
      } else {
        // Try several common repository method names at runtime to avoid
        // compile-time error if the interface uses a different name.
        final repo = _userRepository as dynamic;
        dynamic fetched;
        // try common candidates in order
        try {
          fetched = await repo.getById(userId);
        } catch (_) {}
        if (fetched == null) {
          try {
            fetched = await repo.getUser(userId);
          } catch (_) {}
        }
        if (fetched == null) {
          try {
            fetched = await repo.getUserById(userId);
          } catch (_) {}
        }
        if (fetched == null) {
          try {
            fetched = await repo.fetchUser(userId);
          } catch (_) {}
        }

        if (fetched != null) {
          _user = fetched as AppUser?;
        } else {
          _error = 'User profile not available';
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPosts({int page = 1, int limit = 50}) async {
    if (_isLoadingPosts) return;

    _isLoadingPosts = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postRepository.getPosts(
        userId: userId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await Future.wait([loadUserProfile(), loadUserPosts()]);
  }
}
