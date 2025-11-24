import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../auth/cubit/auth_cubit.dart';

class EditProfileController extends ChangeNotifier {
  final AuthCubit _authCubit;
  final IUserRepository _userRepo = ServiceLocator().userRepository;
  final ImagePicker _picker = ImagePicker();

  // Text controllers
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController patronymicController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController usernameController;
  late final TextEditingController bioController;

  // Gender
  String _gender = '';

  // Avatar
  String? _avatarId;      // uploaded file id as string (from /files/)
  String? _avatarPreview; // URL or local path for UI preview
  bool _isUploadingAvatar = false;

  // State
  bool _isSaving = false;
  String? _error;

  // Getters
  bool get isSaving => _isSaving;
  String? get error => _error;
  String get gender => _gender;

  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get avatarPreview => _avatarPreview;

  AppUser? get currentUser => _authCubit.state.user;

  EditProfileController(this._authCubit) {
    final user = currentUser;

    firstNameController = TextEditingController(text: user?.firstName ?? '');
    lastNameController = TextEditingController(text: user?.lastName ?? '');
    patronymicController = TextEditingController(text: user?.patronymic ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
    _gender = user?.gender ?? '';

    // initial avatar preview from backend
    _avatarPreview = user?.avatarUrl;
  }

  void setGender(String? value) {
    _gender = value ?? '';
    notifyListeners();
  }

  /// Pick image from gallery, upload to /files/, store new id and show preview.
  Future<void> pickAndUploadAvatar() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return; // user cancelled

      _isUploadingAvatar = true;
      notifyListeners();

      final file = File(picked.path);

      // Upload file and get file id from backend
      final id = await _userRepo.uploadAvatar(file);

      _avatarId = id;
      _avatarPreview = picked.path; // local preview

      if (kDebugMode) {
        print('New avatar uploaded, id=$_avatarId, preview=$_avatarPreview');
      }
    } catch (e, st) {
      _error = 'Avatar upload failed: $e';
      if (kDebugMode) {
        print('pickAndUploadAvatar error: $e');
        print(st);
      }
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }

  /// Save profile changes. Avatar rules:
  /// - If _avatarId is set: send it as "avatar" (new avatar for this session).
  /// - Else if user already has avatarUrl: do NOT send avatar field; backend keeps existing.
  /// - Else (no avatar at all): require upload once.
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
      final Map<String, dynamic> data = {
        'phone': phoneController.text.trim(),
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'patronymic': patronymicController.text.trim().isEmpty
            ? null
            : patronymicController.text.trim(),
        'gender': _gender,
        'bio': bioController.text.trim().isEmpty
            ? null
            : bioController.text.trim(),
      };

      // Decide whether to include avatar
      if (_avatarId != null) {
        // New avatar uploaded in this session
        final avatarId = int.tryParse(_avatarId!);
        if (avatarId == null) {
          _isSaving = false;
          _error = 'Invalid avatar id from server.';
          notifyListeners();
          return false;
        }
        data['avatar'] = avatarId;
      } else {
        // No new avatar this session
        // If user has NO existing avatar URL, require upload
        final hasExistingAvatar =
            user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

        if (!hasExistingAvatar) {
          _isSaving = false;
          _error = 'Please upload an avatar before saving your profile.';
          notifyListeners();
          return false;
        }
        // Otherwise: do not include avatar field; backend will keep current avatar.
      }

      final savedUser = await _userRepo.updateProfile(data);

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
    } catch (e, st) {
      _isSaving = false;
      _error = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('EditProfileController.saveChanges error: $e');
        print(st);
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
    bioController.dispose();
    super.dispose();
  }
}