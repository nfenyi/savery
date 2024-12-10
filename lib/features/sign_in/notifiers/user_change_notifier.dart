import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
// import 'package:get/get_utils/get_utils.dart';
import 'package:savery/main.dart';

class UserNotifier extends ChangeNotifier {
  final _accountsBox = Hive.box<Account>(AppBoxes.accounts);
  final _transactionsBox = Hive.box<AccountTransaction>(AppBoxes.transactions);
  final _goalsBox = Hive.box<Goal>(AppBoxes.goals);
  final _budgetBox = Hive.box<Budget>(AppBoxes.budgets);
  final _appStateUid = Hive.box(AppBoxes.appState).get('currentUser');
  final _userBox = Hive.box<AppUser>(AppBoxes.users);
  // final _user = Hive.box<AppUser>(AppBoxes.users).values.firstWhere((element) => element.uid == _appStateUid,);

  UserNotifier();

  AppUser user(String appStateUid) {
    return _userBox.values.firstWhere(
      (element) => element.uid == appStateUid,
    );
  }

  HiveList<AccountTransaction>? transactions(Account selectedAccount) =>
      user(_appStateUid)
          .accounts
          ?.firstWhere(
            (element) => element.name == selectedAccount.name,
          )
          .transactions;

  double savingsBucket(Account selectedAccount) => user(_appStateUid)
      .accounts!
      .firstWhere(
        (element) => element.name == selectedAccount.name,
      )
      .savingsBucket;

  HiveList<Goal>? goals(Account selectedAccount) => user(_appStateUid)
      .accounts!
      .firstWhere(
        (element) => element.name == selectedAccount.name,
      )
      .goals;
  Iterable<Budget>? expenseBudgets(Account selectedAccount) =>
      (user(_appStateUid)
          .accounts!
          .firstWhere(
            (element) => element.name == selectedAccount.name,
          )
          .budgets
          ?.where(
            (element) => element.type == BudgetType.expenseBudget,
          ));
  Iterable<Budget>? savings(Account selectedAccount) => (user(_appStateUid)
      .accounts!
      .firstWhere(
        (element) => element.name == selectedAccount.name,
      )
      .budgets
      ?.where(
        (element) => element.type == BudgetType.savings,
      ));

  Future<void> addAccount(String accountName) async {
    final user = _userBox.values.firstWhere(
      (element) => element.uid == _appStateUid,
    );

    await _accountsBox.add(Account(name: accountName));
    user.accounts ??= HiveList(_accountsBox);

    user.accounts!.add(_accountsBox.values.last);

    await user.save();

    // _accounts.isEmpty
    //     ? await db
    //         // .collection(FirestoreFieldNames.users)
    //         .collection(FirestoreFieldNames.users)
    //         // /${FirebaseAuth.instance.currentUser!.uid}/${FirestoreFieldNames.accounts}

    //         .doc(FirebaseAuth.instance.currentUser!.uid)
    //         .set({
    //         FirestoreFieldNames.accounts: {
    //           _nameController.text.trim(): {}
    //         }
    //       }).then((doc) {
    //         widgets.showInfoToast('Account added!',
    //             context: navigatorKey.currentContext!);
    //       }).onError((error, _) {
    //         widgets.showInfoToast(error.toString(),
    //             context: navigatorKey.currentContext!);
    //       })
    //     : await db
    //         .doc(
    //             '${FirestoreFieldNames.users}/${FirebaseAuth.instance.currentUser!.uid}')
    //         .update({
    //         '${FirestoreFieldNames.accounts}.${_nameController.text.trim()}':
    //             {}
    //       }).then((doc) {
    //         widgets.showInfoToast('Account added!',
    //             context: navigatorKey.currentContext!);
    //       }).onError((error, _) {
    //         widgets.showInfoToast(error.toString(),
    //             context: navigatorKey.currentContext!);
    //       });
    // _accounts.add(Account(
    //     name: _nameController.text,
    //     // availableBalance: 0,
    //     expenses: 0,
    //     income: 0,
    //     transactions: []));

    // await _accountsBox.add(Account(
    //     name: _nameController.text,
    //     // availableBalance: 0,
    //     expenses: 0,
    //     income: 0,
    //     transactions: []));

    notifyListeners();
  }

