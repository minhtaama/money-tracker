part of 'date_time_selector_components.dart';

Future<DateTime?> showCreditSpendingDateTimeEditDialog(BuildContext context,
    {required DateTime current, required CreditAccount creditAccount, required Statement statement}) async {
  final DateTime lastCheckpointDateTime = creditAccount.latestCheckpointDateTime;
  final DateTime previousDueDate = statement.previousDueDate;
  final DateTime dueDate = statement.dueDate;

  final paymentTxnsDateTime = creditAccount.paymentTransactions.map((e) => e.dateTime.onlyYearMonthDay);

  final dateOfPaymentBefore = paymentTxnsDateTime.lastWhere(
    (dt) => !dt.onlyYearMonthDay.isAfter(current.onlyYearMonthDay),
    orElse: () => Calendar.minDate,
  );
  final dateOfPaymentAfter = paymentTxnsDateTime.firstWhere(
    (dt) => dt.onlyYearMonthDay.isAfter(current.onlyYearMonthDay),
    orElse: () => Calendar.maxDate,
  );

  bool canAddTransaction(DateTime dateTime) {
    return !dateTime.isBefore(lastCheckpointDateTime) &&
        dateTime.isAfter(previousDueDate) &&
        !dateTime.isAfter(dueDate) &&
        !dateTime.isBefore(dateOfPaymentBefore) &&
        dateTime.isBefore(dateOfPaymentAfter);
  }

  Widget dayBuilder(BuildContext context,
      {required DateTime date,
      BoxDecoration? decoration,
      bool? isDisabled,
      bool? isSelected,
      bool? isToday,
      TextStyle? textStyle}) {
    final dateTimeYMD = date.onlyYearMonthDay;

    final hasSpendingTransaction = dateTimeYMD.isAtSameMomentAs(current.onlyYearMonthDay);
    final hasPaymentTransaction =
        dateTimeYMD.isAtSameMomentAs(dateOfPaymentBefore) || dateTimeYMD.isAtSameMomentAs(dateOfPaymentAfter);
    final isDueDate = date.day == creditAccount.paymentDueDay;
    final isStatementDate = date.day == creditAccount.statementDay;

    final foregroundColor = isDisabled != null && isDisabled
        ? AppColors.greyBgr(context)
        : isSelected != null && isSelected
            ? context.appTheme.onPrimary
            : context.appTheme.onBackground.withOpacity(canAddTransaction(date) ? 1 : 0.33);

    final bgrColor = isSelected != null && isSelected ? context.appTheme.primary : Colors.transparent;
    final bgrBorder = isToday != null && isToday
        ? Border.all(
            color: isDisabled != null && isDisabled ? AppColors.greyBgr(context) : context.appTheme.primary,
          )
        : null;

    Widget icon(String path, {Color? color}) =>
        Expanded(child: SvgIcon(path, color: color ?? foregroundColor, size: 23));

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 33,
          width: 33,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            border: bgrBorder,
            color: bgrColor,
          ),
        ),
        !isStatementDate && !isDueDate && !hasPaymentTransaction && !hasSpendingTransaction || isSelected!
            ? Text(
                date.day.toString(),
                style: kHeader3TextStyle.copyWith(
                    color: foregroundColor, height: 0.99, fontSize: kHeader4TextStyle.fontSize),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isStatementDate ? icon(AppIcons.budgets) : Gap.noGap,
                  isDueDate ? icon(AppIcons.handCoin) : Gap.noGap,
                  hasSpendingTransaction
                      ? icon(AppIcons.receiptDollar,
                          color: context.appTheme.negative.withOpacity(canAddTransaction(date) ? 1 : 0.33))
                      : Gap.noGap,
                  hasPaymentTransaction
                      ? icon(AppIcons.receiptCheck,
                          color: context.appTheme.positive.withOpacity(canAddTransaction(date) ? 1 : 0.33))
                      : Gap.noGap,
                ],
              ),
      ],
    );
  }

  return showCustomDialog(
      context: context,
      builder: (_, __) {
        DateTime result = current;
        return _CustomCalendarDialog(
          config: _customConfig(
            context,
            firstDate: null,
            selectableDayPredicate: null,
            dayBuilder: dayBuilder,
          ),
          currentDay: current,
          currentMonthView: current,
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
            if (dateTime != null) {
              if (dateTime.isBefore(lastCheckpointDateTime)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'You can only select day after [latest checkpoint]'.hardcoded,
                  ),
                );
              } else if (!dateTime.isAfter(previousDueDate)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! You can only select day since [the statement contains the latest payment]'.hardcoded,
                  ),
                );
              } else if (dateTime.isAfter(dueDate)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! This is future statement!'.hardcoded,
                  ),
                );
              } else if (dateTime.isBefore(dateOfPaymentBefore) || !dateTime.isBefore(dateOfPaymentAfter)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! There is a payment between the current date and the selected date'.hardcoded,
                  ),
                );
              } else {
                result = result.copyWith(
                  day: dateTime.day,
                  month: dateTime.month,
                  year: dateTime.year,
                );

                context.pop<DateTime>(result);
              }
            }
          },
        );
      });
}

