import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/main.dart';
import 'package:savery/notifications/models/notification_model.dart';

import '../presentation/notifications_screen.dart';

class FirebaseNotificationsApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      //this is the default but calling it anyways for learning purposes
      importance: Importance.defaultImportance);
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    //   // You may set the permission requests to "provisional" which allows the user to choose what type
// // of notifications they would like to receive once the user receives a notification.
// final notificationSettings =
    await FirebaseMessaging.instance.requestPermission(

//   // provisional: true
        );
    // // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
// final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
// if (apnsToken != null) {
//  // APNS token is available, make FCM plugin API requests...
// }
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final String? fcmToken = await _firebaseMessaging.getToken();
    logger.d(fcmToken);
    await Hive.box(AppBoxes.appState).put('fcmToken', fcmToken);
    await FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                  _androidChannel.id, _androidChannel.name,
                  channelDescription: _androidChannel.description,
                  icon: '@drawable-xxxhdpi/ic_stat_app_logo')),
          payload: jsonEncode(message.toMap()));
    });
    //doesn''t work because the box is paused when the app is suspended
    // FirebaseMessaging.onBackgroundMessage(handleMessage);
    await initLocalNotifications();
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android =
        AndroidInitializationSettings('@drawable-xxxhdpi/ic_stat_app_logo');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload.toString()));
      handleMessage(message);
    }, onDidReceiveBackgroundNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload.toString()));
      handleMessage(message);
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }
}

Future<void> handleMessage(RemoteMessage? message) async {
  if (message == null) return;
  await Hive.box<AppNotification>(AppBoxes.notifications).add(AppNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data));
  navigatorKey.currentState!.push(MaterialPageRoute(
    builder: (context) => const NotificationsScreen(),
  ));

  logger.d('hello world');
}
