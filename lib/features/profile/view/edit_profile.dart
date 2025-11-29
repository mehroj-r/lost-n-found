import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import 'package:lost_n_found/shared/widgets/CustomTextField.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../controller/edit_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late EditProfileController _controller;

  @override
  void initState() {
    super.initState();
    final authCubit = context.read<AuthCubit>();
    _controller = EditProfileController(authCubit);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final success = await _controller.saveChanges();
    if (!mounted) return;

    if (success) {
      context.go('/profile');
    } else if (_controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.error!)),
      );
    }
  }

  Widget _buildAvatarChild() {
    final preview = _controller.avatarPreview;

    if (preview != null && preview.isNotEmpty) {
      if (preview.startsWith('http://') || preview.startsWith('https://')) {
        // Existing avatar from backend
        return Image.network(
          preview,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.person, size: 55, color: Colors.white),
        );
      } else {
        // Local file path from picker
        return Image.file(
          File(preview),
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {

            return const Icon(Icons.person, size: 55, color: Colors.white);
          },
        );
      }
    }

    // No preview -> default icon
    return const Icon(Icons.person, size: 55, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          'Edit Profile',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppDimensions.allL,
                    child: Column(
                      children: [
                        SizedBox(height: AppDimensions.spaceL),
                        
                        _buildAvatarSection(),
                        
                        SizedBox(height: AppDimensions.spaceXxl),
                        
                        _buildFormSection(),
                        
                        SizedBox(height: AppDimensions.spaceXl),
                      ],
                    ),
                  ),
                ),
                
                _buildSaveButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: AppDimensions.allXl,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimensions.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Profile Photo',
            style: AppTypography.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.spaceL),
          
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary,
                  child: ClipOval(
                    child: _buildAvatarChild(),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: _controller.isUploadingAvatar
                          ? null
                          : () => _controller.pickAndUploadAvatar(),
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spaceM),
                        child: _controller.isUploadingAvatar
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppDimensions.spaceM),
          
          Text(
            'Tap to change photo',
            style: AppTypography.captionMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimensions.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: AppDimensions.allXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTypography.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.spaceXl),
          
          _buildTextField(
            label: 'First Name',
            controller: _controller.firstNameController,
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: AppDimensions.spaceL),
          
          _buildTextField(
            label: 'Last Name',
            controller: _controller.lastNameController,
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: AppDimensions.spaceL),
          
          _buildTextField(
            label: 'Patronymic',
            controller: _controller.patronymicController,
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: AppDimensions.spaceL),
          
          _buildTextField(
            label: 'Phone Number',
            controller: _controller.phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: AppDimensions.spaceL),
          
          _buildTextField(
            label: 'Email',
            controller: _controller.emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.backgroundTertiary,
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceL,
          vertical: AppDimensions.spaceM,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AppButton.primary(
          text: 'Save Changes',
          onPressed: _onSave,
          isLoading: _controller.isSaving,
          fullWidth: true,
        ),
      ),
    );
  }
}