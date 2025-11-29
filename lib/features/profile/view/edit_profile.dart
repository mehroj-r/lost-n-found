import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      context.pop(); // back to Profile
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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                24 + bottomInset, // ensure button is above nav bar
              ),
              child: Column(
                children: [
                  // Avatar Section
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFFE0E0E0),
                        child: ClipOval(
                          child: _buildAvatarChild(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: _controller.isUploadingAvatar
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(
                              Icons.camera_alt, // changed icon
                              size: 18,
                              color: Colors.black,
                            ),
                            onPressed: _controller.isUploadingAvatar
                                ? null
                                : () => _controller.pickAndUploadAvatar(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // First name
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: CustomTextField(
                        label: 'First Name',
                        controller: _controller.firstNameController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Last name
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: CustomTextField(
                        label: 'Last Name',
                        controller: _controller.lastNameController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Patronymic
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: CustomTextField(
                        label: 'Patronymic',
                        controller: _controller.patronymicController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: CustomTextField(
                        label: 'Phone Number',
                        controller: _controller.phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email (added / editable)
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: CustomTextField(
                        label: 'Email',
                        controller: _controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Username
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: CustomTextField(
                        label: 'Username',
                        controller: _controller.usernameController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bio
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: CustomTextField(
                        label: 'Bio',
                        controller: _controller.bioController,
                        maxLines: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Gender dropdown
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _controller.gender.isEmpty
                            ? null
                            : _controller.gender,
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Female'),
                          ),
                        ],
                        onChanged: (v) => _controller.setGender(v),
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _controller.isSaving ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _controller.isSaving
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}