import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class AppCategory {
  AppCategory(
      {required this.type,
      required this.id,
      required this.icon,
      required this.name,
      required this.color});

  final String id;
  final IconData icon;
  final String name;
  final Color color;
  final CategoryType type;
}
