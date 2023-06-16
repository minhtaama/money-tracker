import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../src/features/category/data/hive_model/category_hive_model.dart';

class HiveDataStore {
  // String value of Hive Box. DO NOT MODIFY this string value or all the data will be gone
  static const incomeCategoriesBox = 'incomeCategories';
  static const expenseCategoriesBox = 'expensesCategories';

  Future<void> init() async {
    await Hive.initFlutter(); // In hive_flutter package

    Hive.registerAdapter<CategoryHiveModel>(CategoryHiveModelAdapter());

    await Hive.openBox<CategoryHiveModel>(incomeCategoriesBox);
    await Hive.openBox<CategoryHiveModel>(expenseCategoriesBox);
  }

  // Future<void> createDemoCategory(
  //     {required List<IncomeCategoryHiveModel> categories, bool force = false}) async {
  //   final box = Hive.box<IncomeCategoryHiveModel>(incomeCategoriesBox);
  //   if (box.isEmpty || force == true) {
  //     await box.clear();
  //     await box.addAll(categories);
  //   }
  // }
}

/// This provider data is override in main() function
final hiveStoreProvider = Provider<HiveDataStore>((ref) {
  throw UnimplementedError();
});
