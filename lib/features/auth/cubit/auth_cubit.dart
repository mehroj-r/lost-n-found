import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/mock_auth_repository.dart';

class AuthState {
  final bool loading;
  final AppUser? user;
  final String? error;
  const AuthState({this.loading=false, this.user, this.error});
  AuthState copyWith({bool? loading, AppUser? user, String? error}) =>
      AuthState(loading: loading ?? this.loading, user: user ?? this.user, error: error);
}

class AuthCubit extends Cubit<AuthState> {
  final MockAuthRepository repo;
  AuthCubit(this.repo): super(const AuthState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final r = await repo.login(email, password);
      final u = AppUser.fromJson(r['user']);
      emit(AuthState(user: u));
    } catch (e) {
      emit(AuthState(error: e.toString()));
    }
  }

  Future<void> logout() async {
    await repo.logout();
    emit(const AuthState());
  }
}
