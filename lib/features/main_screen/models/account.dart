import 'package:savery/features/new_transaction/models/transaction_category.dart';

class Account {
  String name;
  double availableBalance;
  double income;
  double? expenses;
  List<Transaction> transactions;

  List<Budget> budgets;

  Account({
    required this.name,
    required this.availableBalance,
    required this.income,
    this.expenses,
    this.transactions = const [],
    this.budgets = const [],
  });
}

abstract class Budget {
  final TransactionCategory transactionCategory;
  final double amount;
  final BudgetType type;

  Budget({
    required this.transactionCategory,
    required this.amount,
    required this.type,
  });
}

class Transaction {
  TransactionCategory category;
  double amount;
  DateTime createdAt;
  String description;

  Transaction(
      {required this.category,
      required this.amount,
      required this.createdAt,
      required this.description});
}

enum BudgetType { bill, savings, goal }
