import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';

class Recurrence extends BaseModel<RecurrenceDb> {
  final RepeatEvery type;

  /// [interval] means `target date` = `startDate` * nth * [interval]
  /// which is similar to `every X parameter`.
  final int interval;

  /// Only year, month, day
  final List<DateTime> repeatOn;

  /// Only year, month, day
  final DateTime startOn;

  /// Only year, month, day
  final DateTime? endOn;

  final bool autoCreateTransaction;

  final TransactionData transactionData;

  final List<BaseTransaction> addedTransactions;

  final List<DateTime> skippedOn;

  List<TransactionData> getUpcomingTransactionInMonth(BuildContext context, DateTime dateTime) {
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

    // Get anchorRange of current month

    final List<DateTimeRange> targetAnchorRanges = switch (type) {
      RepeatEvery.xDay => <DateTimeRange>[
          for (DateTime date = targetMonthRange.start;
              !date.isAfter(targetMonthRange.end);
              date = date.copyWith(day: date.day + 1))
            date.dayRange
        ],
      RepeatEvery.xWeek => dateTime.weekRangesInMonth(context),
      RepeatEvery.xMonth => [dateTime.monthRange],
      RepeatEvery.xYear => [dateTime.yearRange],
    };

    // Remove ranges which is not in interval with startAnchorDate
    // `targetAnchorRanges` now only contains ranges which is in interval with `startAnchorDate`

    final List<DateTimeRange> toRemove = [];

    for (DateTimeRange range in targetAnchorRanges) {
      if (range.start.getDaysDifferent(startAnchorDate) % interval != 0) {
        toRemove.add(range);
      }
    }

    targetAnchorRanges.removeWhere((e) => toRemove.contains(e));

    // Now, for each kind of repeat type, we extract the date in range
    // which is suitable with the condition of `repeatOn`.

    List<DateTime> targetDates = [];

    if (type == RepeatEvery.xDay) {
      // Because targetAnchorRanges contains dayRange (from 0:0:0 to 23:59:59 of same day)
      targetDates = targetAnchorRanges.map((e) => e.start).toList();
    }

    if (type == RepeatEvery.xWeek) {
      final selectedWeekDay = repeatOn.map((e) => e.weekday);

      for (DateTimeRange range in targetAnchorRanges) {
        for (DateTime date = range.start;
            !date.isAfter(range.end);
            date = date.add(const Duration(days: 1))) {
          if (selectedWeekDay.contains(date.weekday)) {
            targetDates.add(date);
          }
        }
      }
    }

    if (type == RepeatEvery.xMonth) {
      targetDates = repeatOn.map((e) => e.copyWith(month: targetAnchorRanges[0].start.month)).toList();
    }

    if (type == RepeatEvery.xYear) {
      targetDates = repeatOn.map((e) => e.copyWith(month: targetAnchorRanges[0].start.month)).toList();
    }

    targetDates.removeWhere((element) => !element.isAfter(startOn));

    print(targetDates);

    return targetDates.map((e) => transactionData.withDateTime(e)).toList();
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
      transactionData: TransactionData.fromDatabase(db.transactionData!),
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
    required this.transactionData,
    required this.addedTransactions,
    required this.skippedOn,
  });
}

@immutable
class TransactionData extends BaseEmbeddedModel<TransactionDataDb> {
  final TransactionType type;

  final DateTime? dateTime;

  final double? amount;

  final String? note;

  final AccountInfo? account;

  final AccountInfo? toAccount;

  final Category? category;

  final CategoryTag? categoryTag;

  const TransactionData._(
    super._databaseObject,
    this.type,
    this.amount,
    this.note,
    this.account,
    this.toAccount,
    this.category,
    this.categoryTag, {
    this.dateTime,
  });

  static TransactionData fromDatabase(TransactionDataDb dataDb) {
    return TransactionData._(
      dataDb,
      TransactionType.fromDatabaseValue(dataDb.type),
      dataDb.amount,
      dataDb.note,
      Account.fromDatabaseInfoOnly(dataDb.account),
      Account.fromDatabaseInfoOnly(dataDb.transferAccount),
      Category.fromDatabase(dataDb.category),
      CategoryTag.fromDatabase(dataDb.categoryTag),
      dateTime: dataDb.dateTime?.toLocal(),
    );
  }

  TransactionData withDateTime(DateTime dateTime) {
    return TransactionData._(
      databaseObject,
      type,
      amount,
      note,
      account,
      toAccount,
      category,
      categoryTag,
      dateTime: dateTime,
    );
  }
}
