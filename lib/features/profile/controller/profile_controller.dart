import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../data/models/user.dart';
import '../../../features/auth/cubit/auth_cubit.dart';

class ProfileController extends ChangeNotifier {
  final AuthCubit _authCubit;
  late final StreamSubscription<AuthState> _sub;

  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  ProfileController(this._authCubit) {
    final s = _authCubit.state;
    _user = s.user;
    _isLoading = s.initializing || s.loading;
    _error = s.error;

    _sub = _authCubit.stream.listen((state) {
      _user = state.user;
      _isLoading = state.initializing || state.loading;
      _error = state.error;
      notifyListeners();
    });
  }

  // Getters
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Refresh profile data
  Future<void> refresh() async {
    _error = null;
    notifyListeners();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authCubit.logout();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
