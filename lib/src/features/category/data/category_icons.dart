import 'package:flutter/material.dart';

class CategoryIcons {
  static String get home => 'home';

  static IconData getIcon(String name) {
    switch (name) {
      case 'home':
        return Icons.home;
      default:
        return Icons.not_interested;
    }
  }
}
