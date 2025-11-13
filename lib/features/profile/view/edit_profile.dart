import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lost_n_found/shared/widgets/CustomTextField.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../controller/edit_profile_controller.dart';
import 'package:go_router/go_router.dart';

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
      context.pop(); // back to Profile using go_router
    } else if (_controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Avatar Section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.person, size: 55, color: Colors.white),
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
                          icon: const Icon(Icons.edit,
                              size: 18, color: Colors.black),
                          onPressed: () {
                            // TODO: add image picker later
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // First name
                CustomTextField(
                  label: "First Name",
                  controller: _controller.firstNameController,
                ),
                const SizedBox(height: 16),

                // Last name
                CustomTextField(
                  label: "Last Name",
                  controller: _controller.lastNameController,
                ),
                const SizedBox(height: 16),

                // Patronymic
                CustomTextField(
                  label: "Patronymic (optional)",
                  controller: _controller.patronymicController,
                ),
                const SizedBox(height: 16),

                // Phone
                CustomTextField(
                  label: "Phone Number",
                  controller: _controller.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  label: "Email",
                  controller: _controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Username
                CustomTextField(
                  label: "Username",
                  controller: _controller.usernameController,
                ),
                const SizedBox(height: 16),

                // Gender dropdown (similar to registration)
                DropdownButtonFormField<String>(
                  value: _controller.gender.isEmpty
                      ? null
                      : _controller.gender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (v) => _controller.setGender(v),
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
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
                      "SAVE CHANGES",
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
    );
  }
}