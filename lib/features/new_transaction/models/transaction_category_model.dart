import 'package:hive_flutter/hive_flutter.dart';

part 'transaction_category_model.g.dart';

@HiveType(typeId: 4, adapterName: 'TransactionCategoryAdapter')
class TransactionCategory extends HiveObject {
  @HiveField(0)
  final String icon;
  @HiveField(1)
  final String name;

  TransactionCategory({required this.icon, required this.name});
}
