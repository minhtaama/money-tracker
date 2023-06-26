import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class AppCategory {
  AppCategory(
      {required this.type,
      required this.id,
      required this.index,
      required this.icon,
      required this.name,
      required this.backgroundColor,
      required this.iconColor});

  final String id;
  final IconData icon;
  final int index;
  final String name;
  final Color backgroundColor;
  final Color iconColor;
  final CategoryType type;

  @override
  String toString() {
    return 'AppCategory{id: $id, icon: $icon, index: $index, name: $name, backgroundColor: $backgroundColor, iconColor: $iconColor, type: $type}';
  }

  AppCategory copyWith({
    String? id,
    IconData? icon,
    int? index,
    String? name,
    Color? backgroundColor,
    Color? iconColor,
    CategoryType? type,
  }) {
    return AppCategory(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      index: index ?? this.index,
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      type: type ?? this.type,
    );
  }
}
