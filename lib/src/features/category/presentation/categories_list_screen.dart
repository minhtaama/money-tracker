// TODO: Implement Categories screen with data from Hive
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_bar.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeCategoriesList = ref.watch(categoryListProvider(CategoryType.income));
    //final expenseCategoriesList = ref.watch(categoryListProvider(CategoryType.expense));
    return Scaffold(
      body: CustomTabPage(
          customTabBar: CustomTabBar(
            smallTabBar: SmallTabBar(
              child: PageHeading(
                hasBackButton: true,
                title: 'Categories',
                trailing: RoundedIconButton(
                  icon: Icons.add,
                  iconColor: context.appTheme.backgroundNegative,
                  backgroundColor: context.appTheme.background3,
                ),
              ),
            ),
          ),
          children: [
            CustomSection(title: 'Income', children: [Text(incomeCategoriesList.length.toString())]),
            CustomSection(title: 'Expense', children: [])
          ]),
    );
  }
}
