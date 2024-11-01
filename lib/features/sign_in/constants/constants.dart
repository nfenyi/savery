import 'package:flutter/foundation.dart';

@immutable
class Constants {
  static const accountExistsWithDifferentCredential =
      'account-exists-with-different-credential';
  static const googleCom = 'google.com';
  static const emailScope = 'email';
  const Constants._();
}

@immutable
class FirebaseFieldName {
  static const userId = 'uid';
  static const createdAt = 'created_at';
  static const postId = 'post_id';
  static const comment = 'comment';
  static const displayName = 'display_name';
  static const email = 'email';
  static const date = 'date';

  const FirebaseFieldName._();
}
