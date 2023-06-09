import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/src/features/category/model/income_category.dart';

class HiveDataStore {
  static const categoriesBox = 'categories';

  Future<void> init() async {
    await Hive.initFlutter(); // Trong hive_flutter
    // Register Adapters
    Hive.registerAdapter<IncomeCategory>(IncomeCategoryAdapter());

    // Open boxes
    await Hive.openBox<IncomeCategory>(categoriesBox);
  }

  ValueListenable<Box<IncomeCategory>> incomeCategoriesListenable() {
    return Hive.box<IncomeCategory>(categoriesBox).listenable();
  }

  Future<void> createDemoCategory({required List<IncomeCategory> categories, bool force = false}) async {
    final box = Hive.box<IncomeCategory>(categoriesBox);
    if (box.isEmpty || force == true) {
      await box.clear();
      await box.addAll(categories);
    }
  }
}
