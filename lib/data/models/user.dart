import 'photo.dart';

class AppUser {
  final int id;
  final String firstName;
  final String lastName;
  final String? patronymic;
  final String phoneNumber;
  final String email;
  final String username;
  final String gender;
  final String? avatarUrl; // final URL to display
  final Photo? avatar;     // optional full object, if backend ever sends it
  final String? bio;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.patronymic,
    required this.phoneNumber,
    required this.email,
    required this.username,
    required this.gender,
    this.avatarUrl,
    this.avatar,
    this.bio,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) {
    // avatar can be either a String (URL) or a Map (Photo object)
    final dynamic avatarRaw = j['avatar'];
    String? avatarUrl;
    Photo? avatarPhoto;

    if (avatarRaw is String) {
      // backend returns direct URL string
      avatarUrl = avatarRaw;
    } else if (avatarRaw is Map<String, dynamic>) {
      avatarPhoto = Photo.fromJson(avatarRaw);
      avatarUrl = avatarPhoto.url;
    }

    // If there is an explicit avatar_url field, prefer that
    avatarUrl = j['avatar_url'] as String? ?? avatarUrl;

    return AppUser(
      id: j['id'] ?? 0,
      firstName: j['first_name'] as String? ?? '',
      lastName: j['last_name'] as String? ?? '',
      patronymic: j['patronymic'] as String?,
      phoneNumber: j['phone'] as String? ?? '',
      email: j['email'] as String? ?? '',
      username: j['username'] as String? ?? '',
      gender: j['gender'] as String? ?? '',
      bio: j['bio'] as String?,
      avatarUrl: avatarUrl,
      avatar: avatarPhoto,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'patronymic': patronymic,
    'phone': phoneNumber,
    'email': email,
    'username': username,
    'gender': gender,
    'bio': bio,
    // no avatar/avatarUrl here; controller sends avatar id explicitly
  };
}