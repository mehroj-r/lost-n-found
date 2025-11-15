import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StreamController<void> _notificationUpdateController = StreamController<void>.broadcast();
  
  Stream<void> get notificationUpdates => _notificationUpdateController.stream;
  
  void notifyNotificationUpdate() {
    _notificationUpdateController.add(null);
  }
  
  void dispose() {
    _notificationUpdateController.close();
  }
}