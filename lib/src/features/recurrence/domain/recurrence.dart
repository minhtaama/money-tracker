import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:realm/realm.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';

class Recurrence extends BaseModel<RecurrenceDb> {
  final RepeatEvery _type;

  /// # Interval
  /// means `targetDate` = `startDate` * nth * [_interval].
  ///
  /// Similar to "every X days/weeks/months/years".
  final int _interval;

  /// # Only year, month, day
  ///
  /// ## WARNING: These DateTimes do not reflect the correct day to write transaction.
  /// ## Use [Recurrence.getAllPlannedTransactionsInMonth] instead.
  final List<DateTime> _patterns;

  /// **Key**: ObjectID's hexString of the linked/written transaction.
  ///
  /// **Value**: the DateTime that this transaction should be repeated on.
  /// This DateTime maybe different from the transaction's DateTime in case
  /// of user customization. This value is used to compare with the [TransactionData.dateTime] values
  /// returns from [Recurrence.getAllPlannedTransactionsInMonth] function.
  final Map<String, DateTime> _addedOn;

  final List<DateTime> _skippedOn;

  /// # Only year, month, day
  final DateTime startOn;

  /// # Only year, month, day
  final DateTime? endOn;

  final bool autoCreateTransaction;

  /// This [transactionData.dateTime] and [transactionData.state] is `null`
  final TransactionData transactionData;

  /// This function evaluates the [_patterns] and returns [TransactionData] objects
  /// which has its [TransactionData.dateTime] correctly aligned with the [_patterns] in the
  /// current month (and only contains year, month and day values). [TransactionData.state] values from this
  /// function is not null and reflect the state of planned transactions.
  List<TransactionData> getAllPlannedTransactionsInMonth(BuildContext context, DateTime dateTime) {
    final targetMonthRange = dateTime.monthRange;
    if (targetMonthRange.end.isBefore(startOn)) {
      return [];
    }

    final startAnchorDate = switch (_type) {
      RepeatEvery.xDay => startOn,
      RepeatEvery.xWeek => startOn.weekRange(context).start,
      RepeatEvery.xMonth => startOn.monthRange.start,
      RepeatEvery.xYear => startOn.yearRange.start,
    };

    // Get anchorRange of current month

    final List<DateTimeRange> targetAnchorRanges = switch (_type) {
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
      if (range.start.getDaysDifferent(startAnchorDate) % _interval != 0) {
        toRemove.add(range);
      }
    }

    targetAnchorRanges.removeWhere((e) => toRemove.contains(e));

    // Now, for each kind of repeat type, we extract the date in range
    // which is suitable with the condition of `repeatOn`.

    List<DateTime> targetDates = [];

    if (_type == RepeatEvery.xDay) {
      // Because targetAnchorRanges contains dayRange (from 0:0:0 to 23:59:59 of same day)
      targetDates = targetAnchorRanges.map((e) => e.start.onlyYearMonthDay).toList();
    }

    if (_type == RepeatEvery.xWeek) {
      final selectedWeekDay = _patterns.map((e) => e.weekday);

      for (DateTimeRange range in targetAnchorRanges) {
        for (DateTime date = range.start; !date.isAfter(range.end); date = date.add(const Duration(days: 1))) {
          if (selectedWeekDay.contains(date.weekday)) {
            targetDates.add(date.onlyYearMonthDay);
          }
        }
      }
    }

    if (_type == RepeatEvery.xMonth) {
      targetDates =
          _patterns.map((e) => e.copyWith(month: targetAnchorRanges[0].start.month).onlyYearMonthDay).toList();
    }

    if (_type == RepeatEvery.xYear) {
      targetDates =
          _patterns.map((e) => e.copyWith(month: targetAnchorRanges[0].start.month).onlyYearMonthDay).toList();
    }

    targetDates.removeWhere((element) => !element.isAfter(startOn));

    if (endOn != null) {
      targetDates.removeWhere((element) => element.isAfter(endOn!));
    }

    final today = DateTime.now().copyWith(day: 19).onlyYearMonthDay;

    return targetDates.map((targetDate) {
      PlannedState state = PlannedState.upcoming;

      if (_addedOn.values.contains(targetDate)) {
        state = PlannedState.added;
      } else if (_skippedOn.contains(targetDate)) {
        state = PlannedState.skipped;
      } else if (targetDate.isBefore(today)) {
        state = PlannedState.overdue;
      } else if (targetDate.isSameDayAs(today)) {
        state = PlannedState.today;
      }

      return transactionData.withDateTimeAndState(
        dateTime: targetDate.onlyYearMonthDay,
        state: state,
      );
    }).toList();
  }

