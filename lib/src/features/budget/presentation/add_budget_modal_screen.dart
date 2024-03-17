import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../category/domain/category.dart';

class AddBudgetModalScreen extends ConsumerStatefulWidget {
  const AddBudgetModalScreen({super.key});

  @override
  ConsumerState<AddBudgetModalScreen> createState() => _AddBudgetModalScreenState();
}

class _AddBudgetModalScreenState extends ConsumerState<AddBudgetModalScreen> {
  final _formKey = GlobalKey<FormState>();

  BudgetType _budgetType = BudgetType.forCategory;
  BudgetPeriodType _periodType = BudgetPeriodType.monthly;
  double _amount = 0;
  List<BaseAccount> _accounts = [];
  List<Category> _categories = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Category',
        isWrapByCard: false,
        sections: [
          CustomSliderToggle<BudgetType>(
            values: const [BudgetType.forCategory, BudgetType.forAccount],
            labels: const ['For Categories', 'For Accounts'],
            initialValueIndex: 1,
            fontSize: 14,
            onTap: (type) {
              _budgetType = type;
            },
          ),
          Gap.h16,
          Align(
            alignment: Alignment.centerRight,
            child: IconWithTextButton(
              iconPath: AppIcons.add,
              label: 'Create',
              backgroundColor: context.appTheme.accent1,
              //isDisabled: _periodType == '',
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  final categoryRepository = ref.read(categoryRepositoryRealmProvider);
                  // categoryRepository.writeNew(
                  //   type: budgetType,
                  //   iconCategory: iconCategory,
                  //   iconIndex: iconIndex,
                  //   name: categoryName,
                  //   colorIndex: colorIndex,
                  // );
                  context.pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
