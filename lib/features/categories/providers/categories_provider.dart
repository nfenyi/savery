import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';

import '../../new_transaction/models/transaction_category_model.dart';

final categoriesProvider = ChangeNotifierProvider<CategoriesNotifier>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends ChangeNotifier {
  final _transactionCategoriesBox =
      Hive.box<TransactionCategory>(AppBoxes.transactionsCategories);
  Iterable<TransactionCategory> get categories =>
      _transactionCategoriesBox.values;
  Future<void> addCategory({required String name, required String icon}) async {
    await _transactionCategoriesBox
        .add(TransactionCategory(icon: icon, name: name));
    notifyListeners();
  }

  Future<void> deleteCategory({required int index}) async {
    await _transactionCategoriesBox.values.elementAt(index - 1).delete();
    notifyListeners();
  }
}
