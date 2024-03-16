import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_card.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_widget.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/dashboard_edit_modal_screen.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/widgets/expense_pie_chart_widget.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/widgets/income_pie_chart_widget.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/widgets/weekly_bar_chart_widget.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../common_widgets/modal_and_dialog.dart';
import '../../../theme_and_ui/icons.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _getChild(DashboardType type) {
    return switch (type) {
      DashboardType.menu => const _DashboardMenu(),
      DashboardType.weeklyReport =>
        const DashboardWidget(title: 'Weekly Report', child: WeeklyBarChartWidget()),
      DashboardType.monthlyExpense =>
        const DashboardWidget(title: 'Monthly Expense', child: ExpensePieChartWidget()),
      DashboardType.monthlyIncome =>
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
            iconPath: AppIcons.edit,
            iconColor: context.appTheme.onBackground,
            onTap: () => context.push(RoutePath.editDashboard),
          ),
        ),
      ),
      children: order.map<Widget>((type) {
        if (hiddenWidgets.contains(type)) {
          return Gap.noGap;
        }
        return _getChild(type);
      }).toList(),
    );
  }
}

class _DashboardMenu extends StatelessWidget {
  const _DashboardMenu({super.key});

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
          DashboardCard(
            onTap: () => context.push(RoutePath.settings),
            title: 'Settings'.hardcoded,
            icon: AppIcons.settings,
          ),
        ],
      ),
    );
  }
}
