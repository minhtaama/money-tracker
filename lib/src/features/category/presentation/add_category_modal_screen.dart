import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

class AddCategoryModalScreen extends ConsumerStatefulWidget {
  const AddCategoryModalScreen({super.key, this.initialType});

  final CategoryType? initialType;

  @override
  ConsumerState<AddCategoryModalScreen> createState() => _AddCategoryModalScreenState();
}

class _AddCategoryModalScreenState extends ConsumerState<AddCategoryModalScreen> {
  final _formKey = GlobalKey<FormState>();

  late CategoryType categoryType = widget.initialType ?? CategoryType.expense;
  String categoryName = '';
  String iconCategory = '';
  int iconIndex = 0;
  int colorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      formKey: _formKey,
      header: ModalHeader(title: 'Add Category'.hardcoded),
      body: [
        CustomSliderToggle<CategoryType>(
          values: const [CategoryType.income, CategoryType.expense],
          labels: const ['Income', 'Expense'],
          initialValueIndex: categoryType == CategoryType.expense ? 1 : 0,
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
              child: CustomTextFormField(
                autofocus: false,
                textInputAction: TextInputAction.done,
                focusColor: AppColors.allColorsUserCanPick[colorIndex][0],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Account name must not empty';
                  }
                  return null;
                },
                maxLines: 1,
                onFieldSubmitted: (_) => _formKey.currentState!.validate(),
                hintText: 'Category Name',
                onChanged: (value) {
                  setState(() {
                    categoryName = value;
                  });
                },
              ),
            ),
          ],
        ),
        Gap.h8,
        ColorSelectListView(
          onColorTap: (index) {
            setState(() {
              colorIndex = index;
            });
          },
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: categoryName == '',
        onBigButtonTap: () {
          if (_formKey.currentState!.validate()) {
            final categoryRepository = ref.read(categoryRepositoryRealmProvider);
            final category = categoryRepository.writeNew(
              type: categoryType,
              iconCategory: iconCategory,
              iconIndex: iconIndex,
              name: categoryName,
              colorIndex: colorIndex,
            );
            context.pop(category);
          }
        },
      ),
    );
  }
}
