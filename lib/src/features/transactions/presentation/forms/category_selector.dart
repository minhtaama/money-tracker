import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/enums.dart';

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({
    Key? key,
    required this.transactionType,
    required this.onChangedCategory,
  })  : assert(transactionType != TransactionType.transfer),
        super(key: key);

  final ValueChanged<CategoryIsar?> onChangedCategory;
  final TransactionType transactionType;

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  CategoryIsar? currentCategory;

  @override
  Widget build(BuildContext context) {
    return IconWithTextButton(
      label: currentCategory != null ? currentCategory!.name : 'Add Category',
      labelSize: 15,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      iconPath: currentCategory != null
          ? AppIcons.fromCategoryAndIndex(currentCategory!.iconCategory, currentCategory!.iconIndex)
          : AppIcons.add,
      backgroundColor:
          currentCategory != null ? AppColors.allColorsUserCanPick[currentCategory!.colorIndex][0] : Colors.transparent,
      color: currentCategory != null
          ? AppColors.allColorsUserCanPick[currentCategory!.colorIndex][1]
          : context.appTheme.backgroundNegative.withOpacity(0.4),
      width: null,
      height: null,
      border: currentCategory != null
          ? null
          : Border.all(
              color: context.appTheme.backgroundNegative.withOpacity(0.4),
            ),
      onTap: () async {
        List<CategoryIsar> categoryList;

        if (widget.transactionType == TransactionType.income) {
          categoryList = ref.read(categoryRepositoryProvider).getList(CategoryType.income);
        } else if (widget.transactionType == TransactionType.expense) {
          categoryList = ref.read(categoryRepositoryProvider).getList(CategoryType.expense);
        } else {
          throw ErrorDescription('Category Selector should not be displayed with Transfer-type Transaction');
        }

        final returnedValue = await showCustomModalBottomSheet<CategoryIsar>(
          context: context,
          child: categoryList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap.h16,
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Choose Category',
                        style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                      ),
                    ),
                    Gap.h16,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(categoryList.length, (index) {
                        final category = categoryList[index];
                        return IconWithTextButton(
                          iconPath: AppIcons.fromCategoryAndIndex(category.iconCategory, category.iconIndex),
                          label: category.name,
                          labelSize: 18,
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: Border.all(
                            color: currentCategory?.id == category.id
                                ? AppColors.allColorsUserCanPick[category.colorIndex][0]
                                : context.appTheme.backgroundNegative.withOpacity(0.4),
                          ),
                          backgroundColor: currentCategory?.id == category.id
                              ? AppColors.allColorsUserCanPick[category.colorIndex][0]
                              : Colors.transparent,
                          color: currentCategory?.id == category.id
                              ? AppColors.allColorsUserCanPick[category.colorIndex][1]
                              : context.appTheme.backgroundNegative,
                          onTap: () => context.pop<CategoryIsar>(category),
                          height: null,
                          width: null,
                        );
                      }),
                    ),
                    Gap.h32,
                  ],
                )
              : Text('NO CATEGORY'),
          //TODO: Create an empty list widget
        );

        setState(() {
          if (returnedValue != null) {
            if (currentCategory != null && currentCategory!.id == returnedValue.id) {
              currentCategory = null;
              widget.onChangedCategory(currentCategory);
            } else {
              currentCategory = returnedValue;
              widget.onChangedCategory(currentCategory);
            }
          }
        });
      },
    );
  }
}
