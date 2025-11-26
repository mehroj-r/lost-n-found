import 'package:get_it/get_it.dart';
import 'service_locator.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/file_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/chat_repository.dart';

final GetIt getIt = GetIt.instance;

void setupDependencyInjection() {
  final serviceLocator = ServiceLocator();
  
  // Register repositories
  getIt.registerLazySingleton<IUserRepository>(() => serviceLocator.userRepository);
  getIt.registerLazySingleton<IAuthRepository>(() => serviceLocator.authRepository);
  getIt.registerLazySingleton<IPostRepository>(() => serviceLocator.postRepository);
  getIt.registerLazySingleton<IFileRepository>(() => serviceLocator.fileRepository);
  getIt.registerLazySingleton<INotificationRepository>(() => serviceLocator.notificationRepository);
  getIt.registerLazySingleton<ChatRepository>(() => serviceLocator.chatRepository);
}