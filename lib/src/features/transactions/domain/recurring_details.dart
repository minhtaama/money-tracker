import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/transactions/domain/template_transaction.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

class Recurrence extends BaseModel<RecurrenceDb> {
  final RepeatEvery type;

  final int interval;

  /// Only year, month, day
  final List<DateTime> repeatOn;

  /// Only year, month, day
  final DateTime startOn;

  /// Only year, month, day
  final DateTime? endOn;

  final bool autoCreateTransaction;

  final TemplateTransaction templateTransaction;

  final List<BaseTransaction> addedTransactions;

  final List<DateTime> skippedOn;

  // List<TemplateTransaction> getUpcomingTransactionInMonth(BuildContext context, DateTime dateTime) {
  //   final targetMonthRange = dateTime.monthRange;
  //   if (targetMonthRange.end.isBefore(startOn)) {
  //     return [];
  //   }
  //
  //   final startAnchorDate = switch(type) {
  //     RepeatEvery.xDay => startOn,
  //     RepeatEvery.xWeek => startOn.weekRange(context).start,
  //     RepeatEvery.xMonth => startOn.monthRange.start,
  //     RepeatEvery.xYear => startOn.yearRange.start,
  //   };
  //
  //   final List<DateTime> targetAnchorDate = switch(type) {
  //     RepeatEvery.xDay => startOn,
  //     RepeatEvery.xWeek => startOn.weekRange(context).start,
  //     RepeatEvery.xMonth => startOn.monthRange.start,
  //     RepeatEvery.xYear => startOn.yearRange.start,
  //   }
  // }

  factory Recurrence.fromDatabase(RecurrenceDb db) {
    return Recurrence._(
      db,
      type: RepeatEvery.fromDatabaseValue(db.type),
      interval: db.repeatInterval,
      repeatOn: db.repeatOn,
      startOn: db.startOn.toLocal(),
      endOn: db.endOn?.toLocal(),
      autoCreateTransaction: db.autoCreateTransaction,
      templateTransaction: TemplateTransaction.fromDatabase(db.templateTransaction!),
      addedTransactions: db.addedTransactions.map((txn) => BaseTransaction.fromDatabase(txn)).toList(),
      skippedOn: db.skippedOn.map((dateTime) => dateTime.toLocal()).toList(),
    );
  }

  const Recurrence._(
    super.databaseObject, {
    required this.type,
    required this.interval,
    required this.repeatOn,
    required this.startOn,
    this.endOn,
    required this.autoCreateTransaction,
    required this.templateTransaction,
    required this.addedTransactions,
    required this.skippedOn,
  });
}
