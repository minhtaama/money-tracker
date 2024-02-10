part of 'date_time_selector.dart';

Future<DateTime?> showRegularDateTimeEditDialog(
  BuildContext context, {
  required DateTime dbDateTime,
  required DateTime? selectedDateTime,
}) async {
  return showStatefulDialog(
      context: context,
      builder: (_, __) {
        DateTime result = selectedDateTime ?? dbDateTime;
        return _CustomCalendarDialog(
          config: _customConfig(context, dayBuilder: _dayBuilderRegular),
          currentDay: result,
          contentBuilder: ({required DateTime monthView, DateTime? selectedDay}) {
            return _CustomTimePickSpinner(
              time: result,
              onTimeChange: (dateTime) {
                result = result.copyWith(
                  hour: dateTime.hour,
                  minute: dateTime.minute,
                );
              },
            );
          },
          onActionButtonTap: (dateTime) {
            if (dateTime != null) {
              result = result.copyWith(
                day: dateTime.day,
                month: dateTime.month,
                year: dateTime.year,
              );
            }
            context.pop<DateTime>(result);
          },
        );
      });
}

Future<DateTime?> showCreditSpendingDateTimeEditDialog(
  BuildContext context, {
  required DateTime dbDateTime,
  required DateTime? selectedDateTime,
  required CreditAccount creditAccount,
  required Statement statement,
}) async {
  final DateTime lastCheckpointDateTime = creditAccount.latestCheckpointDateTime;
  final DateTime previousDueDate = statement.date.previousDue;
  final DateTime dueDate = statement.date.due;

  final paymentDateTimes = creditAccount.paymentTransactions.map((e) => e.dateTime.onlyYearMonthDay);
  final spendingDateTimes = creditAccount.spendingTransactions.map((e) => e.dateTime.onlyYearMonthDay);
  final checkpointDateTimes =
      creditAccount.checkpointTransactions.map((e) => e.dateTime.onlyYearMonthDay);

  final dateOfPaymentBefore = paymentDateTimes.lastWhere(
    (dt) => !dt.onlyYearMonthDay.isAfter(dbDateTime.onlyYearMonthDay),
    orElse: () => Calendar.minDate,
  );
  final dateOfPaymentAfter = paymentDateTimes.firstWhere(
    (dt) => dt.onlyYearMonthDay.isAfter(dbDateTime.onlyYearMonthDay),
    orElse: () => Calendar.maxDate,
  );

  bool canSubmit(DateTime dateTime, {bool showDialog = false}) {
    final beforeLastCheckpoint = dateTime.isBefore(lastCheckpointDateTime);
    final inPreviousStatement = !dateTime.isAfter(previousDueDate);
    final inNextStatement = dateTime.isAfter(dueDate);
    final notBetweenPayments =
        dateTime.isBefore(dateOfPaymentBefore) || !dateTime.isBefore(dateOfPaymentAfter);

    if (beforeLastCheckpoint) {
      showErrorDialog(
        context,
        'You can only select day after [latest checkpoint]'.hardcoded,
        enable: showDialog,
      );

      return false;
    }

    if (inPreviousStatement || inNextStatement) {
      showErrorDialog(
        context,
        'Oops! You can only select day in this statement'.hardcoded,
        enable: showDialog,
      );

      return false;
    }

    if (notBetweenPayments) {
      showErrorDialog(
        context,
        'Oops! There is a payment between current date and selected date'.hardcoded,
        enable: showDialog,
      );

      return false;
    }

    return true;
  }

  Widget dayBuilder(
    BuildContext context, {
    required DateTime date,
    BoxDecoration? decoration,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday,
    TextStyle? textStyle,
  }) {
    final dateTimeYMD = date.onlyYearMonthDay;

    return _DayBuilder.forCredit(
      context,
      date,
      isDisabled,
      isSelected,
      isToday,
      canAddTransaction: canSubmit(date),
      hasPayment: paymentDateTimes.contains(dateTimeYMD),
      hasSpending: spendingDateTimes.contains(dateTimeYMD),
      hasCheckpoint: checkpointDateTimes.contains(dateTimeYMD),
      isStatementDay: date.day == creditAccount.statementDay,
      isDueDay: date.day == creditAccount.paymentDueDay,
    );
  }

  return showStatefulDialog(
      context: context,
      builder: (_, __) {
        DateTime result = selectedDateTime ?? dbDateTime;
        return _CustomCalendarDialog(
          config: _customConfig(
            context,
            firstDate: null,
            selectableDayPredicate: null,
            dayBuilder: dayBuilder,
          ),
          currentDay: result,
          currentMonthView: result,
          contentBuilder: ({required DateTime monthView, DateTime? selectedDay}) {
            return _CustomTimePickSpinner(
              time: result,
              onTimeChange: (dateTime) {
                result = result.copyWith(
                  hour: dateTime.hour,
                  minute: dateTime.minute,
                );
              },
            );
          },
          onActionButtonTap: (dateTime) async {
            if (dateTime != null && canSubmit(dateTime, showDialog: true)) {
              result = result.copyWith(
                day: dateTime.day,
                month: dateTime.month,
                year: dateTime.year,
              );

              context.pop<DateTime>(result);
            }
          },
        );
      });
}

