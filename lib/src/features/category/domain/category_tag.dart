import 'package:flutter/cupertino.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';

import '../../../../persistent/model_from_realm.dart';

@immutable
class CategoryTag extends ModelFromRealm<CategoryTagRealm> {
  final String name;

  static CategoryTag? fromRealm(CategoryTagRealm? tagRealm) {
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
