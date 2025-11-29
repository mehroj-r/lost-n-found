import '../../core/network/dio_client.dart';
import '../../core/config/api_config.dart';
import '../models/photo.dart';

abstract class IFileRepository {
  Future<Photo> uploadFile(String filePath);
}

class FileRepository implements IFileRepository {
  final DioClient dioClient;

  FileRepository({required this.dioClient});

  @override
  Future<Photo> uploadFile(String filePath) async {
    try {
      final response = await dioClient.uploadFile(
        ApiConfig.files,
        filePath,
        fileKey: 'file',
      );

      final data = response.data;
      if (data is Map && data['success'] == true && data.containsKey('data')) {
        final fileData = data['data'];

        final photo = Photo(
          id: fileData['id'] ?? 0,
          url: '',
          size: fileData['size'] ?? 0,
          name: fileData['name'] ?? '',
          extension: fileData['extension'] ?? '',
          createdAt: fileData['created_at'] != null
              ? DateTime.parse(fileData['created_at'])
              : DateTime.now(),
        );

        return photo;
      }

      throw Exception('Failed to upload file: Invalid response format');
    } catch (e) {
      rethrow;
    }
  }
}

