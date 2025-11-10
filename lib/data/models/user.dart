class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String gender;
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.gender,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] as String,
    firstName: j['first_name'] as String? ?? '',
    lastName: j['last_name'] as String? ?? '',
    phoneNumber: j['phone_number'] as String? ?? '',
    email: j['email'] as String? ?? '',
    gender: j['gender'] as String? ?? '',
    avatarUrl: j['avatarUrl'] as String?,
  );
}