/// Return a list has index 0 is [DateTime], index 1 is [Statement]?
Future<List<dynamic>?> showCreditPaymentDateTimeEditDialog(
  BuildContext context, {
  required DateTime dbDateTime,
  required DateTime? selectedDateTime,
  required CreditAccount creditAccount,
  required Statement statement,
}) async {
  final DateTime lastCheckpointDateTime = creditAccount.latestCheckpointDateTime;
  final DateTime previousDueDate = statement.date.previousDue;
  final DateTime statementDate = statement.date.statement;
  final DateTime dueDate = statement.date.due;

  final paymentDateTimes = creditAccount.paymentTransactions.map((e) => e.dateTime.onlyYearMonthDay);
  final spendingDateTimes = creditAccount.spendingTransactions.map((e) => e.dateTime.onlyYearMonthDay);
  final checkpointDateTimes =
      creditAccount.checkpointTransactions.map((e) => e.dateTime.onlyYearMonthDay);

  final dateOfSpendingBefore = spendingDateTimes.lastWhere(
    (dt) => !dt.onlyYearMonthDay.isAfter(dbDateTime.onlyYearMonthDay),
    orElse: () => Calendar.minDate,
  );

  final dateOfSpendingAfter = spendingDateTimes.firstWhere(
    (dt) => dt.onlyYearMonthDay.isAfter(dbDateTime.onlyYearMonthDay),
    orElse: () => Calendar.maxDate,
  );

  bool canSubmit(DateTime dateTime, {bool showDialog = false}) {
    final beforeLastCheckpoint = dateTime.isBefore(lastCheckpointDateTime);
    final inPreviousStatement = !dateTime.isAfter(previousDueDate);
    final inNextStatement = dateTime.isAfter(dueDate);
    final notBetweenSpendings =
        !dateTime.isAfter(dateOfSpendingBefore) || dateTime.isAfter(dateOfSpendingAfter);
    final canPayOnlyInGracePeriod = creditAccount.statementType == StatementType.payOnlyInGracePeriod;
    final notInGracePeriod = dateTime.isBefore(statementDate);

    if (beforeLastCheckpoint) {
      showErrorDialog(
        context,
        'You can only select day after [latest checkpoint]'.hardcoded,
        enable: showDialog,
      );

      return false;
    }

    if (inPreviousStatement || inNextStatement) {
      showErrorDialog(
        context,
        'Oops! You can only select day in this statement'.hardcoded,
        enable: showDialog,
      );

      return false;
    }

    if (notBetweenSpendings) {
      showErrorDialog(
        context,
        'Oops! There is a spending between current date and selected date'.hardcoded,
        enable: showDialog,
      );

      return false;
    }

    if (notInGracePeriod && canPayOnlyInGracePeriod) {
      showErrorDialog(
        context,
        'Oops! Can only pay in grace period (Account preference)'.hardcoded,
        enable: showDialog,
      );

      return false;
    }

    return true;
  }

  Widget dayBuilder(
    BuildContext context, {
    required DateTime date,
    BoxDecoration? decoration,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday,
    TextStyle? textStyle,
  }) {
    final dateTimeYMD = date.onlyYearMonthDay;

    return _DayBuilder.forCredit(
      context,
      date,
      isDisabled,
      isSelected,
      isToday,
      canAddTransaction: canSubmit(date),
      hasPayment: paymentDateTimes.contains(dateTimeYMD),
      hasSpending: spendingDateTimes.contains(dateTimeYMD),
      hasCheckpoint: checkpointDateTimes.contains(dateTimeYMD),
      isStatementDay: date.day == creditAccount.statementDay,
      isDueDay: date.day == creditAccount.paymentDueDay,
    );
  }

  return showStatefulDialog(
      context: context,
      builder: (_, __) {
        DateTime result = selectedDateTime ?? dbDateTime;
        return _CustomCalendarDialog(
          config: _customConfig(context, dayBuilder: dayBuilder),
          currentDay: result,
          currentMonthView: result,
          contentBuilder: ({required DateTime monthView, DateTime? selectedDay}) {
            return _CustomTimePickSpinner(
              time: result,
              onTimeChange: (dateTime) {
                result = result.copyWith(
                  hour: dateTime.hour,
                  minute: dateTime.minute,
                );
              },
            );
          },
          onActionButtonTap: (dateTime) async {
            if (dateTime != null && canSubmit(dateTime, showDialog: true)) {
              result = result.copyWith(
                day: dateTime.day,
                month: dateTime.month,
                year: dateTime.year,
              );
              final statement = creditAccount.statementAt(result, upperGapAtDueDate: true);

              context.pop<List<dynamic>>([result, statement]);
            }
          },
        );
      });
}
