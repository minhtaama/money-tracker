import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/tab_page/presentation/custom_tab_page/custom_tab_page.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(children: [
      Container(
        color: Colors.yellow,
        width: 200,
        height: 300,
      ),
      Container(
        color: Colors.teal,
        width: 200,
        height: 300,
      ),
      Container(
        color: Colors.red,
        width: 200,
        height: 300,
      ),
    ]);
  }
}
