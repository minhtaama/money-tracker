import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/category/domain/category_v2.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:realm/realm.dart';

import '../../../../persistent/isar_data_store.dart';
import '../domain/category_tag.dart';
import '../domain/category_tag_v2.dart';
import 'isar_dto/category_isar.dart';
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

////////////////////////////////////////// REALM REPOSITORY //////////////////////////////

class CategoryRepositoryV2 {
  CategoryRepositoryV2(this.realm);

  final Realm realm;

  int _categoryTypeInRealm(CategoryType type) => switch (type) {
        CategoryType.expense => 0,
        CategoryType.income => 1,
      };

  RealmResults<CategoryRealm> _realmResults(CategoryType type) {
    return realm.all<CategoryRealm>().query('type == \$0 SORT(order ASC)', [_categoryTypeInRealm(type)]);
  }

  RealmResults<CategoryTagRealm> _tagRealmResults(CategoryV2 category) {
    return realm.all<CategoryTagRealm>().query('category == \$0 SORT(order ASC)', [category.realmObject]);
  }

  //// CATEGORY ////

  List<CategoryV2> getList(CategoryType type) {
    return _realmResults(type).map((categoryRealm) => CategoryV2.fromRealm(categoryRealm)!).toList();
  }

  Stream<RealmResultsChanges<CategoryRealm>> _watchListChanges(CategoryType type) {
    return realm.all<CategoryRealm>().changes;
  }

  void writeNew({
    required CategoryType type,
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
  }) {
    final order = getList(type).length;

    final newCategory = CategoryRealm(
      ObjectId(),
      _categoryTypeInRealm(type),
      name,
      colorIndex,
      iconCategory,
      iconIndex,
      order: order,
    );

    realm.write(() {
      realm.add(newCategory);
    });
  }

  void edit(
    CategoryV2 currentCategory, {
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
  }) {
    final categoryRealm = currentCategory.realmObject;

    categoryRealm
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..colorIndex = colorIndex;

    realm.write(() => realm.add(categoryRealm, update: true));
  }

  void delete(CategoryV2 category) {
    realm.write(() async => realm.delete(category.realmObject));
  }

  void reorder(CategoryType type, int oldIndex, int newIndex) {
    final list = _realmResults(type).toList();

    realm.write(
      () {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = list.removeAt(oldIndex);
        list.insert(newIndex, item);

        // Recreate order to query sort by this property
        for (int i = 0; i < list.length; i++) {
          list[i].order = i;
        }
      },
    );
  }

  //// CATEGORY TAG ////

  List<CategoryTagV2> getTagList(CategoryV2 category) {
    return _tagRealmResults(category).map((tagRealm) => CategoryTagV2.fromRealm(tagRealm)!).toList();
  }

  Stream<RealmResultsChanges<CategoryTagRealm>> _watchTagListChanges(CategoryV2 category) {
    return realm.all<CategoryTagRealm>().query('category == \$0', [category.realmObject]).changes;
  }

  CategoryTagV2? writeNewTag({required String name, required CategoryV2 category}) {
    final tagsList = category.tags;

    final newTag = CategoryTagRealm(ObjectId(), name, order: tagsList.length, category: category.realmObject);

    realm.write(() {
      realm.add<CategoryTagRealm>(newTag);
    });

    return CategoryTagV2.fromRealm(newTag);
  }

  void editTag(CategoryTagV2 currentTag, {required String name}) {
    realm.write(() => currentTag.realmObject.name = name);
  }

  void deleteTag(CategoryTagV2 currentTag) {
    realm.write(() => realm.delete(currentTag.realmObject));
  }

  /// The list must be the same list displayed in the widget (sorted by order in isar database)
  Future<void> reorderTagToTop(CategoryV2 category, int oldIndex) async {
    final list = _tagRealmResults(category).toList();

    realm.write(
      () {
        final item = list.removeAt(oldIndex);
        list.insert(0, item);

        // Recreate order to query sort by this property
        for (int i = 0; i < list.length; i++) {
          list[i].order = i;
        }
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

final categoryRepositoryProviderV2 = Provider<CategoryRepositoryV2>(
  (ref) {
    final realm = ref.watch(realmProvider);
    return CategoryRepositoryV2(realm);
  },
);

final categoriesChangesProviderV2 = StreamProvider.autoDispose.family<RealmResultsChanges<CategoryRealm>, CategoryType>(
  (ref, type) {
    final categoryRepo = ref.watch(categoryRepositoryProviderV2);
    return categoryRepo._watchListChanges(type);
  },
);

final categoryTagsChangesProviderV2 =
    StreamProvider.autoDispose.family<RealmResultsChanges<CategoryTagRealm>, CategoryV2>(
  (ref, category) {
    final categoryRepo = ref.watch(categoryRepositoryProviderV2);
    return categoryRepo._watchTagListChanges(category);
  },
);
