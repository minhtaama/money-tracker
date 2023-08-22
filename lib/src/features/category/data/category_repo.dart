import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_data_store.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class CategoryRepository {
  CategoryRepository(this.isar);

  final Isar isar;

  List<CategoryIsar> getList(CategoryType type) {
    Query<CategoryIsar> query = isar.categoryIsars.filter().typeEqualTo(type).sortByOrder().build();
    return query.findAllSync();
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

  Future<void> delete(CategoryIsar category) async {
    await isar.writeTxn(() async => await isar.categoryIsars.delete(category.id));
  }

  /// The list must be the same list displayed in the widget (with the same sort order)
  Future<void> reorder(List<CategoryIsar> list, int oldIndex, int newIndex) async {
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

  List<CategoryTagIsar>? getTagsSortedByOrder(CategoryIsar? category) {
    if (category != null) {
      return category.tags.filter().sortByOrder().build().findAllSync();
    } else {
      return null;
    }
  }

  Stream<void> _watchTagListChanges(CategoryIsar? category) {
    if (category != null) {
      Query<CategoryTagIsar> query = category.tags.filter().sortByOrder().build();
      return query.watchLazy(fireImmediately: true);
    } else {
      return const Stream.empty();
    }
  }

  Future<CategoryTagIsar?> writeNewTag({required String name, required CategoryIsar category}) async {
    final newTag = CategoryTagIsar()
      ..name = name
      ..categoryLink.value = category;

    await isar.writeTxn(() async {
      await isar.categoryTagIsars.put(newTag);
      await newTag.categoryLink.save();

      // If this database is user-reorder-able, then we must
      // assign `order` value equal to its `Isar.autoIncrementID` at the first time
      // then update it
      newTag.order = newTag.id;
      await isar.categoryTagIsars.put(newTag);
    });
    return isar.categoryTagIsars.get(newTag.id);
  }

  Future<void> editTag(CategoryTagIsar currentTag, {required String name}) async {
    currentTag.name = name;
    await isar.writeTxn(() async => await isar.categoryTagIsars.put(currentTag));
  }

  Future<void> deleteTag(CategoryTagIsar currentTag) async {
    await isar.writeTxn(() async => await isar.categoryTagIsars.delete(currentTag.id));
  }

  /// The list must be the same list displayed in the widget (sorted by order in isar database)
  Future<void> reorderTagToTop(List<CategoryTagIsar> list, int oldIndex) async {
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

final categoryTagsChangesProvider = StreamProvider.autoDispose.family<void, CategoryIsar?>(
  (ref, category) {
    final categoryRepo = ref.watch(categoryRepositoryProvider);
    return categoryRepo._watchTagListChanges(category);
  },
);
