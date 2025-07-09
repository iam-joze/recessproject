import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/services/mock_notification_service.dart';
import 'package:housingapp/models/notification_item.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<MockNotificationService>(
            builder: (context, notificationService, child) {
              if (notificationService.notifications.isEmpty) {
                return const SizedBox.shrink(); // Hide if no notifications
              }
              return TextButton(
                onPressed: () {
                  notificationService.markAllAsRead();
                },
                child: const Text(
                  'Mark All Read',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MockNotificationService>(
        builder: (context, notificationService, child) {
          if (notificationService.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No notifications yet.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You\'ll see updates here about new listings and activities.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: notificationService.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationService.notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  notificationService.removeNotification(notification.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notification "${notification.title}" dismissed')),
                  );
                },
                child: Card(
                  color: notification.isRead ? Colors.white : AppStyles.lightGrey.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(
                      notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: notification.isRead ? AppStyles.darkGrey : AppStyles.primaryColor,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        color: AppStyles.textColor,
                      ),
                    ),
                    subtitle: Text(
                      '${notification.body}\n${DateFormat('MMM dd, hh:mm a').format(notification.timestamp)}',
                      style: TextStyle(
                        color: AppStyles.darkGrey,
                        fontStyle: notification.isRead ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    onTap: () {
                      notificationService.markAsRead(notification.id);
                      // TODO: Navigate to relevant screen based on notification type in future
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Read: ${notification.title}')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}