  /// The expression of how this recurrence is repeated
  String expression(BuildContext context) {
    String everyN;
    String repeatPattern;

    switch (_type) {
      case RepeatEvery.xDay:
        everyN = context.loc.everyNDay(_interval);
        repeatPattern = '';
        break;

      case RepeatEvery.xWeek:
        final sort = List<DateTime>.from(_patterns)..sort((a, b) => a.weekday - b.weekday);
        final list = sort
            .map(
              (date) => date.weekdayToString(
                context,
                short: _patterns.length <= 2 ? false : true,
              ),
            )
            .toList();

        everyN = context.loc.everyNWeek(_interval);
        repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xWeek', list.join(', '));
        break;

      case RepeatEvery.xMonth:
        final sort = List<DateTime>.from(_patterns)..sort((a, b) => a.day - b.day);
        final list = sort
            .map(
              (date) => date.dayToString(context),
            )
            .toList();

        everyN = context.loc.everyNMonth(_interval);
        repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xMonth', list.join(', '));
        break;

      case RepeatEvery.xYear:
        final sort = List<DateTime>.from(_patterns)..sort((a, b) => a.compareTo(b));
        final list = sort
            .map(
              (date) => date.toShortDate(context, noYear: true),
            )
            .toList();

        everyN = context.loc.everyNYear(_interval);
        repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xYear', list.join(', '));
        break;
    }

    String startDate =
        startOn.isSameDayAs(DateTime.now()) ? context.loc.today.toLowerCase() : startOn.toShortDate(context);
    String endDate = endOn != null ? context.loc.untilEndDate(endOn!.toShortDate(context)) : '';

    return context.loc.quoteRecurrence3(
      everyN,
      repeatPattern,
      startOn.isSameDayAs(DateTime.now()).toString(),
      startDate,
      endDate,
    );
  }

  static Recurrence? fromDatabase(RecurrenceDb? db) {
    if (db == null) {
      return null;
    }

    return Recurrence._(
      db,
      type: RepeatEvery.fromDatabaseValue(db.type),
      interval: db.repeatInterval,
      patterns: db.patterns.map((e) => e.toLocal()).toList(),
      startOn: db.startOn.toLocal(),
      endOn: db.endOn?.toLocal(),
      autoCreateTransaction: db.autoCreateTransaction,
      transactionData: TransactionData.fromDatabase(db.transactionData!),
      addedOn: db.addedOn,
      skippedOn: db.skippedOn.map((dateTime) => dateTime.toLocal()).toList(),
    );
  }

  const Recurrence._(
    super.databaseObject, {
    required RepeatEvery type,
    required int interval,
    required List<DateTime> patterns,
    required this.startOn,
    this.endOn,
    required this.autoCreateTransaction,
    required this.transactionData,
    required Map<String, DateTime> addedOn,
    required List<DateTime> skippedOn,
  })  : _type = type,
        _skippedOn = skippedOn,
        _addedOn = addedOn,
        _interval = interval,
        _patterns = patterns;
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

  final PlannedState? state;

  Recurrence get recurrence => Recurrence.fromDatabase(databaseObject.parent as RecurrenceDb)!;

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
    this.state,
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

  TransactionData withDateTimeAndState({required DateTime dateTime, required PlannedState state}) {
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
      state: state,
    );
  }

  @override
  String toString() {
    return 'TransactionData{type: ${type.name}, dateTime: $dateTime, amount: $amount, note: $note, account: ${account?.name}, toAccount: ${toAccount?.name}, category: ${category?.name}, categoryTag: ${categoryTag?.name}}';
  }
}

enum PlannedState {
  upcoming,
  today,
  added,
  skipped,
  overdue,
}
