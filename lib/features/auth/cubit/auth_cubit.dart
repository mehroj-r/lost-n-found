import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/mock_auth_repository.dart';

class AuthState {
  final bool loading;
  final AppUser? user;
  final String? error;
  const AuthState({this.loading = false, this.user, this.error});
  AuthState copyWith({bool? loading, AppUser? user, String? error}) =>
      AuthState(loading: loading ?? this.loading, user: user ?? this.user, error: error);
}

class AuthCubit extends Cubit<AuthState> {
  final MockAuthRepository repo;
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
      final r = await repo.login(email, password);
      final userMap = (r['user'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      final u = _userFromMap(userMap);
      emit(AuthState(user: u));
    } catch (e) {
      emit(AuthState(error: e.toString()));
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final r = await repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      final userMap = (r['user'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      final u = _userFromMap(userMap);
      emit(AuthState(user: u));
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
