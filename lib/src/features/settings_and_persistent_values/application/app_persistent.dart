import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import '../../../utils/enums.dart';

// Access this class through `context.appPersistentValues`
class AppPersistentValues {
  final LineChartDataType chartDataTypeInHomescreen;
  final bool showAmount;
  final List<DashboardWidgetType> dashboardOrder;
  final List<DashboardWidgetType> hiddenDashboardWidgets;

  factory AppPersistentValues.fromDatabase(PersistentValuesDb persistentValuesDb) {
    return AppPersistentValues._(
      chartDataTypeInHomescreen:
          LineChartDataType.fromDatabaseValue(persistentValuesDb.chartDataTypeInHomescreen),
      showAmount: persistentValuesDb.showAmount,
      dashboardOrder: persistentValuesDb.dashboardOrder
          .map((e) => DashboardWidgetType.fromDatabaseValue(e))
          .toList(),
      hiddenDashboardWidgets: persistentValuesDb.hiddenDashboardWidgets
          .map((e) => DashboardWidgetType.fromDatabaseValue(e))
          .toList(),
    );
  }

  PersistentValuesDb toDatabase() {
    return PersistentValuesDb(
      0,
      chartDataTypeInHomescreen: chartDataTypeInHomescreen.databaseValue,
      showAmount: showAmount,
      dashboardOrder: dashboardOrder.map((e) => e.databaseValue),
      hiddenDashboardWidgets: hiddenDashboardWidgets.map((e) => e.databaseValue),
    );
  }

  AppPersistentValues._({
    required this.chartDataTypeInHomescreen,
    required this.showAmount,
    required this.dashboardOrder,
    required this.hiddenDashboardWidgets,
  });

  AppPersistentValues copyWith({
    LineChartDataType? chartDataTypeInHomescreen,
    bool? showAmount,
    List<DashboardWidgetType>? dashboardOrder,
    List<DashboardWidgetType>? hiddenDashboardWidgets,
  }) {
    return AppPersistentValues._(
      chartDataTypeInHomescreen: chartDataTypeInHomescreen ?? this.chartDataTypeInHomescreen,
      showAmount: showAmount ?? this.showAmount,
      dashboardOrder: dashboardOrder ?? this.dashboardOrder,
      hiddenDashboardWidgets: hiddenDashboardWidgets ?? this.hiddenDashboardWidgets,
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
