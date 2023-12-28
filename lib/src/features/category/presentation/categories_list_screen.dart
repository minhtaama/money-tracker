import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import 'category_list_tile.dart';
import 'edit_category_modal_screen.dart';

class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryRepository = ref.watch(categoryRepositoryRealmProvider);

    List<Category> incomeList = categoryRepository.getList(CategoryType.income);
    List<Category> expenseList = categoryRepository.getList(CategoryType.expense);

    ref.watch(categoriesChangesRealmProvider(CategoryType.income)).whenData((_) {
      incomeList = categoryRepository.getList(CategoryType.income);
    });

    ref.watch(categoriesChangesRealmProvider(CategoryType.expense)).whenData((_) {
      expenseList = categoryRepository.getList(CategoryType.expense);
    });

    List<Widget> buildCategoryTiles(BuildContext context, CategoryType type) {
      List<Category> list = type == CategoryType.income ? incomeList : expenseList;
      return list.isNotEmpty
          ? List.generate(
              list.length,
              (index) {
                Category model = list[index];
                return CategoryListTile(
                  key: ValueKey(index),
                  iconPath: model.iconPath,
                  backgroundColor: model.backgroundColor,
                  iconColor: model.iconColor,
                  name: model.name,
                  onMenuTap: () {
                    showCustomModalBottomSheet(
                      context: context,
                      child: EditCategoryModalScreen(model),
                    );
                  },
                );
              },
            )
          : [
              Text(
                'Nothing in here.\nPlease add a new category',
                style: kHeader2TextStyle.copyWith(color: AppColors.grey(context)),
                textAlign: TextAlign.center,
              )
            ];
    }

    return Scaffold(
      backgroundColor: context.appTheme.background500,
      body: CustomTabPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            hasBackButton: true,
            title: 'Categories',
            trailing: RoundedIconButton(
              iconPath: AppIcons.add,
              iconColor: context.appTheme.onBackground,
              backgroundColor: context.appTheme.background400,
              onTap: () => context.push(RoutePath.addCategory),
            ),
          ),
        ),
        children: [
          CustomSection(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            title: 'Income',
            onReorder: (oldIndex, newIndex) {
              categoryRepository.reorder(CategoryType.income, oldIndex, newIndex);
            },
            sections: buildCategoryTiles(context, CategoryType.income),
          ),
          CustomSection(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            title: 'Expense',
            onReorder: (oldIndex, newIndex) {
              categoryRepository.reorder(CategoryType.expense, oldIndex, newIndex);
            },
            sections: buildCategoryTiles(context, CategoryType.expense),
          )
        ],
      ),
    );
  }
}
