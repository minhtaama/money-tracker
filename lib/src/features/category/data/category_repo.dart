import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import 'package:money_tracker_app/src/features/category/data/category_icons.dart';
import 'package:money_tracker_app/src/features/category/data/hive_model/category_hive_model.dart';
import 'package:money_tracker_app/src/features/category/domain/app_category.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class CategoryRepository {
  final incomeCategoryBox = Hive.box<CategoryHiveModel>(HiveDataStore.incomeCategoriesBox);
  final expenseCategoryBox = Hive.box<CategoryHiveModel>(HiveDataStore.expenseCategoriesBox);

  List<AppCategory> getAppCategoryList(CategoryType type) {
    List<CategoryHiveModel> categoryBox = type == CategoryType.income
        ? incomeCategoryBox.values.toList()
        : expenseCategoryBox.values.toList();

    final List<AppCategory> returnList = <AppCategory>[];

    for (int i = 0; i <= categoryBox.length; i++) {
      returnList.add(AppCategory(
          type: categoryBox[i].type,
          id: categoryBox[i].id,
          index: i,
          icon: CategoryIcons.getIcon(categoryBox[i].icon),
          name: categoryBox[i].name,
          color: Color(categoryBox[i].color)));
    }

    return returnList;
  }

  Future<void> writeNewCategory(
      {required CategoryType type,
      required String icon,
      required String name,
      required Color color}) async {
    final categoryHiveModel = CategoryHiveModel.create(type: type, icon: icon, name: name, color: color);
    if (type == CategoryType.income) {
      incomeCategoryBox.add(categoryHiveModel);
    } else {
      expenseCategoryBox.add(categoryHiveModel);
    }
  }

  Future<void> deleteCategory({required CategoryType type, required int index}) async {
    if (type == CategoryType.income) {
      incomeCategoryBox.deleteAt(index);
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository());

final categoryListProvider = Provider.family<List<AppCategory>, CategoryType>((ref, type) {
  final categoryProvider = ref.watch(categoryRepositoryProvider);
  return categoryProvider.getAppCategoryList(type);
});
