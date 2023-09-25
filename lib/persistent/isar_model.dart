import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

@immutable
abstract class IsarModel<T extends IsarCollectionObject> {
  const IsarModel(
    this._isarObject,
  );

  final T _isarObject;

  int get id => _isarObject.id;

  T get isarObject => _isarObject;
}

abstract class IsarModelWithIcon<T extends IsarCollectionObject> extends IsarModel<T> {
  const IsarModelWithIcon(super.isarObject,
      {required this.name, required this.color, required this.backgroundColor, required this.iconPath});

  final String name;
  final Color color;
  final Color backgroundColor;
  final String iconPath;
}

/// Only extends this object if sub-class is a [@collection] of Isar Database
abstract class IsarCollectionObject {
  Id id = Isar.autoIncrement;
}

/////////// FOR V2 HERE /////////////////////////

abstract interface class IsarCollectionColorAndIcon {
  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;
}

abstract interface class IsarCollectionWithCategory {}

abstract interface class IsarCollectionDateTime {
  late DateTime dateTime;
}

abstract interface class IsarCollectionOrderable {
  int? order;
}