/// Return a list has index 0 is [DateTime], index 1 is [Statement]?
Future<List<dynamic>?> showCreditPaymentDateTimeEditDialog(BuildContext context,
    {required DateTime current, required CreditAccount creditAccount, required Statement statement}) async {
  final DateTime lastCheckpointDateTime = creditAccount.latestCheckpointDateTime;
  final DateTime previousDueDate = statement.previousDueDate;
  final DateTime statementDate = statement.statementDate;
  final DateTime dueDate = statement.dueDate;

  final spendingTxnsDateTime = creditAccount.spendingTransactions.map((e) => e.dateTime.onlyYearMonthDay);

  final dateOfSpendingBefore = spendingTxnsDateTime.lastWhere(
    (dt) => !dt.onlyYearMonthDay.isAfter(current.onlyYearMonthDay),
    orElse: () => Calendar.minDate,
  );

  final dateOfSpendingAfter = spendingTxnsDateTime.firstWhere(
    (dt) => dt.onlyYearMonthDay.isAfter(current.onlyYearMonthDay),
    orElse: () => Calendar.maxDate,
  );

  bool canAddTransaction(DateTime dateTime) {
    if (creditAccount.statementType != StatementType.payOnlyInGracePeriod) {
      return !dateTime.isBefore(lastCheckpointDateTime) &&
          dateTime.isAfter(previousDueDate) &&
          !dateTime.isAfter(dueDate) &&
          dateTime.isAfter(dateOfSpendingBefore) &&
          !dateTime.isAfter(dateOfSpendingAfter);
    }

    return !dateTime.isBefore(lastCheckpointDateTime) &&
        !dateTime.isBefore(statementDate) &&
        !dateTime.isAfter(dueDate) &&
        dateTime.isAfter(dateOfSpendingBefore) &&
        !dateTime.isAfter(dateOfSpendingAfter);
  }

  Widget dayBuilder(BuildContext context,
      {required DateTime date,
      BoxDecoration? decoration,
      bool? isDisabled,
      bool? isSelected,
      bool? isToday,
      TextStyle? textStyle}) {
    final dateTimeYMD = date.onlyYearMonthDay;

    final hasPayment = dateTimeYMD.isAtSameMomentAs(current.onlyYearMonthDay);
    final hasSpending =
        dateTimeYMD.isAtSameMomentAs(dateOfSpendingBefore) || dateTimeYMD.isAtSameMomentAs(dateOfSpendingAfter);
    final isDueDate = date.day == creditAccount.paymentDueDay;
    final isStatementDate = date.day == creditAccount.statementDay;

    final foregroundColor = isDisabled != null && isDisabled
        ? AppColors.greyBgr(context)
        : isSelected != null && isSelected
            ? context.appTheme.onPrimary
            : context.appTheme.onBackground.withOpacity(canAddTransaction(date) ? 1 : 0.33);

    final bgrColor = isSelected != null && isSelected ? context.appTheme.primary : Colors.transparent;
    final bgrBorder = isToday != null && isToday
        ? Border.all(
            color: isDisabled != null && isDisabled ? AppColors.greyBgr(context) : context.appTheme.primary,
          )
        : null;

    Widget icon(String path, {Color? color}) =>
        Expanded(child: SvgIcon(path, color: color ?? foregroundColor, size: 23));

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 33,
          width: 33,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            border: bgrBorder,
            color: bgrColor,
          ),
        ),
        !isStatementDate && !isDueDate && !hasSpending && !hasPayment || isSelected!
            ? Text(
                date.day.toString(),
                style: kHeader3TextStyle.copyWith(
                    color: foregroundColor, height: 0.99, fontSize: kHeader4TextStyle.fontSize),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isStatementDate ? icon(AppIcons.budgets) : Gap.noGap,
                  isDueDate ? icon(AppIcons.handCoin) : Gap.noGap,
                  hasPayment
                      ? icon(AppIcons.receiptCheck,
                          color: context.appTheme.positive.withOpacity(canAddTransaction(date) ? 1 : 0.33))
                      : Gap.noGap,
                  hasSpending
                      ? icon(AppIcons.receiptDollar,
                          color: context.appTheme.negative.withOpacity(canAddTransaction(date) ? 1 : 0.33))
                      : Gap.noGap,
                ],
              ),
      ],
    );
  }

  return showCustomDialog(
      context: context,
      builder: (_, __) {
        DateTime result = current;
        return _CustomCalendarDialog(
          config: _customConfig(
            context,
            firstDate: null,
            selectableDayPredicate: null,
            dayBuilder: dayBuilder,
          ),
          currentDay: current,
          currentMonthView: current,
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
            if (dateTime != null) {
              if (dateTime.isBefore(lastCheckpointDateTime)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'You can only select day after [latest checkpoint]'.hardcoded,
                  ),
                );
              } else if (!dateTime.isAfter(previousDueDate)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! You can only select day since [the statement contains the latest payment]'.hardcoded,
                  ),
                );
              } else if (dateTime.isAfter(dueDate)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! This is future statement!'.hardcoded,
                  ),
                );
              } else if (!dateTime.isAfter(dateOfSpendingBefore) || dateTime.isAfter(dateOfSpendingAfter)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! There is a spending between current date and selected date'.hardcoded,
                  ),
                );
              } else if (dateTime.isBefore(statementDate) &&
                  creditAccount.statementType == StatementType.payOnlyInGracePeriod) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! Can only pay in grace period (Account preference)'.hardcoded,
                  ),
                );
              } else {
                result = result.copyWith(
                  day: dateTime.day,
                  month: dateTime.month,
                  year: dateTime.year,
                );
                final statement = creditAccount.statementAt(result, upperGapAtDueDate: true);

                context.pop<List<dynamic>>([result, statement]);
              }
            }
          },
        );
      });
}
