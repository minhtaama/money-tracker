import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

@immutable
abstract class BaseModel<T extends RealmObject> {
  const BaseModel(this._databaseObject);

  final T _databaseObject;

  T get databaseObject => _databaseObject;
}

// abstract class BaseEmbeddedModel<T extends EmbeddedObject> {
//   const BaseEmbeddedModel(this._databaseObject);
//
//   final T _databaseObject;
//
//   T get databaseObject => _databaseObject;
// }

@immutable
abstract class BaseModelWithIcon<T extends RealmObject> extends BaseModel<T> {
  const BaseModelWithIcon(super._databaseObject,
      {required this.name,
      required this.iconColor,
      required this.backgroundColor,
      required this.iconPath});

  final String name;
  final Color iconColor;
  final Color backgroundColor;
  final String iconPath;
}
