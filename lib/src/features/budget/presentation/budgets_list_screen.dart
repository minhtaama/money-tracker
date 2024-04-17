import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/budget/data/budget_repo.dart';
import 'package:money_tracker_app/src/features/budget/domain/budget.dart';
import 'package:money_tracker_app/src/features/budget/presentation/edit_budget_modal_screen.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_page/custom_page.dart';
import '../../../common_widgets/modal_and_dialog.dart';

class BudgetsListScreen extends ConsumerWidget {
  const BudgetsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetRepo = ref.watch(budgetsRepositoryRealmProvider);

    List<BaseBudget> budgetsList = budgetRepo.getList();

    ref.watch(budgetsChangesRealmProvider).whenData((_) {
      budgetsList = budgetRepo.getList();
    });

    List<Widget> buildBudgetTiles(BuildContext context, CategoryType type) {
      return budgetsList.isNotEmpty
          ? List.generate(
              budgetsList.length,
              (index) {
                BaseBudget model = budgetsList[index];
                return _BudgetTile(model: model);
              },
            )
          : [
              Text(
                'No budget',
                style: kHeader2TextStyle.copyWith(color: AppColors.grey(context)),
                textAlign: TextAlign.center,
              )
            ];
    }

    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: CustomPage(
        smallTabBar: SmallTabBar(
          child: PageHeading(
            isTopLevelOfNavigationRail: true,
            title: 'Budgets',
            trailing: RoundedIconButton(
              iconPath: AppIcons.add,
              iconColor: context.appTheme.onBackground,
              backgroundColor: context.appTheme.background0,
              onTap: () => context.push(RoutePath.addBudget),
            ),
          ),
        ),
        children: [
          CustomSection(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            isWrapByCard: false,
            onReorder: (oldIndex, newIndex) {
              budgetRepo.reorder(oldIndex, newIndex);
            },
            sections: buildBudgetTiles(context, CategoryType.income),
          ),
        ],
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({required this.model});

  final BaseBudget model;

  List<Widget> _assignedModels() {
    return switch (model) {
      AccountBudget() => (model as AccountBudget).accounts.map((e) => _AssignedModel(model: e)).toList(),
      CategoryBudget() => (model as CategoryBudget).categories.map((e) => _AssignedModel(model: e)).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return CardItem(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h8,
          Row(
            children: [
              Text(
                model.name,
                style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 18),
              ),
              const Spacer(),
              RoundedIconButton(
                iconPath: AppIcons.edit,
                size: 32,
                iconPadding: 6,
                onTap: () {
                  showCustomModal(
                    context: context,
                    child: EditBudgetModalScreen(budget: model),
                  );
                },
              ),
            ],
          ),
          Gap.divider(context),
          Gap.h4,
          Text(
            'Budget:'.hardcoded,
            style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.65), fontSize: 14),
          ),
          Gap.h4,
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                CalService.formatCurrency(context, model.amount),
                style: kHeader1TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 23),
              ),
              Gap.w4,
              Text(
                context.appSettings.currency.code,
                style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 20),
              ),
              Text(
                model.periodType.asSuffix,
                style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
              ),
            ],
          ),
          Gap.h8,
          Text(
            model is AccountBudget ? 'Assigned accounts:'.hardcoded : 'Assigned categories:'.hardcoded,
            style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.65), fontSize: 14),
          ),
          Gap.h8,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _assignedModels(),
          ),
          Gap.h8,
        ],
      ),
    );
  }
}

class _AssignedModel extends StatelessWidget {
  const _AssignedModel({required this.model});

  final BaseModelWithIcon model;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(10),
      color: model.backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(
            model.iconPath,
            color: model.iconColor,
          ),
          Gap.w8,
          Text(
            model.name,
            style: kNormalTextStyle.copyWith(color: model.iconColor),
          ),
        ],
      ),
    );
  }
}
