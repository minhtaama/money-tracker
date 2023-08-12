import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_data_store.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
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
      // If this database is user-reorderable, then we must
      // assign `order` value equal to its `Isar.autoIncrementID` at the first time
      // then update it
      newCategory.order = newCategory.id;
      await isar.categoryIsars.put(newCategory);
    });
  }

  Future<void> addTag(CategoryIsar currentCategory, {required String tag}) async {
    List<String?> list = List.of(currentCategory.tags)..insert(0, tag);
    currentCategory.tags = list;
    await isar.writeTxn(() async => await isar.categoryIsars.put(currentCategory));
  }

  Future<void> editTag(CategoryIsar currentCategory,
      {required int tagIndex, required String newTag}) async {
    currentCategory.tags[tagIndex] = newTag;
    await isar.writeTxn(() async => await isar.categoryIsars.put(currentCategory));
  }

  Future<void> removeTag(CategoryIsar currentCategory, {required int tagIndex}) async {
    currentCategory.tags[tagIndex] = null;
    await isar.writeTxn(() async => await isar.categoryIsars.put(currentCategory));
  }

  Future<void> edit(
    CategoryIsar currentCategory, {
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
    List<String>? tags,
  }) async {
    currentCategory
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..tags = tags ?? currentCategory.tags
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
}

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
