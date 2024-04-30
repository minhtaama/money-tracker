import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/transactions/domain/template_transaction.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:realm/realm.dart';

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

  List<TemplateTransaction> getUpcomingTransactionInMonth(BuildContext context, DateTime dateTime) {
    final targetMonthRange = dateTime.monthRange;
    if (targetMonthRange.end.isBefore(startOn)) {
      return [];
    }

    final startAnchorDate = switch (type) {
      RepeatEvery.xDay => startOn,
      RepeatEvery.xWeek => startOn.weekRange(context).start,
      RepeatEvery.xMonth => startOn.monthRange.start,
      RepeatEvery.xYear => startOn.yearRange.start,
    };

    final List<DateTime> targetAnchorDate = switch (type) {
      RepeatEvery.xDay => <DateTime>[
          for (DateTime date = targetMonthRange.start;
              !date.isAfter(targetMonthRange.end);
              date = date.copyWith(day: date.day + 1))
            date
        ],
      RepeatEvery.xWeek => startOn.weekRangeInMonth(context).map((e) => e.start).toList(),
      RepeatEvery.xMonth => [startOn.monthRange.start],
      RepeatEvery.xYear => [startOn.yearRange.start],
    };

    print(targetAnchorDate);

    return [];
  }

  factory Recurrence.test() {
    return Recurrence._(
      RecurrenceDb(ObjectId(), 1, 2, DateTime.now()),
      type: RepeatEvery.xWeek,
      interval: 1,
      repeatOn: [DateTime(2024, 4, 9)],
      startOn: DateTime(2024, 3, 15),
      endOn: null,
      autoCreateTransaction: true,
      templateTransaction: TemplateTransaction.fromDatabase(TemplateTransactionDb(ObjectId(), 1)),
      addedTransactions: const [],
      skippedOn: const [],
    );
  }

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
