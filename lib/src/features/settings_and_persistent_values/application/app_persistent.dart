import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import '../../../utils/enums.dart';

// Access this class through `context.appPersistentValues`
class AppPersistentValues {
  final ChartDataType chartDataTypeInHomescreen;

  final bool showAmount;

  factory AppPersistentValues.fromDatabase(PersistentValuesDb persistentValuesDb) {
    ChartDataType chartDataTypeInHomescreen = switch (persistentValuesDb.chartDataTypeInHomescreen) {
      0 => ChartDataType.cashflow,
      1 => ChartDataType.expense,
      2 => ChartDataType.income,
      _ => ChartDataType.totalAssets,
    };

    return AppPersistentValues._(
      chartDataTypeInHomescreen: chartDataTypeInHomescreen,
      showAmount: persistentValuesDb.showAmount,
    );
  }

  PersistentValuesDb toDatabase() {
    int typeRealmData = switch (chartDataTypeInHomescreen) {
      ChartDataType.cashflow => 0,
      ChartDataType.expense => 1,
      ChartDataType.income => 2,
      ChartDataType.totalAssets => 3,
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
    ChartDataType? chartDataTypeInHomescreen,
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
