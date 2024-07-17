import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

part 'enums_settings.dart';

enum TransactionType {
  expense,
  income,
  transfer,
  creditSpending,
  creditPayment,
  creditCheckpoint,
  installmentToPay;

  int get databaseValue {
    return switch (this) {
      TransactionType.expense => 0,
      TransactionType.income => 1,
      TransactionType.transfer => 2,
      TransactionType.creditSpending => 3,
      TransactionType.creditPayment => 4,
      TransactionType.creditCheckpoint => 5,
      TransactionType.installmentToPay => throw StateError('Can not put this type into database'),
    };
  }

  static TransactionType fromDatabaseValue(int value) {
    return switch (value) {
      0 => TransactionType.expense,
      1 => TransactionType.income,
      2 => TransactionType.transfer,
      3 => TransactionType.creditSpending,
      4 => TransactionType.creditPayment,
      5 => TransactionType.creditCheckpoint,
      _ => throw StateError('Type $value is not available for TransactionType'),
    };
  }
}

enum CategoryType {
  expense(0),
  income(1);

  final int databaseValue;

  const CategoryType(this.databaseValue);

  static CategoryType fromDatabaseValue(int value) {
    return CategoryType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum AccountType {
  regular(0),
  credit(1),
  saving(2);

  final int databaseValue;

  const AccountType(this.databaseValue);

  static AccountType fromDatabaseValue(int value) {
    return AccountType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum StatementType {
  withAverageDailyBalance(0),
  payOnlyInGracePeriod(1);

  final int databaseValue;

  const StatementType(this.databaseValue);

  static StatementType fromDatabaseValue(int value) {
    return StatementType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum BudgetType {
  forAccount(0),
  forCategory(1);

  final int databaseValue;

  const BudgetType(this.databaseValue);

  static BudgetType fromDatabaseValue(int value) {
    return BudgetType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum BudgetPeriodType {
  daily(0),
  weekly(1),
  monthly(2),
  yearly(3);

  final int databaseValue;

  const BudgetPeriodType(this.databaseValue);

  String get asSuffix {
    return switch (this) {
      BudgetPeriodType.daily => '/day'.hardcoded,
      BudgetPeriodType.weekly => '/week'.hardcoded,
      BudgetPeriodType.monthly => '/month'.hardcoded,
      BudgetPeriodType.yearly => '/year'.hardcoded,
    };
  }

  static BudgetPeriodType fromDatabaseValue(int value) {
    return BudgetPeriodType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum RepeatEvery {
  xDay(0),
  xWeek(1),
  xMonth(2),
  xYear(3),
  ;

  final int databaseValue;

  const RepeatEvery(this.databaseValue);

  static RepeatEvery fromDatabaseValue(int value) {
    return RepeatEvery.values.firstWhere((e) => e.databaseValue == value);
  }
}

////////////// OTHER ///////////////////////////

enum LineChartDataType {
  cashflow(0),
  expense(1),
  income(2),
  totalAssets(3);

  final int databaseValue;

  const LineChartDataType(this.databaseValue);

  static LineChartDataType fromDatabaseValue(int value) {
    return LineChartDataType.values.firstWhere((e) => e.databaseValue == value);
  }
}

///////// NO DATABASE VALUE //////////////////////

enum TransactionScreenType { editable, uneditable, installmentToPay }
