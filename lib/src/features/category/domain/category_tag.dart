import 'package:flutter/cupertino.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:realm/realm.dart';

import '../../../../persistent/base_model.dart';

@immutable
class CategoryTag extends BaseModel<CategoryTagDb> {
  final String name;

  static CategoryTag? fromDatabase(CategoryTagDb? tagRealm) {
    if (tagRealm == null) {
      return null;
    }

    return CategoryTag._(
      tagRealm,
      tagRealm.name,
    );
  }

  /// Use when user edit a transaction and remove its category tag
  static CategoryTag get noTag {
    return CategoryTag._(
      CategoryTagDb(ObjectId.fromTimestamp(Calendar.minDate), 'noTag'),
      'noTag',
    );
  }

  const CategoryTag._(super.realmObject, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTag &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          databaseObject == databaseObject;

  @override
  int get hashCode => databaseObject.hashCode ^ name.hashCode;
}
