import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:realm/realm.dart';
import '../domain/category_tag.dart';

class CategoryRepositoryRealmDb {
  CategoryRepositoryRealmDb(this.realm);

  final Realm realm;

  int _categoryTypeInDb(CategoryType type) => switch (type) {
        CategoryType.expense => 0,
        CategoryType.income => 1,
      };

  RealmResults<CategoryDb> _realmResults(CategoryType type) {
    return realm.all<CategoryDb>().query('type == \$0 SORT(order ASC)', [_categoryTypeInDb(type)]);
  }

  RealmResults<CategoryTagDb> _tagRealmResults(Category category) {
    return realm.all<CategoryTagDb>().query('category == \$0 SORT(order ASC)', [category.databaseObject]);
  }

  //// CATEGORY ////

  List<Category> getList(CategoryType type) {
    return _realmResults(type).map((categoryDb) => Category.fromDatabase(categoryDb)!).toList();
  }

  Stream<RealmResultsChanges<CategoryDb>> _watchListChanges(CategoryType type) {
    return realm.all<CategoryDb>().changes;
  }

  void writeNew({
    required CategoryType type,
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
  }) {
    final order = getList(type).length;

    final newCategory = CategoryDb(
      ObjectId(),
      _categoryTypeInDb(type),
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
    Category currentCategory, {
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
  }) {
    final categoryDb = currentCategory.databaseObject;

    realm.write(
      () => categoryDb
        ..iconCategory = iconCategory
        ..iconIndex = iconIndex
        ..name = name
        ..colorIndex = colorIndex,
    );
  }

  void delete(Category category) {
    realm.write(() async => realm.delete(category.databaseObject));
  }

  void reorder(CategoryType type, int oldIndex, int newIndex) {
    final list = _realmResults(type).toList();

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    realm.write(
      () {
        // Recreate order to query sort by this property
        for (int i = 0; i < list.length; i++) {
          list[i].order = i;
        }
      },
    );
  }

  //// CATEGORY TAG ////

  List<CategoryTag>? getTagList(Category? category) {
    if (category == null) {
      return null;
    }

    return _tagRealmResults(category).map((tagRealm) => CategoryTag.fromDatabase(tagRealm)!).toList();
  }

  Stream<RealmResultsChanges<CategoryTagDb>> _watchTagListChanges(Category? category) {
    if (category == null) {
      return const Stream.empty();
    }

    return realm.all<CategoryTagDb>().query('category == \$0', [category.databaseObject]).changes;
  }

  CategoryTag? writeNewTag({required String name, required Category category}) {
    final tagsList = getTagList(category)!;

    final newTag = CategoryTagDb(ObjectId(), name, order: tagsList.length, category: category.databaseObject);

    realm.write(() {
      realm.add<CategoryTagDb>(newTag);
    });

    return CategoryTag.fromDatabase(newTag);
  }

  void editTag(CategoryTag currentTag, {required String name}) {
    realm.write(() => currentTag.databaseObject.name = name);
  }

  void deleteTag(CategoryTag currentTag) {
    realm.write(() => realm.delete(currentTag.databaseObject));
  }

  /// The list must be the same list displayed in the widget (sorted by order in isar database)
  void reorderTagToTop(Category category, int oldIndex) {
    final list = _tagRealmResults(category).toList();

    if (list.length >= 2) {
      final item = list.removeAt(oldIndex);
      list.insert(0, item);
    }

    realm.write(
      () {
        // Recreate order to query sort by this property
        for (int i = 0; i < list.length; i++) {
          list[i].order = i;
        }
      },
    );
  }
}

//////////////////////////// PROVIDERS ////////////////////////

final categoryRepositoryRealmProvider = Provider<CategoryRepositoryRealmDb>(
  (ref) {
    final realm = ref.watch(realmProvider);
    return CategoryRepositoryRealmDb(realm);
  },
);

final categoriesChangesRealmProvider = StreamProvider.autoDispose.family<RealmResultsChanges<CategoryDb>, CategoryType>(
  (ref, type) {
    final categoryRepo = ref.watch(categoryRepositoryRealmProvider);
    return categoryRepo._watchListChanges(type);
  },
);

final categoryTagsChangesRealmProvider =
    StreamProvider.autoDispose.family<RealmResultsChanges<CategoryTagDb>, Category?>(
  (ref, category) {
    final categoryRepo = ref.watch(categoryRepositoryRealmProvider);
    return categoryRepo._watchTagListChanges(category);
  },
);
