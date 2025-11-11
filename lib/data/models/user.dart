class AppUser {
  final int id;
  final String firstName;
  final String lastName;
  final String? patronymic;
  final String phoneNumber;
  final String email;
  final String username;
  final String gender;
  final String? avatarUrl;

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
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] ?? 0,
    firstName: j['first_name'] as String? ?? '',
    lastName: j['last_name'] as String? ?? '',
    patronymic: j['patronymic'] as String?,
    phoneNumber: j['phone'] as String? ?? '',
    email: j['email'] as String? ?? '',
    username: j['username'] as String? ?? '',
    gender: j['gender'] as String? ?? '',
    avatarUrl: j['avatarUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'patronymic': patronymic,
    'phone': phoneNumber,
    'email': email,
    'username': username,
    'gender': gender,
    'avatarUrl': avatarUrl,
  };
}
