// TODO: Implement Categories screen with data from Hive
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/category/domain/app_category.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeCategoriesList = ref.watch(incomeCategoryListProvider);
    final expenseCategoriesList = ref.watch(expenseCategoryListProvider);
    return Scaffold(
      backgroundColor: context.appTheme.background,
      body: CustomTabPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            hasBackButton: true,
            title: 'Categories',
            trailing: RoundedIconButton(
              icon: Icons.add,
              iconColor: context.appTheme.backgroundNegative,
              backgroundColor: context.appTheme.background3,
              onTap: () => context.push(RoutePath.addCategory),
            ),
          ),
        ),
        children: [
          CustomSection(
            title: 'Income',
            children: List.generate(
              incomeCategoriesList.length,
              (index) {
                AppCategory category = incomeCategoriesList[index];
                return CategoryListTile(
                    icon: category.icon,
                    backgroundColor: category.backgroundColor,
                    iconColor: category.iconColor,
                    name: category.name,
                    index: category.index);
              },
            ),
          ),
          CustomSection(
            title: 'Expense',
            children: List.generate(
              expenseCategoriesList.length,
              (index) {
                AppCategory category = expenseCategoriesList[index];
                return CategoryListTile(
                    icon: category.icon,
                    backgroundColor: category.backgroundColor,
                    iconColor: category.iconColor,
                    name: category.name,
                    index: category.index);
              },
            ),
          )
        ],
      ),
    );
  }
}

class CategoryListTile extends StatelessWidget {
  const CategoryListTile(
      {Key? key,
      required this.icon,
      required this.backgroundColor,
      required this.iconColor,
      required this.name,
      required this.index})
      : super(key: key);
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String name;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundedIconButton(
          icon: icon,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
        Gap.w16,
        Expanded(
          child: Text(
            name,
            style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative),
          ),
        ),
        Gap.w8,
        Icon(Icons.edit, color: context.appTheme.backgroundNegative),
      ],
    );
  }
}
