import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/budget/domain/budget.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../common_widgets/custom_radio.dart';
import '../../../common_widgets/custom_text_form_field.dart';
import '../../../common_widgets/hideable_container.dart';
import '../../../common_widgets/icon_with_text.dart';
import '../../../common_widgets/modal_screen_components.dart';
import '../../../theme_and_ui/colors.dart';
import '../../calculator_input/application/calculator_service.dart';
import '../../calculator_input/presentation/calculator_input.dart';
import '../../category/domain/category.dart';
import '../data/budget_repo.dart';

class EditBudgetModalScreen extends ConsumerStatefulWidget {
  const EditBudgetModalScreen(this.controller, this.isScrollable, {super.key, required this.budget});

  final BaseBudget budget;
  final ScrollController controller;
  final bool isScrollable;

  @override
  ConsumerState<EditBudgetModalScreen> createState() => _EditBudgetModalScreenState();
}

class _EditBudgetModalScreenState extends ConsumerState<EditBudgetModalScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name = widget.budget.name;
  late BudgetType _budgetType = widget.budget is AccountBudget ? BudgetType.forAccount : BudgetType.forCategory;
  late BudgetPeriodType _periodType = widget.budget.periodType;
  late double _amount = widget.budget.amount;
  late List<BaseAccount> _accounts = widget.budget is AccountBudget ? (widget.budget as AccountBudget).accounts : [];
  late List<Category> _categories = widget.budget is CategoryBudget ? (widget.budget as CategoryBudget).categories : [];

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      formKey: _formKey,
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: 'Edit budget'.hardcoded,
      ),
      body: [
        CustomSliderToggle<BudgetType>(
          values: const [BudgetType.forCategory, BudgetType.forAccount],
          labels: const ['For Categories', 'For Accounts'],
          initialValueIndex: widget.budget is AccountBudget ? 1 : 0,
          fontSize: 14,
          onTap: (type) {
            setState(() {
              _budgetType = type;
            });
          },
        ),
        Gap.h16,
        Row(
          children: [
            RoundedIconButton(
              iconPath: AppIcons.budgets,
              iconColor: context.appTheme.onBackground,
              backgroundColor: AppColors.greyBgr(context),
              size: 50,
            ),
            Gap.w16,
            Expanded(
              child: CustomTextFormField(
                keyboardType: TextInputType.text,
                validator: (_) => _name == '' ? 'Please input name'.hardcoded : null,
                onChanged: (value) => _name = value,
                hintText: _name,
                autofocus: false,
                focusColor: context.appTheme.accent1,
                style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 16),
              ),
            ),
          ],
        ),
        Gap.h16,
        Row(
          children: [
            const CurrencyIcon(),
            Gap.w16,
            Expanded(
              child: CalculatorInput(
                hintText: CalService.formatNumberInGroup(_amount.toString()),
                focusColor: context.appTheme.onBackground,
                validator: (_) {
                  if (_amount <= 0) {
                    return 'Invalid amount';
                  }
                  return null;
                },
                formattedResultOutput: (value) {
                  _amount = CalService.formatToDouble(value)!;
                },
              ),
            ),
          ],
        ),
        Gap.h16,
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 6.0),
          child: Text(
            'Budget Period:',
            style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyBorder(context)),
          ),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomRadio<BudgetPeriodType>(
                    label: 'Daily'.hardcoded,
                    width: 135,
                    value: BudgetPeriodType.daily,
                    groupValue: _periodType,
                    onChanged: (value) => setState(() {
                      _periodType = value!;
                    }),
                  ),
                  CustomRadio<BudgetPeriodType>(
                    label: 'Weekly'.hardcoded,
                    width: 135,
                    value: BudgetPeriodType.weekly,
                    groupValue: _periodType,
                    onChanged: (value) => setState(() {
                      _periodType = value!;
                    }),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomRadio<BudgetPeriodType>(
                    label: 'Monthly'.hardcoded,
                    width: 135,
                    value: BudgetPeriodType.monthly,
                    groupValue: _periodType,
                    onChanged: (value) => setState(() {
                      _periodType = value!;
                    }),
                  ),
                  CustomRadio<BudgetPeriodType>(
                    label: 'Yearly'.hardcoded,
                    width: 135,
                    value: BudgetPeriodType.yearly,
                    groupValue: _periodType,
                    onChanged: (value) => setState(() {
                      _periodType = value!;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        Gap.h16,
        HideableContainer(
          hide: _budgetType == BudgetType.forAccount,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text(
                  'Select categories registered with budget:'.hardcoded,
                  style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                ),
              ),
              _Selector<Category>(
                onChanged: (list) {
                  _categories = list;
                },
                initialSelected: _categories,
              ),
            ],
          ),
        ),
        HideableContainer(
          hide: _budgetType == BudgetType.forCategory,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text(
                  'Select accounts registered with budget:'.hardcoded,
                  style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                ),
              ),
              _Selector<BaseAccount>(
                onChanged: (list) {
                  _accounts = list;
                },
                initialSelected: _accounts,
              ),
            ],
          ),
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: false,
        smallButtonIcon: AppIcons.delete,
        bigButtonIcon: AppIcons.edit,
        bigButtonLabel: 'Done'.hardcoded,
        onSmallButtonTap: () {
          showConfirmModal(
            context: context,
            label: 'Are you sure that you want to delete budget ${widget.budget.name}?'.hardcoded,
            onConfirm: () {
              final budgetRepo = ref.read(budgetsRepositoryRealmProvider);
              budgetRepo.delete(widget.budget);
              context.pop();
            },
          );
        },
        onBigButtonTap: () {
          if (_formKey.currentState!.validate()) {
            final budgetRepo = ref.read(budgetsRepositoryRealmProvider);

            budgetRepo.edit(
              widget.budget,
              type: _budgetType,
              periodType: _periodType,
              name: _name,
              amount: _amount,
              accounts: _accounts,
              categories: _categories,
            );
            context.pop();
          }
        },
      ),
    );
  }
}

