import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../domain/category_isar.dart';
import 'category_list_tile.dart';
import 'edit_category_modal_screen.dart';

class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryRepository = ref.watch(categoryRepositoryIsarProvider);
    final incomeAppCategoriesList = ref.watch(categoryListProvider(CategoryType.income));
    final expenseAppCategoriesList = ref.watch(categoryListProvider(CategoryType.expense));

    List<Widget> getTiles(BuildContext context, CategoryType type) {
      final list = type == CategoryType.income ? incomeAppCategoriesList : expenseAppCategoriesList;
      final asyncValue = list.whenData(
        (data) => data.isNotEmpty
            ? List.generate(
                data.length,
                (index) {
                  CategoryIsar model = data[index];
                  return CategoryListTile(
                    key: ValueKey(index),
                    icon: AppIcons.fromCategoryAndIndex(model.iconCategory, model.iconIndex),
                    backgroundColor: AppColors.allColorsUserCanPick[model.colorIndex][0],
                    iconColor: AppColors.allColorsUserCanPick[model.colorIndex][1],
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
                  style: kHeader2TextStyle.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center,
                )
              ],
      );
      return asyncValue.value ?? [];
    }

    return Scaffold(
      backgroundColor: context.appTheme.background,
      body: CustomTabPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            hasBackButton: true,
            title: 'Categories',
            trailing: RoundedIconButton(
              icon: AppIcons.add,
              iconPadding: 8,
              iconColor: context.appTheme.backgroundNegative,
              backgroundColor: context.appTheme.background3,
              onTap: () => context.push(RoutePath.addCategory),
            ),
          ),
        ),
        children: [
          CustomSection(
            title: 'Income',
            onReorder: (oldIndex, newIndex) {
              categoryRepository.reorderCategory(
                  incomeAppCategoriesList.asData!.value, oldIndex, newIndex);
            },
            children: getTiles(context, CategoryType.income),
          ),
          CustomSection(
            title: 'Expense',
            onReorder: (oldIndex, newIndex) {
              categoryRepository.reorderCategory(
                  expenseAppCategoriesList.asData!.value, oldIndex, newIndex);
            },
            children: getTiles(context, CategoryType.expense),
          )
        ],
      ),
    );
  }
}
