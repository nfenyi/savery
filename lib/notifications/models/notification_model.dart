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

  AppNotification(
      {required this.title, required this.body, required this.data});
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      title: json['title'],
      body: json['body'],
      data: json['data'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'data': data,
    };
  }
}