class _Selector<T extends BaseModelWithIcon> extends ConsumerStatefulWidget {
  const _Selector({
    super.key,
    required this.onChanged,
    required this.initialSelected,
  });

  final ValueChanged<List<T>> onChanged;
  final List<T> initialSelected;

  @override
  ConsumerState<_Selector<T>> createState() => _AccountSelectorState();
}

class _AccountSelectorState<T extends BaseModelWithIcon> extends ConsumerState<_Selector<T>> {
  late final _selectedItems = widget.initialSelected;

  List<T> _items = [];

  @override
  void initState() {
    if (T == BaseAccount) {
      _items = ref.read(accountRepositoryProvider).getListInfo(null).cast<T>();
    }
    if (T == Category) {
      _items = ref.read(categoryRepositoryRealmProvider).getList(CategoryType.expense).cast<T>();
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _items.isEmpty
        ? IconWithText(
            header: 'No items'.hardcoded,
            headerSize: 14,
            iconPath: AppIcons.sadFace,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _items
                    .map(
                      (e) => _Item<T>(
                        item: e,
                        isSelected: _selectedItems.contains(e),
                        onTap: (value) {
                          setState(() {
                            if (_selectedItems.contains(e)) {
                              _selectedItems.remove(e);
                            } else {
                              _selectedItems.add(e);
                            }
                          });
                          widget.onChanged(_selectedItems);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          );
  }
}

class _Item<T extends BaseModelWithIcon> extends StatelessWidget {
  const _Item({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final T item;
  final bool isSelected;
  final ValueSetter<T> onTap;

  @override
  Widget build(BuildContext context) {
    return IconWithTextButton(
      iconPath: item.iconPath,
      label: item.name,
      labelSize: 18,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: Border.all(
        color: isSelected ? item.backgroundColor : context.appTheme.onBackground.withOpacity(0.4),
      ),
      backgroundColor: isSelected ? item.backgroundColor : Colors.transparent,
      inkColor: item.backgroundColor,
      color: isSelected ? item.iconColor : context.appTheme.onBackground,
      onTap: () => onTap(item),
      height: null,
      width: null,
    );
  }
}
