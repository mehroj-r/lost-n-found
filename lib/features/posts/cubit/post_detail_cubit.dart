import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';

// States
abstract class PostDetailState {}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostDetailLoaded extends PostDetailState {
  final Post post;
  PostDetailLoaded(this.post);
}

class PostDetailError extends PostDetailState {
  final String message;
  final String? errorCode;
  PostDetailError(this.message, {this.errorCode});
}

class PostDetailDeleting extends PostDetailState {}

class PostDetailDeleted extends PostDetailState {}

// Cubit
class PostDetailCubit extends Cubit<PostDetailState> {
  final IPostRepository postRepository;
  
  PostDetailCubit(this.postRepository) : super(PostDetailInitial());

  Future<void> loadPost(String postId) async {
    emit(PostDetailLoading());
    try {
      final post = await postRepository.getPostById(postId);
      emit(PostDetailLoaded(post));
    } on ApiException catch (e) {
      emit(PostDetailError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(PostDetailError('Failed to load post: ${e.toString()}'));
    }
  }

  Future<void> deletePost(String postId) async {
    emit(PostDetailDeleting());
    try {
      await postRepository.deletePost(postId);
      emit(PostDetailDeleted());
    } on ApiException catch (e) {
      emit(PostDetailError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(PostDetailError('Failed to delete post: ${e.toString()}'));
    }
  }
}
