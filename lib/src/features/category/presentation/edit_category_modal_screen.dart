import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../data/category_repo.dart';

class EditCategoryModalScreen extends ConsumerStatefulWidget {
  const EditCategoryModalScreen(this.currentCategory, {super.key});

  final Category currentCategory;

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
    newName = widget.currentCategory.name;
    newIconCategory = widget.currentCategory.databaseObject.iconCategory;
    newIconIndex = widget.currentCategory.databaseObject.iconIndex;
    newColorIndex = widget.currentCategory.databaseObject.colorIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      header: ModalHeader(
        title: 'Edit Category'.hardcoded,
      ),
      body: [
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[newColorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[newColorIndex][1],
              initialIconCategory: widget.currentCategory.databaseObject.iconCategory,
              initialIconIndex: widget.currentCategory.databaseObject.iconIndex,
              onTap: (iconC, iconI) {
                newIconCategory = iconC;
                newIconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextFormField(
                autofocus: false,
                focusColor: AppColors.allColorsUserCanPick[newColorIndex][0],
                hintText: widget.currentCategory.name,
                onChanged: (value) {
                  newName = value;
                },
              ),
            ),
          ],
        ),
        Gap.h24,
        ColorSelectListView(
          initialColorIndex: widget.currentCategory.databaseObject.colorIndex,
          onColorTap: (index) {
            setState(() {
              newColorIndex = index;
            });
          },
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: false,
        smallButtonIcon: AppIcons.delete,
        onSmallButtonTap: () {
          showConfirmModal(
            context: context,
            label: 'Are you sure that you want to delete "${widget.currentCategory.name}"?',
            onConfirm: () {
              final categoryRepository = ref.read(categoryRepositoryRealmProvider);
              categoryRepository.delete(widget.currentCategory);
              context.pop();
            },
          );
        },
        onBigButtonTap: () async {
          final categoryRepository = ref.read(categoryRepositoryRealmProvider);
          categoryRepository.edit(
            widget.currentCategory,
            iconCategory: newIconCategory,
            iconIndex: newIconIndex,
            name: newName,
            colorIndex: newColorIndex,
          );
          if (mounted) {
            context.pop();
          }
        },
      ),
    );
  }
}
