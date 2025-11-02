import 'dart:async';

class MockAuthRepository {
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!email.endsWith('@newuu.uz')) {
      throw Exception('Use your university email');
    }
    if (password.isEmpty) {
      throw Exception('Invalid credentials');
    }
    return {
      'accessToken': 'mock_at',
      'refreshToken': 'mock_rt',
      'user': {
        'id': 'u1',
        'email': email,
        'role': 'student',
        'fullName': 'NewUU Student',
        'avatarUrl': null,
      }
    };
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
