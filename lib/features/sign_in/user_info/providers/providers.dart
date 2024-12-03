import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';

import '../../notifiers/user_change_notifier.dart';
import '../models/user_model.dart';

final userProvider = ChangeNotifierProvider<UserNotifier>((ref) {
  return UserNotifier();
});

final accountsProvider = Provider(
  (ref) => ref
      .watch(userProvider)
      .user(Hive.box(AppBoxes.appState).get('currentUser'))
      .accounts,
);

// final transactionsProvider = Provider(
//   (ref) => ref.watch(userProvider).user.acc,
// );
