import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/src/features/accounts/data/hive_model/account_hive_model.dart';
import 'package:money_tracker_app/src/features/settings/data/hive_model/settings_hive_model.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import '../src/features/category/data/hive_model/category_hive_model.dart';

class HiveDataStore {
  // String value of Hive Box. DO NOT MODIFY this string value or all the data will be gone
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

  static Future<void> init() async {
    await Hive.initFlutter(); // In hive_flutter package

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
