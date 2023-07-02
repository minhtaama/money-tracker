import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_data_store.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class CategoryRepository {
  CategoryRepository(this.isar);

  final Isar isar;

  Stream<List<CategoryIsar>> _watchCategoryList(CategoryType type) {
    Query<CategoryIsar> query = isar.categoryIsars.filter().typeEqualTo(type).sortByOrder().build();
    return query.watch(fireImmediately: true);
  }

  Future<void> writeNewCategory({
    required CategoryType type,
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
  }) async {
    final newCategory = CategoryIsar()
      ..type = type
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..colorIndex = colorIndex;
    await isar.writeTxn(() async {
      await isar.categoryIsars.put(newCategory);
      // Assign order value equal to its `Isar.autoIncrementID` at the first time
      newCategory.order = newCategory.id;
      await isar.categoryIsars.put(newCategory);
    });
  }

  Future<void> editCategory(
    CategoryIsar currentCategory, {
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
  }) async {
    currentCategory
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..colorIndex = colorIndex;
    await isar.writeTxn(() async => await isar.categoryIsars.put(currentCategory));
  }

  Future<void> deleteCategory(CategoryIsar category) async {
    await isar.writeTxn(() async => await isar.categoryIsars.delete(category.id));
  }

  /// The list must be the same list displayed in the widget (including order)
  Future<void> reorderCategory(List<CategoryIsar> list, int oldIndex, int newIndex) async {
    await isar.writeTxn(
      () async {
        if (newIndex < oldIndex) {
          // Move item up the list
          int temp = list[newIndex].order!;
          for (int i = newIndex; i < oldIndex; i++) {
            list[i].order = list[i + 1].order;
            isar.categoryIsars.put(list[i]);
          }
          list[oldIndex].order = temp;
          isar.categoryIsars.put(list[oldIndex]);
        } else {
          // Move item down the list
          int temp = list[newIndex].order!;
          for (int i = newIndex; i > oldIndex; i--) {
            list[i].order = list[i - 1].order;
            isar.categoryIsars.put(list[i]);
          }
          list[oldIndex].order = temp;
          isar.categoryIsars.put(list[oldIndex]);
        }
      },
    );
  }
}

final categoryRepositoryIsarProvider = Provider<CategoryRepository>(
  (ref) {
    final isar = ref.watch(isarProvider);
    return CategoryRepository(isar);
  },
);

final categoryListProvider = StreamProvider.autoDispose.family<List<CategoryIsar>, CategoryType>(
  (ref, type) {
    final categoryRepo = ref.watch(categoryRepositoryIsarProvider);
    return categoryRepo._watchCategoryList(type);
  },
);
