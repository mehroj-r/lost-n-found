abstract class IAuthRepository {
  Future<Map<String, String>> login(String email, String password);
  Future<void> logout();
}