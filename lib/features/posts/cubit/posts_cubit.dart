import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';

// States
abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<Post> posts;
  final bool hasMore;
  final int currentPage;

  PostsLoaded(this.posts, {this.hasMore = true, this.currentPage = 1});
}

class PostsError extends PostsState {
  final String message;
  final String? errorCode;

  PostsError(this.message, {this.errorCode});
}

// Cubit
class PostsCubit extends Cubit<PostsState> {
  final IPostRepository postRepository;
  
  PostsCubit(this.postRepository) : super(PostsInitial());

  // Load posts with pagination
  Future<void> loadPosts({int page = 1, int limit = 20}) async {
    if (page == 1) {
      emit(PostsLoading());
    }

    try {
      final posts = await postRepository.getPosts(page: page, limit: limit);
      emit(PostsLoaded(
        posts,
        hasMore: posts.length >= limit,
        currentPage: page,
      ));
    } on ApiException catch (e) {
      emit(PostsError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(PostsError('Failed to load posts: ${e.toString()}'));
    }
  }

  // Load more posts (pagination)
  Future<void> loadMorePosts() async {
    final currentState = state;
    if (currentState is PostsLoaded && currentState.hasMore) {
      try {
        final nextPage = currentState.currentPage + 1;
        final newPosts = await postRepository.getPosts(
          page: nextPage,
          limit: 20,
        );
        
        emit(PostsLoaded(
          [...currentState.posts, ...newPosts],
          hasMore: newPosts.length >= 20,
          currentPage: nextPage,
        ));
      } on ApiException catch (e) {
        // Keep current posts, just show error
        emit(PostsError(e.message, errorCode: e.errorCode));
      } catch (e) {
        emit(PostsError('Failed to load more posts'));
      }
    }
  }

  // Search posts
  Future<void> searchPosts(String query) async {
    emit(PostsLoading());
    try {
      final posts = await postRepository.searchPosts(query);
      emit(PostsLoaded(posts, hasMore: false, currentPage: 1));
    } on ApiException catch (e) {
      emit(PostsError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(PostsError('Search failed: ${e.toString()}'));
    }
  }

  // Refresh posts
  Future<void> refresh() async {
    await loadPosts(page: 1);
  }
}
