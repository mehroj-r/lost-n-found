import 'package:flutter/material.dart';
import 'package:lost_n_found/data/models/user.dart';

class ProfilePage extends StatelessWidget {
  final AppUser user = AppUser(
    id: 1,
    firstName: "John",
    lastName: "Doe",
    username: "johndoe",
    email: "john@example.com",
    avatarUrl: "",
    phoneNumber: '+998901234567',
    gender: 'male',
  );

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // pink background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Profile Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Profile image with fallback
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? Image.network(
                        user.avatarUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _initialsOrAsset(),
                      )
                          : _initialsOrAsset(),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Name + Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user.firstName} ${user.lastName}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit icon
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {},
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView(
                children: [
                  menuItem(Icons.list_alt, "My posts", () {}),
                  menuItem(Icons.bookmark_added_outlined, "My claimed items", () {}),
                  menuItem(Icons.location_on_outlined, "My Address", () {}),
                  menuItem(Icons.settings_outlined, "Settings", () {}),
                  menuItem(Icons.logout, "Sign out", () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Returns initials widget or asset image as fallback
  Widget _initialsOrAsset() {
    if (user.firstName.isNotEmpty || user.lastName.isNotEmpty) {
      return Center(
        child: Text(
          "${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    } else {
      return Image.asset(
        "assets/default_avatar.png",
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      );
    }
  }

  Widget menuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[800]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
