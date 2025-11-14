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
      print('📤 FileRepository: Uploading file from: $filePath');
      print('📤 FileRepository: Calling dioClient.uploadFile()');

      final response = await dioClient.uploadFile(
        ApiConfig.files,
        filePath,
        fileKey: 'file',
      );

      print('📤 FileRepository: Got response with status: ${response.statusCode}');
      print('📤 FileRepository: Response data: ${response.data}');

      final data = response.data;
      if (data is Map && data['success'] == true && data.containsKey('data')) {
        final fileData = data['data'];
        print('✅ FileRepository: File uploaded successfully! ID: ${fileData['id']}');

        // The API returns file info but not the URL directly in the upload response
        // We'll construct it or leave it empty for now since posts use photo ID
        final photo = Photo(
          id: fileData['id'] ?? 0,
          url: '', // URL not needed for post creation, only ID is used
          size: fileData['size'] ?? 0,
          name: fileData['name'] ?? '',
          extension: fileData['extension'] ?? '',
          createdAt: fileData['created_at'] != null
              ? DateTime.parse(fileData['created_at'])
              : DateTime.now(),
        );

        print('✅ FileRepository: Created Photo object: $photo');
        return photo;
      }

      print('❌ FileRepository: Invalid response format');
      throw Exception('Failed to upload file: Invalid response format');
    } catch (e, stackTrace) {
      print('❌ FileRepository: Upload failed with error: $e');
      print('❌ FileRepository: Stack trace: $stackTrace');
      rethrow;
    }
  }
}

