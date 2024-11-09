import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';

Stream<List<Account>> accountsStream() {
  final Box<AppUser> userBox = Hive.box<AppUser>(AppBoxes.user);

  late final StreamController<List<Account>> controller;

  void startStream() {
    controller.add(userBox.values.first.accounts?.toList() ?? []);
    userBox.watch().listen(
      (event) {
        controller.add(userBox.values.first.accounts!.toList());
      },
    );
  }

  controller = StreamController<List<Account>>.broadcast(
    onListen: startStream,
  );
  return controller.stream;
}

Stream<List<AccountTransaction>> transactionsStream(String? selectedAccount) {
  final Box<AppUser> userBox = Hive.box(AppBoxes.user);

  late final StreamController<List<AccountTransaction>> controller;

  void startStream() {
    controller.add(userBox.values.first.accounts
            ?.toList()
            .firstWhere((element) => element.name == selectedAccount)
            .transactions
            ?.toList() ??
        []);
    userBox.watch().listen(
      (event) {
        controller.add(userBox.values.first.accounts
                ?.toList()
                .firstWhere((element) => element.name == selectedAccount)
                .transactions
                ?.toList() ??
            []);
      },
    );
  }

  controller = StreamController<List<AccountTransaction>>.broadcast(
    onListen: startStream,
  );
  return controller.stream;
}
