import 'package:flutter/cupertino.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';

import '../../../../persistent/model_from_realm.dart';

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

  const CategoryTag._(super.realmObject, this.name);
}
