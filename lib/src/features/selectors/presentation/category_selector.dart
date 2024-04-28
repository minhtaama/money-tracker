import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/category/presentation/add_category_modal_screen.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/icon_with_text.dart';
import '../../../common_widgets/modal_and_dialog.dart';
import '../../../common_widgets/modal_screen_components.dart';
import '../../../routing/app_router.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({
    super.key,
    required this.transactionType,
    this.initialValue,
    required this.onChangedCategory,
  }) : assert(transactionType != TransactionType.transfer);

  final ValueChanged<Category?> onChangedCategory;
  final Category? initialValue;
  final TransactionType transactionType;

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  late Category? _currentCategory = widget.initialValue;

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    if (widget.initialValue != oldWidget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _currentCategory = widget.initialValue;
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return IconWithTextButton(
      label: _currentCategory != null ? _currentCategory!.name : 'Add Category',
      labelSize: 15,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      iconPath: _currentCategory != null ? _currentCategory!.iconPath : AppIcons.add,
      backgroundColor: _currentCategory != null ? _currentCategory!.backgroundColor : Colors.transparent,
      color: _currentCategory != null
          ? _currentCategory!.iconColor
          : context.appTheme.onBackground.withOpacity(0.4),
      width: null,
      height: null,
      border: _currentCategory != null
          ? null
          : Border.all(
              color: context.appTheme.onBackground.withOpacity(0.4),
            ),
      onTap: () async {
        List<Category> categoryList;
        if (widget.transactionType == TransactionType.income) {
          categoryList = ref.read(categoryRepositoryRealmProvider).getList(CategoryType.income);
        } else if (widget.transactionType == TransactionType.expense) {
          categoryList = ref.read(categoryRepositoryRealmProvider).getList(CategoryType.expense);
        } else {
          throw ErrorDescription(
              'Category Selector should not be displayed with Transfer-type Transaction');
        }

        final returnedValue = await showCustomModal<Category>(
          context: context,
          child: categoryList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ModalHeader(
                      withBackButton: false,
                      title: 'Choose Category'.hardcoded,
                    ),
                    Gap.h16,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...List.generate(categoryList.length, (index) {
                          final category = categoryList[index];
                          return IconWithTextButton(
                            iconPath: category.iconPath,
                            label: category.name,
                            labelSize: 18,
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: Border.all(
                              color: _currentCategory?.databaseObject.id == category.databaseObject.id
                                  ? category.backgroundColor
                                  : context.appTheme.onBackground.withOpacity(0.4),
                            ),
                            backgroundColor:
                                _currentCategory?.databaseObject.id == category.databaseObject.id
                                    ? category.backgroundColor
                                    : Colors.transparent,
                            color: _currentCategory?.databaseObject.id == category.databaseObject.id
                                ? category.iconColor
                                : context.appTheme.onBackground,
                            onTap: () => context.pop<Category>(category),
                            height: null,
                            width: null,
                          );
                        }),
                        IconWithTextButton(
                          iconPath: AppIcons.add,
                          color: AppColors.grey(context),
                          backgroundColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          height: null,
                          border: Border.all(
                            color: AppColors.grey(context),
                          ),
                          onTap: () async {
                            final categoryType = widget.transactionType == TransactionType.income
                                ? CategoryType.income
                                : CategoryType.expense;

                            final newCategory = await showCustomModal<Category>(
                              context: context,
                              child: AddCategoryModalScreen(initialType: categoryType),
                            );
                            if (mounted) {
                              if (newCategory != null && newCategory.type == categoryType) {
                                context.pop<Category>(newCategory);
                              }
                            }
                          },
                        )
                      ],
                    ),
                    context.isBigScreen ? Gap.noGap : Gap.h32,
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Gap.h8,
                    IconWithText(
                      header:
                          'No ${widget.transactionType == TransactionType.income ? 'income' : 'expense'} category.\n Tap here to create a first one'
                              .hardcoded,
                      headerSize: 14,
                      iconPath: AppIcons.accounts,
                      onTap: () async {
                        final categoryType = widget.transactionType == TransactionType.income
                            ? CategoryType.income
                            : CategoryType.expense;

                        final newCategory = await showCustomModal<Category>(
                          context: context,
                          child: AddCategoryModalScreen(initialType: categoryType),
                        );
                        if (mounted) {
                          if (newCategory != null && newCategory.type == categoryType) {
                            context.pop<Category>(newCategory);
                          }
                        }
                      },
                    ),
                    Gap.h48,
                  ],
                ),
        );

        setState(() {
          if (returnedValue != null) {
            if (_currentCategory != null &&
                _currentCategory!.databaseObject.id == returnedValue.databaseObject.id) {
              _currentCategory = null;
              widget.onChangedCategory(_currentCategory);
            } else {
              _currentCategory = returnedValue;
              widget.onChangedCategory(_currentCategory);
            }
          }
        });
      },
    );
  }
}
