import '../../core/network/dio_client.dart';
import '../models/user.dart';

abstract class IUserRepository {
  Future<AppUser> getCurrentUser();
  Future<AppUser> updateProfile(Map<String, dynamic> data);
}

class UserRepository implements IUserRepository {
  final DioClient dioClient;

  UserRepository({required this.dioClient});

  @override
  Future<AppUser> getCurrentUser() async {
    final response = await dioClient.get('/users/profile');
    
    final responseData = response.data as Map<String, dynamic>;
    final userData = responseData['data'] as Map<String, dynamic>? ?? responseData;
    
    return AppUser(
      id: userData['id'] ?? 0,
      firstName: userData['first_name']?.toString() ?? userData['firstName']?.toString() ?? '',
      lastName: userData['last_name']?.toString() ?? userData['lastName']?.toString() ?? '',
      patronymic: userData['patronymic']?.toString(),
      email: userData['email']?.toString() ?? '',
      username: userData['username']?.toString() ?? '',
      phoneNumber: userData['phone']?.toString() ?? userData['phone_number']?.toString() ?? userData['phoneNumber']?.toString() ?? '',
      gender: userData['gender']?.toString() ?? '',
      avatarUrl: userData['avatar']?.toString() ?? userData['avatar_url']?.toString() ?? userData['avatarUrl']?.toString(),
    );
  }

  @override
  Future<AppUser> updateProfile(Map<String, dynamic> data) async {
    final response = await dioClient.patch('/users/profile/', data: data);
    final raw = response.data;
    final status = response.statusCode ?? 0;

    // If success code and JSON map
    if (status >= 200 && status < 300 && raw is Map<String, dynamic>) {
      final responseData = raw;
      final userData =
          responseData['data'] as Map<String, dynamic>? ?? responseData;
      return AppUser.fromJson(userData);
    }

    // If success code and empty body, just use what we sent
    if (status >= 200 && status < 300 && raw is String && raw.isEmpty) {
      return AppUser.fromJson(data);
    }

    throw Exception(
      'Profile update failed: HTTP $status, body type ${raw.runtimeType}, value: $raw',
    );
  }
}
