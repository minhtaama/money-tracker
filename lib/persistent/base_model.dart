import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:realm/realm.dart';

@immutable
abstract class BaseModel<T extends IRealmObjectWithID> {
  const BaseModel(this._databaseObject);

  final T _databaseObject;

  T get databaseObject => _databaseObject;

  ObjectId get id => _databaseObject.id;
}

@immutable
abstract class BaseEmbeddedModel<T extends EmbeddedObject> {
  const BaseEmbeddedModel(this._databaseObject);

  final T _databaseObject;

  T get databaseObject => _databaseObject;
}

@immutable
abstract class BaseModelWithIcon<T extends IRealmObjectWithID> extends BaseModel<T> {
  const BaseModelWithIcon(super._databaseObject,
      {required this.name, required this.iconColor, required this.backgroundColor, required this.iconPath});

  final String name;
  final Color iconColor;
  final Color backgroundColor;
  final String iconPath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseModelWithIcon &&
          _databaseObject == other._databaseObject &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          iconColor == other.iconColor &&
          backgroundColor == other.backgroundColor &&
          iconPath == other.iconPath;

  @override
  int get hashCode =>
      _databaseObject.hashCode ^
      runtimeType.hashCode ^
      name.hashCode ^
      iconColor.hashCode ^
      backgroundColor.hashCode ^
      iconPath.hashCode;
}
