import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import '../../../utils/enums.dart';

// Access this class through `context.appPersistentValues`
class AppPersistentValues {
  final LineChartDataType chartDataTypeInHomescreen;

  final bool showAmount;

  factory AppPersistentValues.fromDatabase(PersistentValuesDb persistentValuesDb) {
    LineChartDataType chartDataTypeInHomescreen = switch (persistentValuesDb.chartDataTypeInHomescreen) {
      0 => LineChartDataType.cashflow,
      1 => LineChartDataType.expense,
      2 => LineChartDataType.income,
      _ => LineChartDataType.totalAssets,
    };

    return AppPersistentValues._(
      chartDataTypeInHomescreen: chartDataTypeInHomescreen,
      showAmount: persistentValuesDb.showAmount,
    );
  }

  PersistentValuesDb toDatabase() {
    int typeRealmData = switch (chartDataTypeInHomescreen) {
      LineChartDataType.cashflow => 0,
      LineChartDataType.expense => 1,
      LineChartDataType.income => 2,
      LineChartDataType.totalAssets => 3,
    };

    return PersistentValuesDb(
      0,
      chartDataTypeInHomescreen: typeRealmData,
      showAmount: showAmount,
    );
  }

  AppPersistentValues._({
    required this.chartDataTypeInHomescreen,
    required this.showAmount,
  });

  AppPersistentValues copyWith({
    LineChartDataType? chartDataTypeInHomescreen,
    bool? showAmount,
  }) {
    return AppPersistentValues._(
      chartDataTypeInHomescreen: chartDataTypeInHomescreen ?? this.chartDataTypeInHomescreen,
      showAmount: showAmount ?? this.showAmount,
    );
  }
}

/// Class for reading AppPersistentValues via InheritedWidget
/// No need to change this class when add property
class AppPersistent extends InheritedWidget {
  const AppPersistent({
    super.key,
    required this.data,
    required super.child,
  });

  final AppPersistentValues data;

  static AppPersistentValues of(BuildContext context) {
    final values = context.dependOnInheritedWidgetOfExactType<AppPersistent>();
    if (values != null) {
      return values.data;
    } else {
      throw StateError('Could not find ancestor widget of type `AppPersistent`');
    }
  }

  @override
  bool updateShouldNotify(AppPersistent oldWidget) => data != oldWidget.data;
}
