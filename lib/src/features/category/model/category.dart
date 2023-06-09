import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class Category {
  Category({required this.icon, required this.name, required this.type});

  final IconData icon;
  final String name;
  final TransactionType type;

  @override
  String toString() {
    return 'Category{icon: $icon, name: $name, type: $type}';
  }

  Category copyWith({
    IconData? icon,
    String? name,
    TransactionType? type,
  }) {
    return Category(
      icon: icon ?? this.icon,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => icon.hashCode ^ name.hashCode ^ type.hashCode;
}
