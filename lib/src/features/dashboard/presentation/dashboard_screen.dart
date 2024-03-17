import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_card.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_widget.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/widgets/expense_pie_chart_widget.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/widgets/income_pie_chart_widget.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/widgets/weekly_bar_chart_widget.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _getChild(DashboardWidgetType type) {
    return switch (type) {
      DashboardWidgetType.menu => const _DashboardMenu2(),
      DashboardWidgetType.weeklyReport =>
        const DashboardWidget(title: 'Weekly Report', child: WeeklyBarChartWidget()),
      DashboardWidgetType.monthlyExpense =>
        const DashboardWidget(title: 'Monthly Expense', child: ExpensePieChartWidget()),
      DashboardWidgetType.monthlyIncome =>
        const DashboardWidget(title: 'Monthly Income', child: IncomePieChartWidget()),
    };
  }

  @override
  Widget build(BuildContext context) {
    final order = context.appPersistentValues.dashboardOrder;
    final hiddenWidgets = context.appPersistentValues.hiddenDashboardWidgets;

    return CustomTabPage(
      smallTabBar: SmallTabBar(
        child: PageHeading(
          title: context.localize.dashboard,
          secondaryTitle: DateTime.now().getFormattedDate(hasDay: false),
          trailing: RoundedIconButton(
            iconPath: AppIcons.settings,
            iconColor: context.appTheme.onBackground,
            onTap: () => context.push(RoutePath.settings),
          ),
        ),
      ),
      children: order.map<Widget>((type) {
        if (hiddenWidgets.contains(type)) {
          return Gap.noGap;
        }
        return _getChild(type);
      }).toList()
        ..add(const _EditButton()),
    );
  }
}

class _DashboardMenu1 extends StatelessWidget {
  const _DashboardMenu1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DashboardCard(
            onTap: () => context.push(RoutePath.accounts),
            title: 'Accounts'.hardcoded,
            icon: AppIcons.accounts,
          ),
          DashboardCard(
            onTap: () => context.push(RoutePath.categories),
            title: 'Categories'.hardcoded,
            icon: AppIcons.categories,
          ),
          DashboardCard(
            title: 'Budget'.hardcoded,
            icon: AppIcons.budgets,
          ),
          DashboardCard(
            title: 'Saving'.hardcoded,
            icon: AppIcons.savings,
          ),
        ],
      ),
    );
  }
}

class _DashboardMenu2 extends StatelessWidget {
  const _DashboardMenu2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RoundedIconButton(
            onTap: () => context.push(RoutePath.accounts),
            label: 'Accounts'.hardcoded,
            size: 50,
            iconPath: AppIcons.accounts,
            iconColor: context.appTheme.onBackground,
          ),
          RoundedIconButton(
            onTap: () => context.push(RoutePath.categories),
            label: 'Categories'.hardcoded,
            size: 50,
            iconPath: AppIcons.categories,
            iconColor: context.appTheme.onBackground,
          ),
          RoundedIconButton(
            onTap: () => context.push(RoutePath.budgets),
            label: 'Budget'.hardcoded,
            size: 50,
            iconPath: AppIcons.budgets,
            iconColor: context.appTheme.onBackground,
          ),
          RoundedIconButton(
            label: 'Saving'.hardcoded,
            size: 50,
            iconPath: AppIcons.savings,
            iconColor: context.appTheme.onBackground,
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomInkWell(
            onTap: () => context.push(RoutePath.editDashboard),
            inkColor: AppColors.grey(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgIcon(
                    AppIcons.edit,
                    color: AppColors.grey(context),
                    size: 17,
                  ),
                  Gap.w8,
                  Text(
                    'Edit dashboard'.hardcoded,
                    style: kNormalTextStyle.copyWith(
                      color: AppColors.grey(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
