import 'package:dio/dio.dart';
import '../models/notification.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markNotificationAsRead(int notificationId);
  Future<void> markAllNotificationsAsRead();
  Future<int> getUnreadCount();
}

class ApiNotificationRepository implements INotificationRepository {
  final Dio _dio;

  ApiNotificationRepository(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List notificationsList = data['data'];
          return notificationsList
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load notifications');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _dio.post('/notifications/$notificationId/read/');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await _dio.post('/notifications/read-all/');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data']['unread_count'] ?? 0;
        } else {
          throw Exception(data['message'] ?? 'Failed to get unread count');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}