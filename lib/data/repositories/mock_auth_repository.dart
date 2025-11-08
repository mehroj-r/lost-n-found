import 'dart:async';

import 'auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Basic checks to simulate backend validation
    if (!email.endsWith('@newuu.uz')) {
      throw Exception('Use your university email (@newuu.uz)');
    }
    if (password.isEmpty) {
      throw Exception('Invalid credentials');
    }

    // Build a simple user object. Prefer first_name/last_name shape so AppUser mapping works.
    final local = email.split('@').first;
    final parts = local.split(RegExp(r'[._\-]')).where((s) => s.isNotEmpty).toList();
    final first = parts.isNotEmpty ? _capitalize(parts.first) : 'NewUU';
    final last = parts.length > 1 ? _capitalize(parts.sublist(1).join(' ')) : '';

    return {
      'accessToken': 'mock_at_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'mock_rt_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'u_${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'role': 'student',
        'first_name': first,
        'last_name': last,
        'phone_number': '',
        'gender': '',
        'avatarUrl': null,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    String? phoneNumber,
    String? username,
    String? patronymic,
    required String gender,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate server-side validation
    if (!email.endsWith('@newuu.uz')) {
      throw Exception('Registration requires a @newuu.uz email');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
    return {
      'accessToken': 'mock_at_reg_$id',
      'refreshToken': 'mock_rt_reg_$id',
      'user': {
        'id': id,
        'email': email,
        'role': 'student',
        'first_name': firstName,
        'last_name': lastName ?? '',
        'username': username ?? '',
        'patronymic': patronymic ?? '',
        'phone_number': phoneNumber ?? '',
        'gender': gender,
        'avatarUrl': null,
      },
    };
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // No-op for mock
  }

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Return new tokens (simulate refresh)
    return {
      'accessToken': 'mock_at_refreshed_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'mock_rt_refreshed_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // Helper: simple capitalization
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
