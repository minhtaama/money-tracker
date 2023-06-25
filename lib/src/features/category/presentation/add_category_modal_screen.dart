import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class AddCategoryModalScreen extends StatefulWidget {
  const AddCategoryModalScreen({Key? key}) : super(key: key);

  @override
  State<AddCategoryModalScreen> createState() => _AddCategoryModalScreenState();
}

class _AddCategoryModalScreenState extends State<AddCategoryModalScreen> {
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
          onTap: (type) {
            print(type.toString());
          },
        ),
        Gap.h24,
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[colorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[colorIndex][1],
              onTap: (iconCategory, iconIndex) {
                print('$iconCategory, $iconIndex');
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextField(
                onChanged: (value) {
                  print(value);
                },
              ),
            ),
          ],
        ),
        Gap.h32,
        ColorSelectListView(
          onColorTap: (index) {
            print(index);
            setState(() {
              colorIndex = index;
            });
          },
        ),
        Gap.h24,
        IconWithTextButton(
          icon: AppIcons.arrowLeft,
          label: 'Create',
          backgroundColor: context.appTheme.accent,
        ),
      ],
    );
  }
}
