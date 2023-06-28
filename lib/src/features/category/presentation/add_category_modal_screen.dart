import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class AddCategoryModalScreen extends ConsumerStatefulWidget {
  const AddCategoryModalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCategoryModalScreen> createState() => _AddCategoryModalScreenState();
}

class _AddCategoryModalScreenState extends ConsumerState<AddCategoryModalScreen> {
  CategoryType categoryType = CategoryType.expense;
  String categoryName = '';
  String iconCategory = '';
  int iconIndex = 0;
  int colorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Add Category',
      isWrapByCard: false,
      children: [
        CustomSliderToggle<CategoryType>(
          values: const [CategoryType.income, CategoryType.expense],
          labels: const ['Income', 'Expense'],
          initialValueIndex: 1,
          onTap: (type) {
            categoryType = type;
          },
        ),
        Gap.h24,
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[colorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[colorIndex][1],
              onTap: (iconC, iconI) {
                iconCategory = iconC;
                iconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextField(
                focusColor: AppColors.allColorsUserCanPick[colorIndex][0],
                onChanged: (value) {
                  categoryName = value;
                },
              ),
            ),
          ],
        ),
        Gap.h32,
        ColorSelectListView(
          onColorTap: (index) {
            setState(() {
              colorIndex = index;
            });
          },
        ),
        Gap.h24,
        IconWithTextButton(
          icon: AppIcons.add,
          label: 'Create',
          backgroundColor: context.appTheme.accent,
          onTap: () {
            final categoryRepository = ref.read(categoryRepositoryProvider);
            categoryRepository.writeNewCategory(
              type: categoryType,
              iconCategory: iconCategory,
              iconIndex: iconIndex,
              name: categoryName,
              colorIndex: colorIndex,
            );
            context.pop();
          },
        ),
      ],
    );
  }
}
