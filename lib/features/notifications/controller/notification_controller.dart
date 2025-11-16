import 'package:flutter/foundation.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/notification.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  final INotificationRepository _repository = ServiceLocator().notificationRepository;
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _notifications = await _repository.getNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
        
        // Notify the notification service about the update
        NotificationService().notifyUpdate();
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
      
      // Notify the notification service about the update
      NotificationService().notifyUpdate();
    } catch (e) {
      _error = 'Failed to mark all notifications as read: $e';
      notifyListeners();
    }
  }
  
  Future<void> refresh() async {
    await fetchNotifications();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}