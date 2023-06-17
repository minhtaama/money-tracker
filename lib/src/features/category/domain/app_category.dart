import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class AppCategory {
  AppCategory(
      {required this.type,
      required this.id,
      required this.index,
      required this.icon,
      required this.name,
      required this.color});

  final String id;
  final IconData icon;
  final int index;
  final String name;
  final Color color;
  final CategoryType type;

  AppCategory copyWith({
    String? id,
    IconData? icon,
    int? index,
    String? name,
    Color? color,
    CategoryType? type,
  }) {
    return AppCategory(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      index: index ?? this.index,
      name: name ?? this.name,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}
