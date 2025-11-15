import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/post.dart';
import '../../../data/repositories/post_repository.dart';

// States
abstract class CreatePostState {}

class CreatePostInitial extends CreatePostState {}

class CreatePostLoading extends CreatePostState {
  final double progress;
  CreatePostLoading({this.progress = 0.0});
}

class CreatePostSuccess extends CreatePostState {
  final Post post;
  CreatePostSuccess(this.post);
}

class CreatePostError extends CreatePostState {
  final String message;
  final String? errorCode;
  CreatePostError(this.message, {this.errorCode});
}

// Cubit
class CreatePostCubit extends Cubit<CreatePostState> {
  final IPostRepository postRepository;
  
  CreatePostCubit(this.postRepository) : super(CreatePostInitial());

  Future<void> createPost({
    required String title,
    required String description,
    required String type,
    int? photoId,
  }) async {
    emit(CreatePostLoading());
    
    try {
      final post = await postRepository.createPost(
        title: title,
        description: description,
        type: type,
        photoId: photoId,
      );
      
      emit(CreatePostSuccess(post));
    } on ApiException catch (e) {
      emit(CreatePostError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CreatePostError('Failed to create post: ${e.toString()}'));
    }
  }

  void reset() {
    emit(CreatePostInitial());
  }
}
