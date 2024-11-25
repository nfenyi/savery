import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:get/get_utils/get_utils.dart';
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
    required String? selectedCategory,
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
      double amountHolder = double.parse(amount);
      Budget? budget = selectedAccount.budgets?.firstWhereOrNull(
        (element) => element.category == selectedCategory,
      );
      if (budget != null) {
        //TODO: test
        if (budget.amount >= amountHolder) {
          //TODO: later do calculations here instead of in the expense budget screen
        } else {
          if (selectedAccount.savingsBucket >= amountHolder) {
            showInfoToast('Deducting from your savings bucket...',
                context: navigatorKey.currentContext);
            selectedAccount.savingsBucket -= amountHolder;
          } else {
            showInfoToast('Deducting from your savings bucket...',
                context: navigatorKey.currentContext);
            amountHolder = amountHolder - selectedAccount.savingsBucket;
            selectedAccount.savingsBucket = 0;
            //the excess is subtracted from the balance. balance remains same if amountHolder is 0
            showInfoToast('Deducting from ${selectedAccount.name} balance',
                context: navigatorKey.currentContext);
            selectedAccount.balance -= amountHolder;
          }
        }
      }
      selectedAccount.expenses += double.parse(amount);
    }
    await selectedAccount.save();
    notifyListeners();
  }

  Future<void> reduceMilestone(
      {required Account selectedAccount,
      double? difference,
      required Goal goal,
      required double parsedInput}) async {
    selectedAccount.savingsBucket += selectedAccount.balance;
    if (difference == null) {
      selectedAccount.balance = 0;
    }
    goal.raisedAmount = parsedInput;
    await selectedAccount.save();
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
    required String selectedCategory,
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
    selectedAccount.balance -= double.parse(expenseAmount);

    await selectedAccount.save();
    // await user.save();

    notifyListeners();
  }

  Future<void> deleteGoal(
      {required Goal goal, required Account selectedAccount}) async {
    await goal.delete();
    await selectedAccount.save();
    notifyListeners();
  }

  Future<void> addToBucket({
    required Account selectedAccount,
  }) async {
    selectedAccount.savingsBucket += selectedAccount.balance;

    await selectedAccount.save();
    notifyListeners();
  }
}
