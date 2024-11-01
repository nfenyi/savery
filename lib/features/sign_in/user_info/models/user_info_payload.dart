import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../../constants/constants.dart';

@immutable
class UserInfoPayload extends MapView<String, String> {
  UserInfoPayload({
    required String userId,
    required String? displayName,
    required String? email,
  }) : super({
          FirebaseFieldName.userId: userId,
          FirebaseFieldName.displayName: displayName ?? "",
          FirebaseFieldName.email: email ?? "",
        });
}
