import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../theme_and_ui/icons.dart';

enum DashboardWidgetType {
  menu(0),
  weeklyReport(1),
  monthlyExpense(2),
  monthlyIncome(3),
  budgets(4),
  upcomingTransactions(5),
  ;

  final int databaseValue;

  const DashboardWidgetType(this.databaseValue);

  static DashboardWidgetType fromDatabaseValue(int value) {
    return DashboardWidgetType.values.firstWhere((e) => e.databaseValue == value);
  }

  String get iconPath {
    return switch (this) {
      DashboardWidgetType.menu => AppIcons.categoriesBulk,
      DashboardWidgetType.weeklyReport => AppIcons.receiptDollarBulk,
      DashboardWidgetType.monthlyExpense => AppIcons.reportsBulk,
      DashboardWidgetType.monthlyIncome => AppIcons.reportsBulk,
      DashboardWidgetType.budgets => AppIcons.budgetsBulk,
      DashboardWidgetType.upcomingTransactions => AppIcons.recurrenceBulk,
    };
  }

  String name(BuildContext context) {
    return switch (this) {
      DashboardWidgetType.menu => 'Menu'.hardcoded,
      DashboardWidgetType.weeklyReport => context.loc.weeklyReport,
      DashboardWidgetType.monthlyExpense => context.loc.monthlyExpense,
      DashboardWidgetType.monthlyIncome => context.loc.monthlyIncome,
      DashboardWidgetType.budgets => context.loc.budgets,
      DashboardWidgetType.upcomingTransactions => context.loc.upcomingTransactions,
    };
  }
}

// TODO: Add this
enum DWMenuType {
  icon(0),
  button(1);

  final int databaseValue;

  const DWMenuType(this.databaseValue);

  static DWMenuType fromDatabaseValue(int value) {
    return DWMenuType.values.firstWhere((e) => e.databaseValue == value);
  }
}
