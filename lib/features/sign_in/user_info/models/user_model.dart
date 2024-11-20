import 'package:hive_flutter/adapters.dart';
import 'package:savery/app_constants/app_constants.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0, adapterName: 'UserAdapter')
class AppUser extends HiveObject {
  @HiveField(0)
  String uid;
  @HiveField(1)
  HiveList<Account>? accounts;
  @HiveField(2)
  String? displayName;
  @HiveField(3)
  String? phoneNumber;
  @HiveField(4)
  String? email;
  @HiveField(5)
  String? photoUrl;

  AppUser({
    required this.uid,
    this.accounts,
    this.displayName = 'user',
    this.phoneNumber,
    this.photoUrl,
    this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? AppConstants.na,
      accounts: HiveList(
        json['accounts']
            .map((accountJson) => Account.fromJson(accountJson))
            .toList<Account>(),
      ),
      displayName: json['displayName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'accounts': accounts == null
          ? []
          : accounts!.map((account) => account.toJson()).toList(),
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
    };
  }
}

@HiveType(typeId: 1, adapterName: 'AccountAdapter')
class Account extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  double income;
  @HiveField(2)
  double expenses;
  @HiveField(3)
  HiveList<AccountTransaction>? transactions;
  @HiveField(4)
  HiveList<Budget>? budgets;
  @HiveField(5)
  String? currency;

  Account({
    required this.name,
    this.expenses = 0,
    this.transactions,
    this.income = 0,
    this.budgets,
    this.currency,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      name: json['name'] ?? AppConstants.na,
      income: json['income'],
      expenses: json['expenses'],
      transactions: json['transactions']
          .map(
              (transactionJson) => AccountTransaction.fromJson(transactionJson))
          .toList(),
      budgets: json['budgets']
          .map((budgetJson) => Budget.fromJson(budgetJson))
          .toList(),
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'income': income,
      'expenses': expenses,
      'currency': currency,
      'transactions':
          transactions!.map((transaction) => transaction.toJson()).toList(),
      'budgets': budgets == null
          ? []
          : budgets?.map((budget) => budget.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 2, adapterName: 'BudgetAdapter')
class Budget extends HiveObject {
  @HiveField(0)
  String? category;
  @HiveField(1)
  double amount;
  @HiveField(2)
  BudgetType type;
  @HiveField(3)
  int duration;
  @HiveField(4)
  DateTime createdAt;

  Budget({
    this.category,
    required this.amount,
    required this.type,
    required this.duration,
    required this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['name'] ?? AppConstants.na,
      amount: json['amount'],
      type: BudgetType.values[json['type']],
      duration: json['duration'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': category,
      'amount': amount,
      'type': type.index,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum BudgetType { expenseBudget, savings, goal }

@HiveType(typeId: 3, adapterName: 'TransactionAdapter')
class AccountTransaction extends HiveObject {
  @HiveField(0)
  String type;
  @HiveField(1)
  double amount;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  String description;
  @HiveField(4)
  String? category;

  AccountTransaction({
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    this.category,
  });

  factory AccountTransaction.fromJson(Map<String, dynamic> json) {
    return AccountTransaction(
      type: json['type'] ?? AppConstants.na,
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      description: json['description'] ?? AppConstants.na,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'category': category,
    };
  }
}
