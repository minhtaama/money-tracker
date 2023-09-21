import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_data_store.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

import 'isar_dto/category_tag_isar.dart';

class CategoryRepository {
  CategoryRepository(this.isar);

  final Isar isar;

  List<Category> getList(CategoryType type) {
    List<CategoryIsar> list = isar.categoryIsars.filter().typeEqualTo(type).sortByOrder().build().findAllSync();
    return list.map((categoryIsar) => Category.fromIsar(categoryIsar)!).toList();
  }

  Stream<void> _watchListChanges(CategoryType type) {
    Query<CategoryIsar> query = isar.categoryIsars.filter().typeEqualTo(type).sortByOrder().build();
    return query.watchLazy(fireImmediately: true);
  }

  Future<void> writeNew({
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
      // If this database is user-reorder-able, then we must
      // assign `order` value equal to its `Isar.autoIncrementID` at the first time
      // then update it
      newCategory.order = newCategory.id;
      await isar.categoryIsars.put(newCategory);
    });
  }

  Future<void> edit(
    Category currentCategory, {
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
  }) async {
    final categoryIsar = currentCategory.isarObject;

    categoryIsar
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..colorIndex = colorIndex;

    await isar.writeTxn(() async => await isar.categoryIsars.put(categoryIsar));
  }

  Future<void> delete(Category category) async {
    await isar.writeTxn(() async => await isar.categoryIsars.delete(category.id));
  }

  /// The list must be the same list displayed in the widget (with the same sort order)
  Future<void> reorder(CategoryType type, int oldIndex, int newIndex) async {
    final List<CategoryIsar> list = isar.categoryIsars.filter().typeEqualTo(type).sortByOrder().build().findAllSync();
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

  ////////////////// CATEGORY TAG //////////////

  List<CategoryTag>? getTagsSortedByOrder(Category? category) {
    if (category != null) {
      List<CategoryTagIsar> list = category.isarObject.tags.filter().sortByOrder().build().findAllSync();
      return list.map((e) => CategoryTag.fromIsar(e)!).toList();
    } else {
      return null;
    }
  }

  Stream<void> _watchTagListChanges(Category? category) {
    if (category != null) {
      Query<CategoryTagIsar> query = category.isarObject.tags.filter().sortByOrder().build();
      return query.watchLazy(fireImmediately: true);
    } else {
      return const Stream.empty();
    }
  }

  Future<CategoryTag?> writeNewTag({required String name, required Category category}) async {
    final newTag = CategoryTagIsar()
      ..name = name
      ..categoryLink.value = category.isarObject;

    await isar.writeTxn(() async {
      await isar.categoryTagIsars.put(newTag);
      await newTag.categoryLink.save();

      // If this database is user-reorder-able, then we must
      // assign `order` value equal to its `Isar.autoIncrementID` at the first time
      // then update it
      newTag.order = newTag.id;
      await isar.categoryTagIsars.put(newTag);
    });
    return CategoryTag.fromIsar(isar.categoryTagIsars.getSync(newTag.id));
  }

  Future<void> editTag(CategoryTag currentTag, {required String name}) async {
    final categoryTagIsar = currentTag.isarObject;
    categoryTagIsar.name = name;
    await isar.writeTxn(() async => await isar.categoryTagIsars.put(categoryTagIsar));
  }

  Future<void> deleteTag(CategoryTag currentTag) async {
    await isar.writeTxn(() async => await isar.categoryTagIsars.delete(currentTag.id));
  }

  /// The list must be the same list displayed in the widget (sorted by order in isar database)
  Future<void> reorderTagToTop(Category category, int oldIndex) async {
    final list = category.isarObject.tags.filter().sortByOrder().build().findAllSync();
    if (list.length <= 1) {
      return;
    }

    await isar.writeTxn(
      () async {
        // Move item up the list
        int temp = list[0].order!;
        for (int i = 0; i < oldIndex; i++) {
          list[i].order = list[i + 1].order;
          isar.categoryTagIsars.put(list[i]);
        }
        list[oldIndex].order = temp;
        isar.categoryTagIsars.put(list[oldIndex]);
      },
    );
  }
}

//////////////////////////// PROVIDERS ////////////////////////

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) {
    final isar = ref.watch(isarProvider);
    return CategoryRepository(isar);
  },
);

final categoriesChangesProvider = StreamProvider.autoDispose.family<void, CategoryType>(
  (ref, type) {
    final categoryRepo = ref.watch(categoryRepositoryProvider);
    return categoryRepo._watchListChanges(type);
  },
);

final categoryTagsChangesProvider = StreamProvider.autoDispose.family<void, Category?>(
  (ref, category) {
    final categoryRepo = ref.watch(categoryRepositoryProvider);
    return categoryRepo._watchTagListChanges(category);
  },
);
