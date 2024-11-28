import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
// import 'package:get/get_utils/get_utils.dart';
import 'package:savery/main.dart';

class UserNotifier extends ChangeNotifier {
  final Box<AppUser> _userBox;
  final _accountsBox = Hive.box<Account>(AppBoxes.accounts);
  final _transactionsBox = Hive.box<AccountTransaction>(AppBoxes.transactions);
  final _goalsBox = Hive.box<Goal>(AppBoxes.goals);
  final _budgetBox = Hive.box<Budget>(AppBoxes.budgets);

  UserNotifier(this._userBox);

  AppUser get user => _userBox.values.first;

  HiveList<AccountTransaction>? transactions(Account selectedAccount) =>
      user.accounts
          ?.firstWhere(
            (element) => element.name == selectedAccount.name,
          )
          .transactions;

  double savingsBucket(Account selectedAccount) => user.accounts!
      .firstWhere(
        (element) => element.name == selectedAccount.name,
      )
      .savingsBucket;

  HiveList<Goal>? goals(Account selectedAccount) => user.accounts!
      .firstWhere(
        (element) => element.name == selectedAccount.name,
      )
      .goals;
  Iterable<Budget>? expenseBudgets(Account selectedAccount) => (user.accounts!
      .firstWhere(
        (element) => element.name == selectedAccount.name,
      )
      .budgets
      ?.where(
        (element) => element.type == BudgetType.expenseBudget,
      ));
  Iterable<Budget>? savings(Account selectedAccount) => (user.accounts!
      .firstWhere(
        (element) => element.name == selectedAccount.name,
      )
      .budgets
      ?.where(
        (element) => element.type == BudgetType.savings,
      ));

  Future<void> addAccount(String accountName) async {
    final user = _userBox.values.first;

    await _accountsBox.add(Account(name: accountName));

    user.accounts = HiveList(_accountsBox);

    user.accounts!.addAll(_accountsBox.values);

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
    final selectedAccount = user.accounts!
        .where((element) => element.name == selectedAccountName)
        .first;
    await _transactionsBox.add((AccountTransaction(
        amount: double.parse(amount),
        date: selectedDate,
        category: selectedCategory,
        description: description,
        type: selectedTransactionType)));
    final temp = selectedAccount.transactions;
    selectedAccount.transactions = HiveList(_transactionsBox);
    if (temp != null) {
      selectedAccount.transactions!
          .addAll({...temp, _transactionsBox.values.last});
    } else {
      selectedAccount.transactions!.addAll({_transactionsBox.values.last});
    }
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
    if (selectedAccount.balance < 0) {
      selectedAccount.balance += difference;
      showInfoToast('Your account balance has been updated.',
          context: navigatorKey.currentContext);
    } else {
      selectedAccount.savingsBucket += difference;
    }
    // if (difference == null) {
    //   selectedAccount.balance = 0;
    // }
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
    final temp = selectedAccount.goals;
    selectedAccount.goals = HiveList(_goalsBox);
    if (temp != null) {
      selectedAccount.goals!.addAll([...temp, _goalsBox.values.last]);
    } else {
      selectedAccount.goals?.addAll([
        _goalsBox.values.last,
      ]);
    }

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

    final temp = selectedAccount.budgets;
    selectedAccount.budgets = HiveList(_budgetBox);
    if (temp != null) {
      selectedAccount.budgets?.addAll([
        ...temp,
        _budgetBox.values.last,
        _budgetBox.values.elementAt(_budgetBox.values.length - 2)
      ]);
    } else {
      selectedAccount.budgets?.addAll([
        _budgetBox.values.last,
        _budgetBox.values.elementAt(_budgetBox.values.length - 2)
      ]);
    }
    final parsedExpenseAmount = double.parse(expenseAmount);
    if (selectedAccount.savingsBucket >= parsedExpenseAmount) {
      selectedAccount.savingsBucket -= parsedExpenseAmount;
    } else {
      final difference = parsedExpenseAmount - selectedAccount.savingsBucket;
      selectedAccount.savingsBucket = 0;
      selectedAccount.balance -= difference;
      if (selectedAccount.balance == 0) {
        showInfoToast('Your account is fully budgeted👍',
            color: Colors.green.shade800, context: navigatorKey.currentContext);
      }
      if (selectedAccount.balance < 0) {
        showInfoToast('You now have an account balance deficit',
            color: Colors.red.shade800, context: navigatorKey.currentContext);
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
    late final double anotherDifference;

    if (selectedAccount.balance > 0) {
      if (selectedAccount.balance >= difference) {
        selectedAccount.balance -= difference;
      } else {
        anotherDifference = selectedAccount.balance - difference;
        selectedAccount.balance = 0;
        if (selectedAccount.savingsBucket >= anotherDifference) {
          selectedAccount.savingsBucket -= anotherDifference;
        } else {
          selectedAccount.balance -=
              (selectedAccount.savingsBucket - anotherDifference);

          if (selectedAccount.balance == 0) {
            showInfoToast('Your account is fully budgeted👍',
                color: Colors.green.shade800,
                context: navigatorKey.currentContext);
          }
          if (selectedAccount.balance < 0) {
            showInfoToast('You now have an account balance deficit',
                color: Colors.red.shade800,
                context: navigatorKey.currentContext);
          }
          selectedAccount.savingsBucket -= selectedAccount.savingsBucket;
        }
      }
    } else {
      if (selectedAccount.savingsBucket > difference) {
        showInfoToast('Deducting from your savings bucket',
            context: navigatorKey.currentContext);
        selectedAccount.savingsBucket -= difference;
      } else {
        anotherDifference = difference - selectedAccount.savingsBucket;
        selectedAccount.savingsBucket -= selectedAccount.savingsBucket;
        selectedAccount.balance -= anotherDifference;
      }
    }
    final correspondingSaving = selectedAccount.budgets!.firstWhere(
      (element) => (element.category!.name == budget.category!.name &&
          element.type == BudgetType.savings),
    );

    if (parsedAmount <= correspondingSaving.amount) {
      correspondingSaving.amount = 0;
      showInfoToast('Adjust your saving accordingly',
          context: navigatorKey.currentContext);
    }
    budget
      ..amount = parsedAmount
      ..duration = newDuration;

    await selectedAccount.save();
    await budget.save();

    notifyListeners();
  }
}
