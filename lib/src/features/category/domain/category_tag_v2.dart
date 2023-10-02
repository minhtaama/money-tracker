import 'package:flutter/cupertino.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';

import '../../../../persistent/model_from_realm.dart';

@immutable
class CategoryTagV2 extends ModelFromRealm<CategoryTagRealm> {
  final String name;

  static CategoryTagV2? fromRealm(CategoryTagRealm? tagRealm) {
    if (tagRealm == null) {
      return null;
    }

    return CategoryTagV2._(
      tagRealm,
      tagRealm.name,
    );
  }

  const CategoryTagV2._(super.realmObject, this.name);
}
