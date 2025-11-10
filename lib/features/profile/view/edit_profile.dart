import 'package:flutter/material.dart';
import 'package:lost_n_found/shared/widgets/CustomTextField.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.black),
                      onPressed: () {
                        // Add image picker later
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Input Fields
            const CustomTextField(label: "Name", initialValue: "Toshmat"),
            const SizedBox(height: 16),
            const CustomTextField(label: "Email", initialValue: "toshmat@email.com"),
            const SizedBox(height: 16),
            const CustomTextField(
              label: "Phone Number",
              initialValue: "+998 97 907 97 07",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const CustomTextField(label: "Location", initialValue: "Uzbekistan"),

            const SizedBox(height: 36),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Add save functionality later
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "SAVE CHANGES",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}