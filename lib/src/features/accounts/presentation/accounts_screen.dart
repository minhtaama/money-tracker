import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import '../../category/model/income_category.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hiveStore = HiveDataStore();
    return ValueListenableBuilder(
      valueListenable: hiveStore.incomeCategoriesListenable(),
      builder: (_, box, __) {
        List<IncomeCategory> categories = box.values.toList();
        return CustomTabPage(
          children: List.generate(
            categories.length,
            (index) => Text(
              categories[index].toString(),
            ),
          ),
        );
      },
    );
  }
}
