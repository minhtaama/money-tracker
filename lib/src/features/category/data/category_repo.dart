import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/features/category/data/hive_model/category_hive_model.dart';
import 'package:money_tracker_app/src/features/category/domain/app_category.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class CategoryRepository {
  final _incomeCategoryBox = HiveDataStore.getIncomeCategoriesBox;
  final _expenseCategoryBox = HiveDataStore.getExpenseCategoriesBox;

  List<AppCategory> _getAppCategoryList(CategoryType type) {
    List<CategoryHiveModel> categoryBox = type == CategoryType.income
        ? _incomeCategoryBox.values.toList()
        : _expenseCategoryBox.values.toList();

    final List<AppCategory> returnList = <AppCategory>[];

    for (int i = 0; i <= categoryBox.length - 1; i++) {
      returnList.add(AppCategory(
          type: categoryBox[i].type,
          id: categoryBox[i].id,
          index: i,
          icon: AppIcons.fromCategoryAndIndex(categoryBox[i].iconCategory, categoryBox[i].iconIndex),
          name: categoryBox[i].name,
          color: Color(categoryBox[i].color)));
    }

    return returnList;
  }

  Future<void> writeNewCategory(
      {required CategoryType type,
      required String iconCategory,
      required int iconIndex,
      required String name,
      required Color color}) async {
    final categoryHiveModel = CategoryHiveModel.create(
        type: type, iconCategory: iconCategory, iconIndex: iconIndex, name: name, color: color);
    if (type == CategoryType.income) {
      _incomeCategoryBox.add(categoryHiveModel);
    } else {
      _expenseCategoryBox.add(categoryHiveModel);
    }
  }

  Future<void> deleteCategory({required CategoryType type, required int index}) async {
    if (type == CategoryType.income) {
      _incomeCategoryBox.deleteAt(index);
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository());

final categoryListProvider = Provider.family<List<AppCategory>, CategoryType>((ref, type) {
  final categoryProvider = ref.watch(categoryRepositoryProvider);
  return categoryProvider._getAppCategoryList(type);
});
