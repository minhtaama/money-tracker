import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

@immutable
abstract class ModelFromRealm<T extends RealmObject> {
  const ModelFromRealm(this._realmObject);

  final T _realmObject;

  T get realmObject => _realmObject;
}

abstract class EmbeddedModelFromRealm<T extends EmbeddedObject> {
  const EmbeddedModelFromRealm(this._realmObject);

  final T _realmObject;

  T get realmObject => _realmObject;
}

@immutable
abstract class ModelFromRealmWithIcon<T extends RealmObject> extends ModelFromRealm<T> {
  const ModelFromRealmWithIcon(super._realmObject,
      {required this.name, required this.color, required this.backgroundColor, required this.iconPath});

  final String name;
  final Color color;
  final Color backgroundColor;
  final String iconPath;
}