  Future<void> addTransaction({
    required String selectedTransactionType,
    required String selectedAccountName,
    required String amount,
    required DateTime selectedDate,
    required String description,
    required TransactionCategory? selectedCategory,
  }) async {
    final selectedAccount = user(_appStateUid)
        .accounts!
        .where((element) => element.name == selectedAccountName)
        .first;
    await _transactionsBox.add((AccountTransaction(
        amount: double.parse(amount),
        date: selectedDate,
        category: selectedCategory,
        description: description,
        type: selectedTransactionType)));
    selectedAccount.transactions ??= HiveList(_transactionsBox);

    selectedAccount.transactions!.add(_transactionsBox.values.last);

    if (selectedTransactionType == 'Income') {
      selectedAccount.income += double.parse(amount);
      selectedAccount.balance += double.parse(amount);
    } else {
      // double amountHolder = double.parse(amount);
      // Budget? budget = selectedAccount.budgets?.firstWhereOrNull(
      //   (element) => element.category == selectedCategory,
      // );
      // if (budget != null) {
      //   //TODO: test
      //   if (budget.amount >= amountHolder) {
      //     //TODO: later do calculations here instead of in the expense budget screen
      //   } else {
      //     if (selectedAccount.savingsBucket >= amountHolder) {
      //       showInfoToast('Deducting from your savings bucket...',
      //           context: navigatorKey.currentContext);
      //       selectedAccount.savingsBucket -= amountHolder;
      //     } else {
      //       showInfoToast('Deducting from your savings bucket...',
      //           context: navigatorKey.currentContext);
      //       amountHolder = amountHolder - selectedAccount.savingsBucket;
      //       selectedAccount.savingsBucket = 0;
      //       //the excess is subtracted from the balance. balance remains same if amountHolder is 0
      //       showInfoToast('Deducting from ${selectedAccount.name} balance',
      //           context: navigatorKey.currentContext);
      //       selectedAccount.balance -= amountHolder;
      //       if (selectedAccount.balance == 0) {
      //         showInfoToast('Your account is fully budgeted👍',
      //             color: Colors.green.shade800,
      //             context: navigatorKey.currentContext);
      //       }
      //       if (selectedAccount.balance < 0) {
      //         showInfoToast('You now have an account balance deficit',
      //             color: Colors.red.shade800,
      //             context: navigatorKey.currentContext);
      //       }
      //     }
      //   }
      // }s
      selectedAccount.expenses += double.parse(amount);
    }
    await selectedAccount.save();
    notifyListeners();
  }

  Future<void> decreaseMilestone(
      {required Account selectedAccount,
      required double difference,
      required Goal goal,
      required double parsedInput}) async {
    if (selectedAccount.balance <= 0) {
      final sum = selectedAccount.balance + difference;
      if (sum <= 0) {
        selectedAccount.balance += difference;
        showInfoToast(
            navigatorKey.currentContext!.localizations
                .your_account_balance_has_been_updated,
            // 'Your account balance has been updated.',
            context: navigatorKey.currentContext);
      } else {
        selectedAccount.balance = 0;
        selectedAccount.savingsBucket += sum;
      }
      if (selectedAccount.balance == 0) {
        showInfoToast(
            navigatorKey
                .currentContext!.localizations.your_account_is_fully_budgeted,
            // 'Your account is fully budgeted👍',
            color: Colors.green.shade800,
            context: navigatorKey.currentContext);
      }
    } else {
      selectedAccount.savingsBucket += difference;
    }

    goal.raisedAmount = parsedInput;
    await selectedAccount.save();
    await goal.save();
    notifyListeners();
  }

  Future<void> increaseMilestone(
      {required double difference,
      required Account selectedAccount,
      required Goal goal,
      required double parsedInput}) async {
    selectedAccount.savingsBucket -= difference;
    goal.raisedAmount = parsedInput;
    await selectedAccount.save();
    await goal.save();
    notifyListeners();
  }

