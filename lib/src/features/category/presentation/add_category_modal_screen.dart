import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';

class AddCategoryModalScreen extends StatelessWidget {
  const AddCategoryModalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomSection(
        title: 'Add Category', isWrapByCard: false, children: [Text('Hello'), Text('Hello2')]);
  }
}
