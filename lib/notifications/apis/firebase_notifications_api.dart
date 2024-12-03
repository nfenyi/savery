import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';
import 'package:savery/notifications/models/notification_model.dart';
import 'package:get/get_utils/get_utils.dart';

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
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final String? fcmToken = await _firebaseMessaging.getToken();
    logger.d(fcmToken);
    await Hive.box(AppBoxes.appState).put('fcmToken', fcmToken);
    await _firebaseMessaging.getInitialMessage().then(handleMessage);
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
                  icon: 'ic_stat_app_logo')),
          payload: jsonEncode(message.toMap()));
    });
    //doesn''t work because the box is paused when the app is suspended
    // FirebaseMessaging.onBackgroundMessage(handleMessage);
    await initLocalNotifications();
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('ic_stat_app_logo');
    const settings = InitializationSettings(android: android, iOS: iOS);

    // await _localNotifications.initialize(settings,
    //     onSelectNotification: (payload) {
    //   final message = RemoteMessage.fromMap(jsonDecode(payload!));
    //   handleMessage(message);
    // });

    //newer version
    await _localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: handleNotificationResponse);

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }
}

Future<void> handleMessage(RemoteMessage? message) async {
  if (message == null) return;
  final appStateUid = Hive.box(AppBoxes.appState).get('currentUser');
  final notificationsBox = Hive.box<AppNotification>(AppBoxes.notifications);
  final newNotification = AppNotification(
      title: message.notification?.title,
      body: message.notification?.body,
      sentTime: message.sentTime,
      data: message.data);

  AppUser? user =
      Hive.box<AppUser>(AppBoxes.users).values.toList().firstWhereOrNull(
            (element) => element.uid == appStateUid,
          );
  if (user == null) {
    await notificationsBox.add(newNotification);
    return;
  }

  HiveList<AppNotification>? userNotifications = user.notifications;
  if (userNotifications != null) {
    userNotifications.add(AppNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        sentTime: message.sentTime,
        data: message.data));
  } else {
    userNotifications = HiveList(notificationsBox, objects: [
      //in case some general messages came in while  the user was signed out, meaning these messages are for everyone
      ...notificationsBox.values, newNotification
    ]);
  }
  await user.save();
  if (Hive.box(AppBoxes.appState).get('authenticated')) {
    navigatorKey.currentState!.push(MaterialPageRoute(
      builder: (context) => const NotificationsScreen(),
    ));
  }

  // logger.d('hello world');
}

Future<void> handleNotificationResponse(
    NotificationResponse notificationResponse) async {
  final message =
      RemoteMessage.fromMap(jsonDecode(notificationResponse.payload ?? ""));
  await handleMessage(message);
}
