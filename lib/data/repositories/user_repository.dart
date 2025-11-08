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
      id: userData['id']?.toString() ?? '',
      firstName: userData['first_name']?.toString() ?? userData['firstName']?.toString() ?? '',
      lastName: userData['last_name']?.toString() ?? userData['lastName']?.toString() ?? '',
      email: userData['email']?.toString() ?? '',
      phoneNumber: userData['phone']?.toString() ?? userData['phone_number']?.toString() ?? userData['phoneNumber']?.toString() ?? '',
      gender: userData['gender']?.toString() ?? '',
      avatarUrl: userData['avatar']?.toString() ?? userData['avatar_url']?.toString() ?? userData['avatarUrl']?.toString(),
    );
  }

  @override
  Future<AppUser> updateProfile(Map<String, dynamic> data) async {
    final response = await dioClient.patch('/auth/profile', data: data);
    
    final responseData = response.data as Map<String, dynamic>;
    final userData = responseData['data'] as Map<String, dynamic>? ?? responseData;
    
    return AppUser(
      id: userData['id']?.toString() ?? '',
      firstName: userData['first_name']?.toString() ?? userData['firstName']?.toString() ?? '',
      lastName: userData['last_name']?.toString() ?? userData['lastName']?.toString() ?? '',
      email: userData['email']?.toString() ?? '',
      phoneNumber: userData['phone_number']?.toString() ?? userData['phoneNumber']?.toString() ?? '',
      gender: userData['gender']?.toString() ?? '',
      avatarUrl: userData['avatar_url']?.toString() ?? userData['avatarUrl']?.toString(),
    );
  }
}
