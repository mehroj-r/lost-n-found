import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart'; // if needed for IUserRepository
import '../../auth/cubit/auth_cubit.dart';

class EditProfileController extends ChangeNotifier {
  final AuthCubit _authCubit;
  final IUserRepository _userRepo = ServiceLocator().userRepository;

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController patronymicController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController usernameController;

  String _gender = '';
  bool _isSaving = false;
  String? _error;

  bool get isSaving => _isSaving;
  String? get error => _error;
  String get gender => _gender;

  AppUser? get currentUser => _authCubit.state.user;

  EditProfileController(this._authCubit) {
    final user = currentUser;

    firstNameController = TextEditingController(text: user?.firstName ?? '');
    lastNameController = TextEditingController(text: user?.lastName ?? '');
    patronymicController = TextEditingController(text: user?.patronymic ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    _gender = user?.gender ?? '';
  }

  void setGender(String? value) {
    _gender = value ?? '';
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    final user = currentUser;
    if (user == null) {
      _error = 'No user to update';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated = AppUser(
        id: user.id,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        patronymic: patronymicController.text.trim().isEmpty
            ? null
            : patronymicController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        gender: _gender,
        avatarUrl: user.avatarUrl,
      );

      // Send proper payload to backend
      final savedUser = await _userRepo.updateProfile(updated.toJson());

      // Update AuthCubit so ProfilePage sees new user immediately
      _authCubit.emit(
        _authCubit.state.copyWith(
          user: savedUser,
          loading: false,
          error: null,
          registrationSuccess: false,
          initializing: false,
        ),
      );

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _error = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('EditProfileController.saveChanges error: $e');
      }
      return false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    patronymicController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}