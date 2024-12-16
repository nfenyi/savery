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
      'high_importance_channel', 'High-Importance Notifications',
      description: 'This channel is used for important notifications.',
      //this is the default but calling it anyways for learning purposes
      importance: Importance.high);
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await initLocalNotifications();
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
      // final notificationsBox =
      //     Hive.box<AppNotification>(AppBoxes.notifications);
      //  if (!notificationsBox.isOpen){

      //  }
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                  _androidChannel.id, _androidChannel.name,
                  channelDescription: _androidChannel.description,
                  icon: '@drawable/ic_stat_app_logo')),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_stat_app_logo');
    const settings = InitializationSettings(android: android, iOS: iOS);

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
  try {
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
    await notificationsBox.add(newNotification);
    if (user == null) {
      return;
    }

    HiveList<AppNotification>? userNotifications = user.notifications;
    userNotifications ??= HiveList(notificationsBox);
    userNotifications.add(newNotification);
    final boxNotifications = notificationsBox.values.toList();
    boxNotifications.removeLast();
    //Seems to remove notifications stored in a user
    // await notificationsBox.clear();
    // await notificationsBox.addAll(boxNotifications);

    await user.save();
    if (Hive.box(AppBoxes.appState).get('authenticated')) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ));
    }
  } on Exception catch (e) {
    throw Exception(e);
  }

  // logger.d('hello world');
}

Future<void> handleNotificationResponse(
    NotificationResponse notificationResponse) async {
  final message =
      RemoteMessage.fromMap(jsonDecode(notificationResponse.payload ?? ""));
  await handleMessage(message);
}
