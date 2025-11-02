class AppUser {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final String? avatarUrl;
  AppUser({required this.id, required this.email, required this.role, required this.fullName, this.avatarUrl});
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
      id: j['id'], email: j['email'], role: j['role'], fullName: j['fullName'], avatarUrl: j['avatarUrl']
  );
}
