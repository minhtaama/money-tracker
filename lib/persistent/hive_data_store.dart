import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/src/features/category/model/expense_category.dart';
import 'package:money_tracker_app/src/features/category/model/income_category.dart';

class HiveDataStore {
  /// String value of Hive Box. Do not modify this string value or all the data will be gone
  static const incomeCategoriesBox = 'incomeCategories';

  /// String value of Hive Box. Do not modify this string value or all the data will be gone
  static const expenseCategoriesBox = 'expensesCategories';

  Future<void> init() async {
    await Hive.initFlutter(); // Trong hive_flutter
    // Register Adapters
    Hive.registerAdapter<IncomeCategory>(IncomeCategoryAdapter());
    Hive.registerAdapter<ExpenseCategory>(ExpenseCategoryAdapter());

    // Open boxes
    await Hive.openBox<IncomeCategory>(incomeCategoriesBox);
    await Hive.openBox<ExpenseCategory>(expenseCategoriesBox);
  }

  ValueListenable<Box<IncomeCategory>> incomeCategoriesBoxListenable() {
    return Hive.box<IncomeCategory>(incomeCategoriesBox).listenable();
  }

  ValueListenable<Box<ExpenseCategory>> expenseCategoriesBoxListenable() {
    return Hive.box<ExpenseCategory>(expenseCategoriesBox).listenable();
  }

  Future<void> createDemoCategory({required List<IncomeCategory> categories, bool force = false}) async {
    final box = Hive.box<IncomeCategory>(incomeCategoriesBox);
    if (box.isEmpty || force == true) {
      await box.clear();
      await box.addAll(categories);
    }
  }
}

/// This provider data is override in main() function
final hiveStoreProvider = Provider<HiveDataStore>((ref) {
  throw UnimplementedError();
});
