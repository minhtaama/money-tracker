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

  List<AppCategory> getCategoryList(CategoryType type) {
    List<CategoryHiveModel> categoryBox = type == CategoryType.income
        ? incomeCategoryBox.values.toList()
        : expenseCategoryBox.values.toList();
    final List<AppCategory> returnList = <AppCategory>[];
    for (CategoryHiveModel category in categoryBox) {
      returnList.add(AppCategory(
          type: category.type,
          id: category.id,
          icon: CategoryIcons.getIconFromName(category.icon),
          name: category.name,
          color: Color(category.color)));
    }
    return returnList;
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository());

final categoryListProvider = Provider.family<List<AppCategory>, CategoryType>((ref, type) {
  final categoryProvider = ref.watch(categoryRepositoryProvider);
  return categoryProvider.getCategoryList(type);
});
