import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/category/domain/category_hive_model.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class EditCategoryModalScreen extends ConsumerStatefulWidget {
  const EditCategoryModalScreen(this.currentHiveModel, {required this.index, Key? key})
      : super(key: key);
  final CategoryHiveModel currentHiveModel;
  final int index;

  @override
  ConsumerState<EditCategoryModalScreen> createState() => _EditCategoryModalScreenState();
}

class _EditCategoryModalScreenState extends ConsumerState<EditCategoryModalScreen> {
  late String newName;
  late String newIconCategory;
  late int newIconIndex;
  late int newColorIndex;

  @override
  void initState() {
    newName = widget.currentHiveModel.name;
    newIconCategory = widget.currentHiveModel.iconCategory;
    newIconIndex = widget.currentHiveModel.iconIndex;
    newColorIndex = widget.currentHiveModel.colorIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Edit Category',
      isWrapByCard: false,
      children: [
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[newColorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[newColorIndex][1],
              initialCategory: widget.currentHiveModel.iconCategory,
              initialIconIndex: widget.currentHiveModel.iconIndex,
              onTap: (iconC, iconI) {
                newIconCategory = iconC;
                newIconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextField(
                autofocus: false,
                focusColor: AppColors.allColorsUserCanPick[newColorIndex][0],
                hintText: widget.currentHiveModel.name,
                onChanged: (value) {
                  newName = value;
                },
              ),
            ),
          ],
        ),
        Gap.h32,
        ColorSelectListView(
          initialColorIndex: widget.currentHiveModel.colorIndex,
          onColorTap: (index) {
            setState(() {
              newColorIndex = index;
            });
          },
        ),
        Gap.h24,
        Row(
          children: [
            RoundedIconButton(
              size: 55,
              icon: AppIcons.delete,
              iconPadding: 15,
              backgroundColor: AppColors.grey,
              iconColor: context.appTheme.backgroundNegative,
              onTap: () {
                showConfirmModalBottomSheet(
                  context: context,
                  label: 'Are you sure that you want to delete "${widget.currentHiveModel.name}"?',
                  onConfirm: () {
                    final categoryRepository = ref.read(categoryRepositoryProvider);
                    categoryRepository.deleteCategory(
                        type: widget.currentHiveModel.type, index: widget.index);
                    context.pop();
                  },
                );
              },
            ),
            const Expanded(child: SizedBox()),
            IconWithTextButton(
              icon: AppIcons.edit,
              label: 'Done',
              backgroundColor: context.appTheme.accent,
              onTap: () {
                final categoryRepository = ref.read(categoryRepositoryProvider);
                categoryRepository.editCategory(
                  type: widget.currentHiveModel.type,
                  index: widget.index,
                  newValue: widget.currentHiveModel.copyWith(
                    name: newName,
                    iconCategory: newIconCategory,
                    iconIndex: newIconIndex,
                    colorIndex: newColorIndex,
                  ),
                );
                context.pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}
