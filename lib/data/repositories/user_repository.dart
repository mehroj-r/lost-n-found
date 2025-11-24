import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/user.dart';

abstract class IUserRepository {
  Future<AppUser> getCurrentUser();
  Future<AppUser> updateProfile(Map<String, dynamic> data);
  Future<String> uploadAvatar(File file);
}

class UserRepository implements IUserRepository {
  final DioClient dioClient;

  UserRepository({required this.dioClient});

  @override
  Future<AppUser> getCurrentUser() async {
    final response = await dioClient.get('/users/profile');

    final responseData = response.data as Map<String, dynamic>;
    final userData =
        responseData['data'] as Map<String, dynamic>? ?? responseData;

    // Let AppUser.fromJson handle avatar, bio, etc.
    return AppUser.fromJson(userData);
  }

  @override
  Future<AppUser> updateProfile(Map<String, dynamic> data) async {
    final response = await dioClient.patch('/users/profile/', data: data);
    final raw = response.data;
    final status = response.statusCode ?? 0;

    if (status >= 200 && status < 300 && raw is Map<String, dynamic>) {
      final responseData = raw;
      final userData =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return AppUser.fromJson(userData);
    }

    if (status >= 200 && status < 300 && raw is String && raw.isEmpty) {
      return AppUser.fromJson(data);
    }

    throw Exception(
      'Profile update failed: HTTP $status, body type ${raw.runtimeType}, value: $raw',
    );

  }
  @override
  Future<String> uploadAvatar(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });

    final response = await dioClient.post('/files/', data: formData);

    final status = response.statusCode ?? 0;
    final raw = response.data;

    if (status < 200 || status >= 300) {
      throw Exception(
        'Upload avatar failed: HTTP $status, body type ${raw.runtimeType}, value: $raw',
      );
    }

    if (raw is! Map<String, dynamic>) {
      throw Exception(
        'Upload avatar failed: unexpected response type ${raw.runtimeType}, value: $raw',
      );
    }

    final data = raw as Map<String, dynamic>;
    final inner = data['data'] as Map<String, dynamic>? ?? data;

    final id = inner['id'] ?? inner['file_id'];
    if (id == null) {
      throw Exception('Upload avatar failed: no id in response: $data');
    }

    return id.toString();
  }


}
