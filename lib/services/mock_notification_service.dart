// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/foundation.dart';
import 'package:housingapp/models/notification_item.dart';
import 'package:uuid/uuid.dart'; // For unique IDs

class MockNotificationService with ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  final Uuid _uuid = Uuid();

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(String title, String body) {
    final newNotification = NotificationItem(
      id: _uuid.v4(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, newNotification); // Add to the beginning
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Example of how to add mock notifications for testing
  void generateMockNotifications() {
    addNotification('Welcome!', 'Welcome to HousingApp! We hope you find your dream home.');
    addNotification('New Property Alert', 'A new apartment matching your rental preferences is available in Kampala!');
    addNotification('Match Score Updated', 'Your match score for "Luxury Villa, Kololo" has improved!');
  }
}