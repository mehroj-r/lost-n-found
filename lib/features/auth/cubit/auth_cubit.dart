import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthState {
  final bool loading;
  final bool initializing;
  final bool registrationSuccess;
  final AppUser? user;
  final String? error;
  const AuthState({this.loading = false, this.initializing = true, this.registrationSuccess = false, this.user, this.error});
  AuthState copyWith({bool? loading, bool? initializing, bool? registrationSuccess, AppUser? user, String? error}) =>
      AuthState(
        loading: loading ?? this.loading, 
        initializing: initializing ?? this.initializing,
        registrationSuccess: registrationSuccess ?? this.registrationSuccess,
        user: user ?? this.user, 
        error: error
      );
}

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository repo;
  AuthCubit(this.repo) : super(const AuthState());

  /// Check if user is already authenticated on app startup
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await repo.isLoggedIn();
    if (isLoggedIn) {
      try {
        // Try to fetch user profile if logged in
        final user = await ServiceLocator().userRepository.getCurrentUser();
        emit(AuthState(user: user, initializing: false, registrationSuccess: false));
      } catch (e) {
        // If fetching profile fails, create a minimal user or logout
        await repo.logout();
        emit(const AuthState(initializing: false, registrationSuccess: false));
      }
    } else {
      emit(const AuthState(initializing: false, registrationSuccess: false));
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(loading: true, error: null, initializing: false, registrationSuccess: false));
    try {
      // Login and save tokens
      await repo.login(email, password);
      
      // Try to fetch user profile after successful login
      try {
        final user = await ServiceLocator().userRepository.getCurrentUser();
        emit(AuthState(user: user, loading: false, initializing: false, registrationSuccess: false));
      } catch (profileError) {
        // If profile fetch fails, logout and show error instead of creating minimal user
        try {
          await repo.logout();
        } catch (_) {}
        emit(AuthState(error: 'Login successful but failed to fetch profile. Please try again.', loading: false, initializing: false, registrationSuccess: false));
      }
    } on ApiException catch (e) {
      emit(AuthState(error: e.message, loading: false, initializing: false, registrationSuccess: false));
    } catch (e) {
      emit(AuthState(error: e.toString(), loading: false, initializing: false, registrationSuccess: false));
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
    emit(state.copyWith(loading: true, error: null, initializing: false, registrationSuccess: false));
    try {
      // Register but don't save tokens or log user in
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

      // Registration successful - set registrationSuccess flag
      emit(AuthState(loading: false, initializing: false, registrationSuccess: true));
    } on ApiException catch (e) {
      emit(AuthState(error: e.message, loading: false, initializing: false, registrationSuccess: false));
    } catch (e) {
      emit(AuthState(error: e.toString(), loading: false, initializing: false, registrationSuccess: false));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(loading: true, error: null, registrationSuccess: false));
    try {
      await repo.logout();
    } catch (_) {
    } finally {
      emit(const AuthState(initializing: false, registrationSuccess: false));
    }
  }
}
