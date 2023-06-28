import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/src/features/accounts/data/hive_model/account_hive_model.dart';
import 'package:money_tracker_app/src/features/settings/data/hive_model/settings_hive_model.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import '../src/features/category/data/hive_model/category_hive_model.dart';

class HiveDataStore {
  // String value of Hive Box. DO NOT MODIFY this value or all the data will be gone
  static const _incomeCategoriesBox = 'incomeCategories';
  static const _expenseCategoriesBox = 'expensesCategories';
  static const _settingsBox = 'settingsBox';

  static SettingsHiveModel get getSettingsHiveModel => Hive.box<SettingsHiveModel>(_settingsBox).get(
        'settingsHiveModel',
        defaultValue: SettingsHiveModel(currentThemeIndex: 0, themeType: ThemeType.light),
      )!;

  static void setSettingsHiveModel(SettingsHiveModel settingsHiveModel) {
    Hive.box<SettingsHiveModel>(_settingsBox).put('settingsHiveModel', settingsHiveModel);
  }

  static Box<CategoryHiveModel> get getIncomeCategoriesBox =>
      Hive.box<CategoryHiveModel>(_incomeCategoriesBox);

  static Box<CategoryHiveModel> get getExpenseCategoriesBox =>
      Hive.box<CategoryHiveModel>(_expenseCategoriesBox);

  /// Use with `reorderable` package or [ReorderableListView]. In this case,
  /// Hive is a key-value data store, so that it will not shrink or expands
  /// at all when deleting a key-value pair.
  ///
  /// This function is called when user drop the "item to reorder" to the
  /// new index. The function take responsibility to reorder all the items
  /// between the old and new index.
  static void reorderBox<T>(Box<T> box, int oldIndex, int newIndex) {
    final itemToReorder = box.getAt(oldIndex) as T;

    // Moving item up the list
    if (newIndex < oldIndex) {
      for (int i = oldIndex - 1; i >= newIndex; i--) {
        // For each loop, get an element (between newIndex -> oldIndex) from the bottom
        // to the top, then move it down the list by 1 index
        final itemBetween = box.getAt(i) as T;
        box.putAt(i + 1, itemBetween);
      }
      box.putAt(newIndex, itemToReorder);
    }

    // Moving item down the list
    if (newIndex > oldIndex) {
      for (int i = oldIndex + 1; i <= newIndex; i++) {
        // For each loop, get an element (between oldIndex -> newIndex) from the top
        // to the bottom, then move it up the list by 1 index
        final itemBetween = box.getAt(i) as T;
        box.putAt(i - 1, itemBetween);
      }
      box.putAt(newIndex, itemToReorder);
    }
  }

  /// Call this function only in __`main()`__ method
  static Future<void> init() async {
    await Hive.initFlutter(); // hive_flutter

    Hive.registerAdapter<CategoryHiveModel>(CategoryHiveModelAdapter());
    Hive.registerAdapter<AccountHiveModel>(AccountHiveModelAdapter());
    Hive.registerAdapter<SettingsHiveModel>(SettingsHiveModelAdapter());
    Hive.registerAdapter<TransactionType>(TransactionTypeAdapter());
    Hive.registerAdapter<ThemeType>(ThemeTypeAdapter());
    Hive.registerAdapter<CategoryType>(CategoryTypeAdapter());

    await Hive.openBox<CategoryHiveModel>(_incomeCategoriesBox);
    await Hive.openBox<CategoryHiveModel>(_expenseCategoriesBox);
    await Hive.openBox<SettingsHiveModel>(_settingsBox);
  }
}
