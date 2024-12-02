import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/notifications/models/notification_model.dart';

import '../../app_constants/app_constants.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications =
        Hive.box<AppNotification>(AppBoxes.notifications).values.toList();
    return Scaffold(
        appBar: AppBar(
          title: const AppText(text: 'Notifications'),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return ListTile(
              title: AppText(text: notification.title ?? '⚠️'),
              subtitle: AppText(
                text: notification.body ?? '',
                maxLines: 2,
              ),
              isThreeLine: true,
            );
          },
          itemCount: notifications.length,
        ));
  }
}