  Future<void> addGoal({
    required Account selectedAccount,
    required String goalName,
    required String goalFund,
    required DateTime currentDate,
    required DateTime selectedDate,
  }) async {
    await _goalsBox.add(Goal(
        name: goalName,
        fund: double.parse(goalFund),
        createdAt: currentDate,
        estimatedDate: selectedDate));
    selectedAccount.goals ??= HiveList(_goalsBox);

    selectedAccount.goals!.add(_goalsBox.values.last);

    await selectedAccount.save();

    notifyListeners();
  }

  Future<void> addExpenseBudget({
    required Account selectedAccount,
    required DateTime currentDate,
    required TransactionCategory selectedCategory,
    required String expenseAmount,
    required String expenseCoverage,
  }) async {
    await _budgetBox.add(Budget(
        category: selectedCategory,
        amount: double.parse(expenseAmount),
        type: BudgetType.expenseBudget,
        createdAt: currentDate,
        duration: int.parse(expenseCoverage)));

    await _budgetBox.add(Budget(
        category: selectedCategory,
        amount: 0,
        createdAt: currentDate,
        type: BudgetType.savings,
        duration: int.parse(expenseCoverage)));

    selectedAccount.budgets ??= HiveList(_budgetBox);

    selectedAccount.budgets?.addAll([
      _budgetBox.values.elementAt(_budgetBox.values.length - 2),
      _budgetBox.values.last,
    ]);

//Old logic which i do not know why i created it:

    // if (selectedAccount.savingsBucket >= parsedExpenseAmount) {
    //   selectedAccount.savingsBucket -= parsedExpenseAmount;
    // } else {
    //   final difference = parsedExpenseAmount - selectedAccount.savingsBucket;
    //   selectedAccount.savingsBucket = 0;
    //   selectedAccount.balance -= difference;
    //   if (selectedAccount.balance == 0) {
    //     showInfoToast('Your account is fully budgeted👍',
    //         color: Colors.green.shade800, context: navigatorKey.currentContext);
    //   }
    //   if (selectedAccount.balance < 0) {
    //     showInfoToast('You now have an account balance deficit',
    //         color: Colors.red.shade800, context: navigatorKey.currentContext);
    //   }
    // }
    final parsedExpenseAmount = double.parse(expenseAmount);
    if (selectedAccount.balance >= parsedExpenseAmount) {
      selectedAccount.balance -= parsedExpenseAmount;
      if (selectedAccount.balance == 0) {
        showInfoToast(
            navigatorKey
                .currentContext!.localizations.your_account_is_fully_budgeted,
            // 'Your account is fully budgeted👍',
            color: Colors.green.shade800,
            context: navigatorKey.currentContext);
      }
    } else {
      final difference = parsedExpenseAmount - selectedAccount.balance;
      selectedAccount.balance = 0;
      showInfoToast(
          navigatorKey
              .currentContext!.localizations.deducting_from_your_savings_bucket,
          // 'Deducting from your savings bucket',
          context: navigatorKey.currentContext);
      if (selectedAccount.savingsBucket >= difference) {
        selectedAccount.savingsBucket -= difference;
      } else {
        final difference2 = difference - selectedAccount.savingsBucket;
        selectedAccount.savingsBucket = 0;
        selectedAccount.balance -= difference2;
        showInfoToast(
            navigatorKey.currentContext!.localizations
                .you_now_have_an_account_balance_deficit,
            // 'You now have an account balance deficit',
            color: Colors.red.shade800,
            context: navigatorKey.currentContext);
      }
    }

    await selectedAccount.save();

    notifyListeners();
  }

  Future<void> deleteGoal(
      {required Goal goal, required Account selectedAccount}) async {
    if (goal.raisedAmount > 0) {
      selectedAccount.balance += goal.raisedAmount;
    }
    await goal.delete();
    await selectedAccount.save();
    notifyListeners();
  }

  Future<void> addBalanceToBucket({
    required Account selectedAccount,
  }) async {
    selectedAccount.savingsBucket += selectedAccount.balance;
    selectedAccount.balance = 0;
    await selectedAccount.save();
    notifyListeners();
  }

