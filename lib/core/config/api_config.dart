class ApiConfig {
  // Base URL for the API
  static const String baseUrl = 'https://findly.mekhroj.uz/api/v1';
  
  // Timeouts in milliseconds
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  // Auth Endpoints
  static const String authLogin = '/auth/login/';
  static const String authRegister = '/auth/register/';
  static const String authLogout = '/auth/logout/';
  static const String authRefresh = '/auth/refresh/';
  static const String userProfile = '/users/profile/';
  
  // Post Endpoints
  static const String posts = '/posts/';
  static const String postsCreate = '/posts/';
  static const String postsUpdate = '/posts/'; // + {id}/
  static const String postsDelete = '/posts/'; // + {id}/
  static const String postsDetail = '/posts/'; // + {id}/
  static const String postsLike = '/posts/'; // + {id}/likes/
  
  // File Endpoints
  static const String files = '/files/';

  // User Endpoints
  static const String users = '/users/';
  static const String userDetail = '/users/'; // + {id}/
  
  // Environment
  static bool get isDevelopment => const bool.fromEnvironment('dart.vm.product') == false;
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
}
