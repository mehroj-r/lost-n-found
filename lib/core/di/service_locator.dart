import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/repositories/api_auth_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/file_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../config/api_config.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final FlutterSecureStorage _secureStorage;
  late final Connectivity _connectivity;
  late final INetworkInfo _networkInfo;
  late final DioClient _dioClient;
  late final IAuthRepository _authRepository;
  late final IPostRepository _postRepository;
  late final IUserRepository _userRepository;
  late final IFileRepository _fileRepository;
  late final INotificationRepository _notificationRepository;
  late final ChatRepository _chatRepository;
  Function()? _onUnauthorized; // Store logout callback

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize secure storage with error handling
      _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

      // Initialize connectivity
      _connectivity = Connectivity();
      _networkInfo = NetworkInfo(_connectivity);

      // Initialize Dio client
      _dioClient = DioClient(
        baseUrl: ApiConfig.baseUrl,
        networkInfo: _networkInfo,
        secureStorage: _secureStorage,
        onTokenRefresh: _refreshToken,
        onUnauthorized: () => _onUnauthorized?.call(), // Use stored callback
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
      );

      // Initialize repositories
      _authRepository = ApiAuthRepository(
        dioClient: _dioClient,
        secureStorage: _secureStorage,
      );

      _postRepository = PostRepository(dioClient: _dioClient);
      _userRepository = UserRepository(dioClient: _dioClient);
      _fileRepository = FileRepository(dioClient: _dioClient);
      _notificationRepository = ApiNotificationRepository(_dioClient.dio);
      _chatRepository = ApiChatRepository(_dioClient);

      _isInitialized = true;
    } catch (e) {
      // Reset initialization flag on error
      _isInitialized = false;
      rethrow;
    }
  }

  // Token refresh callback
  Future<void> _refreshToken(String refreshToken) async {
    final tokens = await _authRepository.refresh(refreshToken);

    if (tokens.containsKey('accessToken')) {
      await _secureStorage.write(
        key: 'access_token',
        value: tokens['accessToken'],
      );
    }
    if (tokens.containsKey('refreshToken')) {
      await _secureStorage.write(
        key: 'refresh_token',
        value: tokens['refreshToken'],
      );
    }
  }

  // Getters
  FlutterSecureStorage get secureStorage {
    _ensureInitialized();
    return _secureStorage;
  }

  INetworkInfo get networkInfo {
    _ensureInitialized();
    return _networkInfo;
  }

  DioClient get dioClient {
    _ensureInitialized();
    return _dioClient;
  }

  IAuthRepository get authRepository {
    _ensureInitialized();
    return _authRepository;
  }

  IPostRepository get postRepository {
    _ensureInitialized();
    return _postRepository;
  }

  IUserRepository get userRepository {
    _ensureInitialized();
    return _userRepository;
  }

  IFileRepository get fileRepository {
    _ensureInitialized();
    return _fileRepository;
  }

  INotificationRepository get notificationRepository {
    _ensureInitialized();
    return _notificationRepository;
  }

  ChatRepository get chatRepository {
    _ensureInitialized();
    return _chatRepository;
  }

  // Method to set logout callback from AuthCubit
  void setUnauthorizedCallback(Function() callback) {
    _onUnauthorized = callback;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
  }

  // Reset (useful for testing or logout)
  Future<void> reset() async {
    _isInitialized = false;
    await init();
  }
}
