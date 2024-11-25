import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';

import '../../notifiers/user_change_notifier.dart';
import '../models/user_model.dart';

final userProvider = ChangeNotifierProvider<UserNotifier>((ref) {
  return UserNotifier(Hive.box<AppUser>(AppBoxes.user));
});

final accountsProvider = Provider(
  (ref) => ref.watch(userProvider).user.accounts,
);

// final transactionsProvider = Provider(
//   (ref) => ref.watch(userProvider).user.acc,
// );
