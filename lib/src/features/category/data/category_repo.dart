import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import 'package:money_tracker_app/persistent/hive_data_store_controller.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/features/category/data/hive_model/category_hive_model.dart';
import 'package:money_tracker_app/src/features/category/domain/app_category.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class CategoryRepository {
  final _incomeCategoryBox = HiveDataStore.getIncomeCategoriesBox;
  final _expenseCategoryBox = HiveDataStore.getExpenseCategoriesBox;

  List<AppCategory> _getAppCategoryList(List<CategoryHiveModel> categoryHiveModelList) {
    final List<AppCategory> returnList = <AppCategory>[];

    for (int i = 0; i <= categoryHiveModelList.length - 1; i++) {
      returnList.add(
        AppCategory(
          type: categoryHiveModelList[i].type,
          id: categoryHiveModelList[i].id,
          icon: AppIcons.fromCategoryAndIndex(
              categoryHiveModelList[i].iconCategory, categoryHiveModelList[i].iconIndex),
          name: categoryHiveModelList[i].name,
          backgroundColor: AppColors.allColorsUserCanPick[categoryHiveModelList[i].colorIndex][0],
          iconColor: AppColors.allColorsUserCanPick[categoryHiveModelList[i].colorIndex][1],
        ),
      );
    }
    return returnList;
  }

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
final incomeAppCategoryDomainListProvider = StateProvider<List<AppCategory>>((ref) {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  final hiveModelsList =
      ref.watch(hiveBoxValuesControllerProvider(categoryRepository._incomeCategoryBox))
          as List<CategoryHiveModel>;
  return categoryRepository._getAppCategoryList(hiveModelsList);
});

/// This [StateProvider] returns a `List` of domains of this Category feature.
///
/// Widgets must watch to this StateProvider in order to be rebuilt
final expenseAppCategoryDomainListProvider = StateProvider<List<AppCategory>>((ref) {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  final hiveModelsList =
      ref.watch(hiveBoxValuesControllerProvider(categoryRepository._expenseCategoryBox))
          as List<CategoryHiveModel>;
  return categoryRepository._getAppCategoryList(hiveModelsList);
});
