import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';

Stream<List<Account>> accountsStream() {
  final Box<AppUser> userBox = Hive.box<AppUser>(AppBoxes.user);

  late final StreamController<List<Account>> controller;
  late final StreamSubscription sub;

  void startStream() {
    controller.add(userBox.values.first.accounts?.toList() ?? []);
    sub = userBox.watch().listen(
      (event) {
        controller.add(userBox.values.first.accounts!.toList());
      },
    );
  }

  controller = StreamController<List<Account>>.broadcast(
    onListen: startStream,
    onCancel: () {
      sub.cancel;
    },
  );
  return controller.stream;
}

Stream<List<AccountTransaction>> transactionsStream(String? selectedAccount) {
  final Box<AppUser> userBox = Hive.box(AppBoxes.user);

  late final StreamController<List<AccountTransaction>> controller;
  late final StreamSubscription sub;

  void startStream() {
    controller.add(userBox.values.first.accounts
            ?.firstWhere((element) => element.name == selectedAccount)
            .transactions
            ?.toList() ??
        []);
    sub = userBox.watch().listen(
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
    onCancel: () {
      sub.cancel;
    },
  );
  return controller.stream;
}

Stream<List<Budget>> budgetStream(
    {required String? selectedAccount, required BudgetType type}) {
  final accountsBox = Hive.box<Account>(AppBoxes.accounts);
  final budgetsBox = Hive.box<Budget>(AppBoxes.budgets);
  late final StreamController<List<Budget>> controller;
  late final StreamSubscription sub;

  void startStream() {
    controller.add(accountsBox.values
            .firstWhere((element) => element.name == selectedAccount)
            .budgets
            ?.where(
              (element) => element.type == type,
            )
            .toList() ??
        []);
    sub = budgetsBox.watch().listen(
      (event) {
        controller.add(accountsBox.values
                .firstWhere((element) => element.name == selectedAccount)
                .budgets
                ?.where(
                  (element) => element.type == type,
                )
                .toList() ??
            []);
      },
    );
  }

  controller = StreamController<List<Budget>>.broadcast(
    onListen: startStream,
    onCancel: () {
      sub.cancel;
    },
  );
  return controller.stream;
}