  Future<void> subtractFromBucket({
    required Account selectedAccount,
    required double subtractor,
  }) async {
    selectedAccount.savingsBucket -= subtractor;

    await selectedAccount.save();
    notifyListeners();
  }

//not used yet but has been tested
  Future<void> addToBucket({
    required Account selectedAccount,
    required double adder,
  }) async {
    selectedAccount.savingsBucket += adder;

    await selectedAccount.save();
    notifyListeners();
  }

  Future<void> deleteExpenseBudget(
      {required Budget budget, required Account selectedAccount}) async {
    selectedAccount.balance += budget.amount;
    await budget.delete();
    //getting corresponding saving
    await selectedAccount.budgets!
        .firstWhere(
          (element) => (element.category!.name == budget.category!.name &&
              element.type == BudgetType.savings),
        )
        .delete();

    await selectedAccount.save();

    notifyListeners();
  }

  Future<void> updateExpenseBudget(
      {required Budget budget,
      required Account selectedAccount,
      required int newDuration,
      required double parsedAmount}) async {
    final double difference = parsedAmount - budget.amount;

    if (selectedAccount.balance > 0) {
      if (selectedAccount.balance >= difference) {
        selectedAccount.balance -= difference;
      } else {
        final double difference2 = difference - selectedAccount.balance;
        selectedAccount.balance = 0;
        if (selectedAccount.savingsBucket >= difference2) {
          if (selectedAccount.savingsBucket > 0) {
            showInfoToast(
                navigatorKey.currentContext!.localizations
                    .deducting_from_your_savings_bucket,
                // 'Deducting from your savings bucket',
                context: navigatorKey.currentContext);
          }
          selectedAccount.savingsBucket -= difference2;
        } else {
          final difference3 = difference2 - selectedAccount.savingsBucket;
          if (selectedAccount.savingsBucket > 0) {
            showInfoToast(
                navigatorKey.currentContext!.localizations
                    .deducting_from_your_savings_bucket,
                // 'Deducting from your savings bucket',
                context: navigatorKey.currentContext);
          }
          selectedAccount.savingsBucket = 0;
          selectedAccount.balance -= difference3;
        }
      }
    } else {
      if (difference > 0) {
        if (selectedAccount.savingsBucket >= difference) {
          showInfoToast(
              navigatorKey.currentContext!.localizations
                  .deducting_from_your_savings_bucket,
              // 'Deducting from your savings bucket',
              context: navigatorKey.currentContext);
          selectedAccount.savingsBucket -= difference;
        } else {
          final double difference2 = difference - selectedAccount.savingsBucket;
          selectedAccount.savingsBucket = 0;
          selectedAccount.balance -= difference2;
        }
      } else {
        //add difference to balance
        selectedAccount.balance -= difference;
        showInfoToast(
            navigatorKey.currentContext!.localizations
                .the_difference_has_been_added_to_the_accounts_balance,
            // "The difference has been added to the account's balance",
            context: navigatorKey.currentContext);
      }
      final correspondingSaving = selectedAccount.budgets!.firstWhere(
        (element) => (element.category!.name == budget.category!.name &&
            element.type == BudgetType.savings),
      );

      if (parsedAmount <= correspondingSaving.amount) {
        correspondingSaving.amount = 0;
        showInfoToast(
            navigatorKey
                .currentContext!.localizations.adjust_your_saving_accordingly,
            // 'Adjust your saving accordingly',
            context: navigatorKey.currentContext);
      }
    }

    budget
      ..amount = parsedAmount
      ..duration = newDuration;

    await selectedAccount.save();
    await budget.save();
    if (selectedAccount.balance == 0) {
      showInfoToast(
          navigatorKey
              .currentContext!.localizations.your_account_is_fully_budgeted,
          // 'Your account is fully budgeted👍',
          color: Colors.green.shade800,
          context: navigatorKey.currentContext);
    } else if (selectedAccount.balance < 0) {
      showInfoToast(
          navigatorKey.currentContext!.localizations
              .you_now_have_an_account_balance_deficit,
          // 'You now have an account balance deficit',
          color: Colors.red.shade800,
          context: navigatorKey.currentContext);
    }

    notifyListeners();
  }
}
