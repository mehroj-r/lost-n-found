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

// Cubit
class UploadCubit extends Cubit<UploadState> {
  final IPostRepository postRepository;
  final IFileRepository fileRepository;

  Photo? _uploadedPhoto;
  String? _selectedImagePath;

  UploadCubit({
    required this.postRepository,
    required this.fileRepository,
  }) : super(UploadInitial());

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
  }) async {
    try {
      emit(CreatingPost(photo: _uploadedPhoto, localPath: _selectedImagePath));

      final post = await postRepository.createPost(
        title: title,
        description: description,
        type: type,
        photoId: _uploadedPhoto?.id,
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

  void reset() {
    _uploadedPhoto = null;
    _selectedImagePath = null;
    emit(UploadInitial());
  }

  void removeImage() {
    _uploadedPhoto = null;
    _selectedImagePath = null;
    emit(UploadInitial());
  }
}

