import 'package:flutter/material.dart';

class CategoryIcons {
  static IconData get home => Icons.home;

  static IconData getIconFromName(String name) {
    switch (name) {
      case 'home':
        return Icons.home;
      default:
        return Icons.not_interested;
    }
  }
}
