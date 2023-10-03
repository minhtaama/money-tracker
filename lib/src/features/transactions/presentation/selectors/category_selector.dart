import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../../common_widgets/empty_info.dart';
import '../../../../common_widgets/modal_bottom_sheets.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/enums.dart';

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({
    Key? key,
    required this.transactionType,
    required this.onChangedCategory,
  })  : assert(transactionType != TransactionType.transfer),
        super(key: key);

  final ValueChanged<Category?> onChangedCategory;
  final TransactionType transactionType;

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  Category? currentCategory;

  @override
  Widget build(BuildContext context) {
    return IconWithTextButton(
      label: currentCategory != null ? currentCategory!.name : 'Add Category',
      labelSize: 15,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      iconPath: currentCategory != null ? currentCategory!.iconPath : AppIcons.add,
      backgroundColor: currentCategory != null ? currentCategory!.backgroundColor : Colors.transparent,
      color: currentCategory != null ? currentCategory!.color : context.appTheme.backgroundNegative.withOpacity(0.4),
      width: null,
      height: null,
      border: currentCategory != null
          ? null
          : Border.all(
              color: context.appTheme.backgroundNegative.withOpacity(0.4),
            ),
      onTap: () async {
        List<Category> categoryList;
        if (widget.transactionType == TransactionType.income) {
          categoryList = ref.read(categoryRepositoryRealmProvider).getList(CategoryType.income);
        } else if (widget.transactionType == TransactionType.expense) {
          categoryList = ref.read(categoryRepositoryRealmProvider).getList(CategoryType.expense);
        } else {
          throw ErrorDescription('Category Selector should not be displayed with Transfer-type Transaction');
        }

        final returnedValue = await showCustomModalBottomSheet<Category>(
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
                          iconPath: category.iconPath,
                          label: category.name,
                          labelSize: 18,
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: Border.all(
                            color: currentCategory?.databaseObject.id == category.databaseObject.id
                                ? category.backgroundColor
                                : context.appTheme.backgroundNegative.withOpacity(0.4),
                          ),
                          backgroundColor: currentCategory?.databaseObject.id == category.databaseObject.id
                              ? category.backgroundColor
                              : Colors.transparent,
                          color: currentCategory?.databaseObject.id == category.databaseObject.id
                              ? category.color
                              : context.appTheme.backgroundNegative,
                          onTap: () => context.pop<Category>(category),
                          height: null,
                          width: null,
                        );
                      }),
                    ),
                    Gap.h32,
                    Gap.h32,
                  ],
                )
              : Column(
                  children: [
                    Gap.h8,
                    EmptyInfo(
                      infoText:
                          'No ${widget.transactionType == TransactionType.income ? 'income' : 'expense'} category.\n Tap here to create a first one'
                              .hardcoded,
                      textSize: 14,
                      iconPath: AppIcons.accounts,
                      onTap: () => context.push(RoutePath.addCategory),
                    ),
                    Gap.h48,
                  ],
                ),
          //TODO: Create an empty list widget
        );

        setState(() {
          if (returnedValue != null) {
            if (currentCategory != null && currentCategory!.databaseObject.id == returnedValue.databaseObject.id) {
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
