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

/// Only extends this object if sub-class is a Collection of Isar Database
abstract class IsarCollectionObject {
  Id id = Isar.autoIncrement;
}
