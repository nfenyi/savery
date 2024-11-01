import 'dart:collection';

import '../../constants/constants.dart';

class UserInfoModel extends MapView<String, String?> {
  final String userId;
  final String displayName;
  final String? email;

  UserInfoModel({
    required this.userId,
    required this.displayName,
    required this.email,
  }) : super({
          FirebaseFieldName.userId: userId,
          FirebaseFieldName.displayName: displayName,
          FirebaseFieldName.email: email,
        });

  UserInfoModel.fromJson(
    Map<String, dynamic> json, {
    required String userId,
  }) : this(
          userId: userId,
          displayName: json[FirebaseFieldName.displayName] ?? '',
          email: json[FirebaseFieldName.email],
        );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          displayName == other.displayName &&
          email == other.email;

  @override
  int get hashCode => Object.hashAll(
        [userId, displayName, email],
      );
}
