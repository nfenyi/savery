import 'package:hive_flutter/hive_flutter.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 7, adapterName: 'NotificationAdapter')
class AppNotification extends HiveObject {
  @HiveField(0)
  final String? title;
  @HiveField(1)
  final String? body;
  @HiveField(2)
  final Map data;
  @HiveField(3)
  final DateTime? sentTime;

  AppNotification(
      {required this.title,
      required this.body,
      required this.data,
      required this.sentTime});
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      title: json['title'],
      body: json['body'],
      data: json['data'] ?? {},
      sentTime: json['sentTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'sentTime': sentTime,
    };
  }
}
