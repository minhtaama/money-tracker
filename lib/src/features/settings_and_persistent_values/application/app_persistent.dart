import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import '../../../utils/enums.dart';

// Access this class through `context.appPersistentValues`
class AppPersistentValues {
  //final ChartDataType chartDataTypeInHomescreen;

  final bool showAmount;

  //final List<BalanceAtDateTimeDb> balanceAtDateTimes;

  factory AppPersistentValues.fromDatabase(PersistentValuesDb persistentValuesDb) {
    ChartDataType chartDataTypeInHomescreen = switch (persistentValuesDb.chartDataTypeInHomescreen) {
      0 => ChartDataType.cashflow,
      1 => ChartDataType.expense,
      _ => ChartDataType.income,
    };

    return AppPersistentValues._(
      //chartDataTypeInHomescreen: chartDataTypeInHomescreen,
      showAmount: persistentValuesDb.showAmount,
      //balanceAtDateTimes: persistentValuesDb.balanceAtDateTimes,
    );
  }

  PersistentValuesDb toDatabase() {
    // int typeRealmData = switch (chartDataTypeInHomescreen) {
    //   ChartDataType.cashflow => 0,
    //   ChartDataType.expense => 1,
    //   ChartDataType.income => 2,
    // };

    return PersistentValuesDb(
      0,
      //chartDataTypeInHomescreen: typeRealmData,
      showAmount: showAmount,
      //balanceAtDateTimes: balanceAtDateTimes,
    );
  }

  AppPersistentValues._({
    //required this.chartDataTypeInHomescreen,
    required this.showAmount,
    //required this.balanceAtDateTimes,
  });

  AppPersistentValues copyWith({
    ChartDataType? chartDataTypeInHomescreen,
    bool? showAmount,
    List<BalanceAtDateTimeDb>? balanceAtDateTimes,
  }) {
    return AppPersistentValues._(
      //chartDataTypeInHomescreen: chartDataTypeInHomescreen ?? this.chartDataTypeInHomescreen,
      showAmount: showAmount ?? this.showAmount,
      //balanceAtDateTimes: balanceAtDateTimes ?? this.balanceAtDateTimes,
    );
  }
}

/// Class for reading AppPersistentValues via InheritedWidget
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
