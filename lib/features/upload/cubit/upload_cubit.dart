import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/file_repository.dart';
import '../../../data/models/post.dart';
import '../../../data/models/photo.dart';

// States
abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadState {}

class UploadImageSelected extends UploadState {
  final String imagePath;

  const UploadImageSelected(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class UploadingImage extends UploadState {}

class ImageUploaded extends UploadState {
  final Photo photo;
  final String localPath;

  const ImageUploaded(this.photo, this.localPath);

  @override
  List<Object?> get props => [photo, localPath];
}

class CreatingPost extends UploadState {
  final Photo? photo;
  final String? localPath;

  const CreatingPost({this.photo, this.localPath});

  @override
  List<Object?> get props => [photo, localPath];
}

class PostCreated extends UploadState {
  final Post post;

  const PostCreated(this.post);

  @override
  List<Object?> get props => [post];
}

class UploadError extends UploadState {
  final String message;

  const UploadError(this.message);

  @override
  List<Object?> get props => [message];
}

class LoadingPost extends UploadState {
  final Post? post;
  
  const LoadingPost({this.post});
  
  @override
  List<Object?> get props => [post];
}

class PostLoaded extends UploadState {
  final Post post;

  const PostLoaded(this.post);

  @override
  List<Object?> get props => [post];
}

class UpdatingPost extends UploadState {
  final Photo? photo;
  final String? localPath;

  const UpdatingPost({this.photo, this.localPath});

  @override
  List<Object?> get props => [photo, localPath];
}

class PostUpdated extends UploadState {
  final Post post;

  const PostUpdated(this.post);

  @override
  List<Object?> get props => [post];
}

// Cubit
class UploadCubit extends Cubit<UploadState> {
  final IPostRepository postRepository;
  final IFileRepository fileRepository;

  Photo? _uploadedPhoto;
  String? _selectedImagePath;

  Post? _editingPost;
  bool _isEditMode = false;

  UploadCubit({
    required this.postRepository,
    required this.fileRepository,
  }) : super(UploadInitial());

  bool get isEditMode => _isEditMode;
  Post? get editingPost => _editingPost;

  Future<void> loadPostForEdit(int postId) async {
    try {
      emit(LoadingPost());
      _editingPost = await postRepository.getPostById(postId.toString());
      _isEditMode = true;
      emit(PostLoaded(_editingPost!));
    } catch (e) {
      emit(UploadError('Failed to load post: ${e.toString()}'));
    }
  }

  void initializeForCreate() {
    _editingPost = null;
    _isEditMode = false;
    _uploadedPhoto = null;
    _selectedImagePath = null;
    emit(UploadInitial());
  }

  void selectImage(String imagePath) {
    _selectedImagePath = imagePath;
    emit(UploadImageSelected(imagePath));
  }

  Future<void> uploadImage(String imagePath) async {
    try {
      print('🔵 UploadCubit: Starting image upload for: $imagePath');
      emit(UploadingImage());

      print('🔵 UploadCubit: Calling fileRepository.uploadFile()');
      _uploadedPhoto = await fileRepository.uploadFile(imagePath);

      print('🟢 UploadCubit: Image uploaded successfully! Photo ID: ${_uploadedPhoto!.id}');
      _selectedImagePath = imagePath;
      emit(ImageUploaded(_uploadedPhoto!, imagePath));
    } catch (e, stackTrace) {
      print('🔴 UploadCubit: Upload failed with error: $e');
      print('🔴 UploadCubit: Stack trace: $stackTrace');
      emit(UploadError('Failed to upload image: ${e.toString()}'));
      // Revert to previous state
      if (_selectedImagePath != null) {
        emit(UploadImageSelected(_selectedImagePath!));
      } else {
        emit(UploadInitial());
      }
    }
  }

  Future<void> createPost({
    required String title,
    required String description,
    required String type,
    String? location,
  }) async {
    try {
      emit(CreatingPost(photo: _uploadedPhoto, localPath: _selectedImagePath));

      final post = await postRepository.createPost(
        title: title,
        description: description,
        type: type,
        photoId: _uploadedPhoto?.id,
        location: location,
      );

      emit(PostCreated(post));

      // Reset state after successful creation
      _uploadedPhoto = null;
      _selectedImagePath = null;
    } catch (e) {
      emit(UploadError('Failed to create post: ${e.toString()}'));
      // Revert to previous state
      if (_uploadedPhoto != null && _selectedImagePath != null) {
        emit(ImageUploaded(_uploadedPhoto!, _selectedImagePath!));
      } else if (_selectedImagePath != null) {
        emit(UploadImageSelected(_selectedImagePath!));
      } else {
        emit(UploadInitial());
      }
    }
  }

  Future<void> updatePost({
    required int postId,
    required String title,
    required String description,
    required String type,
    String? location,
    bool? isCompleted,
  }) async {
    try {
      emit(UpdatingPost(photo: _uploadedPhoto, localPath: _selectedImagePath));

      final updateData = <String, dynamic>{
        'title': title,
        'description': description,
        'type': type,
        if (isCompleted != null) 'is_completed': isCompleted,
        if (_uploadedPhoto != null) 'photo': _uploadedPhoto!.id,
        if (location != null && location.isNotEmpty) 'location': location,
      };

      final post = await postRepository.updatePost(postId.toString(), updateData);

      emit(PostUpdated(post));

      // Reset state after successful update
      _uploadedPhoto = null;
      _selectedImagePath = null;
      _isEditMode = false;
      _editingPost = null;
    } catch (e) {
      emit(UploadError('Failed to update post: ${e.toString()}'));
      // Revert to previous state
      if (_editingPost != null) {
        emit(PostLoaded(_editingPost!));
      } else if (_uploadedPhoto != null && _selectedImagePath != null) {
        emit(ImageUploaded(_uploadedPhoto!, _selectedImagePath!));
      } else if (_selectedImagePath != null) {
        emit(UploadImageSelected(_selectedImagePath!));
      } else {
        emit(UploadInitial());
      }
    }
  }

  void reset() {
    _uploadedPhoto = null;
    _selectedImagePath = null;
    _editingPost = null;
    _isEditMode = false;
    emit(UploadInitial());
  }

  void removeImage() {
    _uploadedPhoto = null;
    _selectedImagePath = null;
    emit(_isEditMode && _editingPost != null 
        ? PostLoaded(_editingPost!) 
        : UploadInitial());
  }
}

