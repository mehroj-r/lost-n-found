import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthState {
  final bool loading;
  final AppUser? user;
  final String? error;
  const AuthState({this.loading = false, this.user, this.error});
  AuthState copyWith({bool? loading, AppUser? user, String? error}) =>
      AuthState(loading: loading ?? this.loading, user: user ?? this.user, error: error);
}

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository repo;
  AuthCubit(this.repo) : super(const AuthState());

  // Helper: convert backend user map into AppUser (defensive, handles different shapes)
  AppUser _userFromMap(Map<String, dynamic> u) {
    // prefer explicit fields when present
    final id = (u['id'] ?? u['userId'] ?? '').toString();
    final email = (u['email'] ?? '').toString();
    final avatar = (u['avatarUrl'] ?? u['avatar'] ?? u['avatar_url']) as String?;
    final phone = (u['phone_number'] ?? u['phone'] ?? '').toString();
    final gender = (u['gender'] ?? '').toString();

    // If backend returns first_name/last_name use them, otherwise try to build from fullName
    String firstName = '';
    String lastName = '';
    if (u.containsKey('first_name') || u.containsKey('last_name')) {
      firstName = (u['first_name'] ?? '').toString();
      lastName = (u['last_name'] ?? '').toString();
    } else if (u.containsKey('fullName')) {
      final full = (u['fullName'] ?? '').toString();
      final parts = full.split(' ');
      if (parts.isNotEmpty) firstName = parts.first;
      if (parts.length > 1) lastName = parts.sublist(1).join(' ');
    } else if (u.containsKey('full_name')) {
      final full = (u['full_name'] ?? '').toString();
      final parts = full.split(' ');
      if (parts.isNotEmpty) firstName = parts.first;
      if (parts.length > 1) lastName = parts.sublist(1).join(' ');
    }

    return AppUser(
      id: id.isNotEmpty ? id : DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phone,
      email: email,
      gender: gender,
      avatarUrl: avatar,
    );
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      // Login and save tokens
      await repo.login(email, password);
      
      // Try to fetch user profile after successful login
      try {
        final user = await ServiceLocator().userRepository.getCurrentUser();
        emit(AuthState(user: user));
      } catch (profileError) {
        // If profile fetch fails, create minimal user from email
        final userData = {
          'email': email,
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
        };
        final u = _userFromMap(userData);
        emit(AuthState(user: u));
      }
    } on ApiException catch (e) {
      emit(AuthState(error: e.message));
    } catch (e) {
      emit(AuthState(error: e.toString()));
    }
  }

  Future<void> register({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    String? phoneNumber,
    String? username,
    String? patronymic,
    required String gender,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      // Register and save tokens
      await repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        username: username,
        patronymic: patronymic,
        gender: gender,
      );

      // Try to fetch user profile after successful registration
      try {
        final user = await ServiceLocator().userRepository.getCurrentUser();
        emit(AuthState(user: user));
      } catch (profileError) {
        // If profile fetch fails, create from registration info
        final userData = {
          'email': email,
          'first_name': firstName,
          'last_name': lastName ?? '',
          'username': username,
          'patronymic': patronymic,
          'gender': gender,
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
        };
        final u = _userFromMap(userData);
        emit(AuthState(user: u));
      }
    } on ApiException catch (e) {
      emit(AuthState(error: e.message));
    } catch (e) {
      emit(AuthState(error: e.toString()));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repo.logout();
    } catch (_) {
    } finally {
      emit(const AuthState());
    }
  }
}
