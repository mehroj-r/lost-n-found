abstract class IAuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    String? phoneNumber,
    String? username,
    String? patronymic,
    required String gender,
  });

  Future<void> logout();
  Future<Map<String, dynamic>> refresh(String refreshToken);
  Future<bool> isLoggedIn();
}
