import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import 'package:money_tracker_app/persistent/hive_data_store_controller.dart';
import 'package:money_tracker_app/src/features/category/domain/category_hive_model.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class CategoryRepository {
  final _incomeCategoryBox = HiveDataStore.getIncomeCategoriesBox;
  final _expenseCategoryBox = HiveDataStore.getExpenseCategoriesBox;

  Future<void> writeNewCategory(
      {required CategoryType type,
      required String iconCategory,
      required int iconIndex,
      required String name,
      required int colorIndex}) async {
    final categoryHiveModel = CategoryHiveModel.create(
        type: type,
        iconCategory: iconCategory,
        iconIndex: iconIndex,
        name: name,
        colorIndex: colorIndex);

    if (type == CategoryType.income) {
      _incomeCategoryBox.add(categoryHiveModel);
    } else if (type == CategoryType.expense) {
      _expenseCategoryBox.add(categoryHiveModel);
    }
  }

  Future<void> deleteCategory({required CategoryType type, required int index}) async {
    if (type == CategoryType.income) {
      _incomeCategoryBox.deleteAt(index);
    } else if (type == CategoryType.expense) {
      _expenseCategoryBox.deleteAt(index);
    }
  }

  Future<void> editCategory(
      {required CategoryType type, required int index, required CategoryHiveModel newValue}) async {
    if (type == CategoryType.income) {
      _incomeCategoryBox.putAt(index, newValue);
    } else if (type == CategoryType.expense) {
      _expenseCategoryBox.putAt(index, newValue);
    }
  }

  Future<void> reorderCategory(
      {required CategoryType type, required int oldIndex, required int newIndex}) async {
    if (type == CategoryType.income) {
      HiveDataStore.reorderBox(_incomeCategoryBox, oldIndex, newIndex);
    } else if (type == CategoryType.expense) {
      HiveDataStore.reorderBox(_expenseCategoryBox, oldIndex, newIndex);
    }
  }
}

/// Widgets only watch to this Provider if needed to call function
/// on this Category Repository.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository());

/// This [StateProvider] returns a `List` of domains of this Category feature.
///
/// Widgets must watch to this StateProvider in order to be rebuilt
final incomeAppCategoryDomainListProvider = StateProvider<List<CategoryHiveModel>>((ref) {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return ref.watch(hiveBoxValuesControllerProvider(categoryRepository._incomeCategoryBox))
      as List<CategoryHiveModel>;
});

/// This [StateProvider] returns a `List` of domains of this Category feature.
///
/// Widgets must watch to this StateProvider in order to be rebuilt
final expenseAppCategoryDomainListProvider = StateProvider<List<CategoryHiveModel>>((ref) {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return ref.watch(hiveBoxValuesControllerProvider(categoryRepository._expenseCategoryBox))
      as List<CategoryHiveModel>;
});
