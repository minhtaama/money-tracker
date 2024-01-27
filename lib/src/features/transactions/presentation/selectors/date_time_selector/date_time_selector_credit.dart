part of 'date_time_selector_components.dart';

Future<DateTime?> showCreditSpendingDateTimeEditDialog(BuildContext context,
    {required DateTime current, required CreditAccount creditAccount}) async {
  final DateTime lastCheckpointDateTime = creditAccount.latestCheckpointDateTime;
  final DateTime canAddTransactionSinceDateTime = creditAccount.latestStatementDueDate;
  final DateTime todayStatementDueDate = creditAccount.todayStatementDueDate;
  final int statementDay = creditAccount.statementDay;

  final paymentTxnsDateTime = creditAccount.paymentTransactions.map((e) => e.dateTime.onlyYearMonthDay);
  final dueDates = creditAccount.statementsList.map((e) => e.dueDate.onlyYearMonthDay).toList();
  if (creditAccount.statementsList.isNotEmpty) {
    dueDates.add(creditAccount.statementsList.first.previousStatement.dueDate);
  }

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
        dateTime.isAfter(canAddTransactionSinceDateTime) &&
        !dateTime.isAfter(todayStatementDueDate) &&
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
    final isDueDate = dueDates.contains(dateTimeYMD);
    final isStatementDate = date.day == statementDay;

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
              } else if (!dateTime.isAfter(canAddTransactionSinceDateTime)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! You can only select day since [the statement contains the latest payment]'.hardcoded,
                  ),
                );
              } else if (dateTime.isAfter(todayStatementDueDate)) {
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
    {required DateTime current, required CreditAccount creditAccount}) async {
  final DateTime lastCheckpointDateTime = creditAccount.latestCheckpointDateTime;
  final DateTime canAddTransactionSinceDateTime = creditAccount.latestStatementDueDate;
  final DateTime todayStatementDueDate = creditAccount.todayStatementDueDate;
  final int statementDay = creditAccount.statementDay;

  final spendingTxnsDateTime = creditAccount.spendingTransactions.map((e) => e.dateTime.onlyYearMonthDay);
  final dueDates = creditAccount.statementsList.map((e) => e.dueDate.onlyYearMonthDay).toList();
  if (creditAccount.statementsList.isNotEmpty) {
    dueDates.add(creditAccount.statementsList.first.previousStatement.dueDate);
  }

  final dateOfSpendingBefore = spendingTxnsDateTime.lastWhere(
    (dt) => !dt.onlyYearMonthDay.isAfter(current.onlyYearMonthDay),
    orElse: () => Calendar.minDate,
  );
  final dateOfSpendingAfter = spendingTxnsDateTime.firstWhere(
    (dt) => dt.onlyYearMonthDay.isAfter(current.onlyYearMonthDay),
    orElse: () => Calendar.maxDate,
  );

  bool canAddTransaction(DateTime dateTime) {
    return !dateTime.isBefore(lastCheckpointDateTime) &&
        dateTime.isAfter(canAddTransactionSinceDateTime) &&
        !dateTime.isAfter(todayStatementDueDate) &&
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
    final isDueDate = dueDates.contains(dateTimeYMD);
    final isStatementDate = date.day == statementDay;

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
              } else if (!dateTime.isAfter(canAddTransactionSinceDateTime)) {
                showCustomDialog2(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFace,
                    color: context.appTheme.onBackground,
                    header: 'Oops! You can only select day since [the statement contains the latest payment]'.hardcoded,
                  ),
                );
              } else if (dateTime.isAfter(todayStatementDueDate)) {
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
              } else {
                result = result.copyWith(
                  day: dateTime.day,
                  month: dateTime.month,
                  year: dateTime.year,
                );
                final statement = creditAccount.statementAt(result);

                context.pop<List<dynamic>>([result, statement]);
              }
            }
          },
        );
      });
}

class DateTimeSelectorCredit extends ConsumerStatefulWidget {
  const DateTimeSelectorCredit(
      {super.key,
      this.creditAccount,
      this.initialDate,
      required this.onChanged,
      this.isForPayment = true,
      this.disableText});

  final CreditAccount? creditAccount;
  final bool isForPayment;
  final DateTime? initialDate;
  final Function(DateTime, Statement?) onChanged;
  final String? disableText;

  @override
  ConsumerState<DateTimeSelectorCredit> createState() => _DateTimeSelectorCreditState();
}

class _DateTimeSelectorCreditState extends ConsumerState<DateTimeSelectorCredit> {
  late DateTime _lastCheckpointDateTime = widget.creditAccount!.latestCheckpointDateTime;
  late DateTime _canAddTransactionSinceDateTime = widget.creditAccount!.latestStatementDueDate;
  late DateTime _todayStatementDueDate = widget.creditAccount!.todayStatementDueDate;

  late DateTime? _outputDateTime = widget.initialDate;
  Statement? _outputStatement;

  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  DateTime _currentMonthView = DateTime.now();

  late int? _statementDay = widget.creditAccount?.statementDay;

  final _key = GlobalKey();
  Size _size = const Size(0.0, 0.0);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _size = _key.currentContext!.size!;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DateTimeSelectorCredit oldWidget) {
    if (widget.creditAccount != null) {
      _statementDay = widget.creditAccount!.statementDay;
      _outputDateTime = widget.initialDate;
      _lastCheckpointDateTime = widget.creditAccount!.latestCheckpointDateTime;
      _canAddTransactionSinceDateTime = widget.creditAccount!.latestStatementDueDate;
      _todayStatementDueDate = widget.creditAccount!.todayStatementDueDate;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _submit(DateTime dateTime) {
    _currentMonthView = dateTime;

    _outputDateTime = dateTime.copyWith(hour: _selectedHour, minute: _selectedMinute);
    _outputStatement = widget.creditAccount!.statementAt(_outputDateTime!);

    widget.onChanged(_outputDateTime!, _outputStatement);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: CardItem(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          elevation: 0,
          border:
              Border.all(color: context.appTheme.onBackground.withOpacity(widget.creditAccount == null ? 0.1 : 0.4)),
          color: Colors.transparent,
          child: Stack(
            children: [
              Column(
                key: _key,
                children: [
                  _CustomTimePickSpinner(
                    onTimeChange: (newTime) {
                      _selectedHour = newTime.hour;
                      _selectedMinute = newTime.minute;

                      if (_outputDateTime != null) {
                        setState(() {
                          _outputDateTime = _outputDateTime!.copyWith(hour: _selectedHour, minute: _selectedMinute);
                        });
                        widget.onChanged(_outputDateTime!, _outputStatement);
                      }
                    },
                  ),
                  CustomInkWell(
                    inkColor: AppColors.grey(context),
                    onTap: () async {
                      if (widget.creditAccount != null) {
                        await showCustomDialog(
                          context: context,
                          builder: (context, setState) {
                            return _CustomCalendarDialog(
                              config: _customConfig(
                                context,
                                firstDate: null,
                                selectableDayPredicate: null,
                                dayBuilder: _dayBuilder,
                              ),
                              currentDay: _outputDateTime,
                              currentMonthView: _currentMonthView,
                              onActionButtonTap: (dateTime) async {
                                if (dateTime != null) {
                                  if (dateTime.isBefore(_lastCheckpointDateTime)) {
                                    showCustomDialog2(
                                      context: context,
                                      child: IconWithText(
                                        iconPath: AppIcons.sadFace,
                                        color: context.appTheme.onBackground,
                                        header: 'You can only add transaction after [latest checkpoint]'.hardcoded,
                                      ),
                                    );
                                  } else if (!dateTime.isAfter(_canAddTransactionSinceDateTime)) {
                                    showCustomDialog2(
                                      context: context,
                                      child: IconWithText(
                                        iconPath: AppIcons.sadFace,
                                        color: context.appTheme.onBackground,
                                        header:
                                            'Oops! You can only add transactions since [the statement contains the latest payment]'
                                                .hardcoded,
                                      ),
                                    );
                                  } else if (dateTime.isAfter(_todayStatementDueDate)) {
                                    showCustomDialog2(
                                      context: context,
                                      child: IconWithText(
                                        iconPath: AppIcons.sadFace,
                                        color: context.appTheme.onBackground,
                                        header: 'Oops! This is future statement!'.hardcoded,
                                      ),
                                    );
                                  } else {
                                    _submit(dateTime);
                                  }
                                }
                              },
                              contentBuilder: ({required DateTime monthView, DateTime? selectedDay}) {
                                return AnimatedSize(
                                  duration: k150msDuration,
                                  child: widget.creditAccount!.earliestPayableDate == null
                                      ? IconWithText(
                                          iconPath: AppIcons.done,
                                          header:
                                              'This credit account currently has no credit/BNPL transaction needed to pay'
                                                  .hardcoded,
                                        )
                                      : monthView.isBefore(widget.creditAccount!.earliestPayableDate!
                                              .copyWith(month: widget.creditAccount!.earliestPayableDate!.month - 1))
                                          ? IconWithText(
                                              iconPath: AppIcons.done,
                                              header: 'No transactions before this time'.hardcoded,
                                            )
                                          : selectedDay != null
                                              ? CreditInfo(
                                                  chosenDateTime: selectedDay,
                                                  showPaymentAmount: widget.isForPayment &&
                                                      !selectedDay.isBefore(widget.creditAccount!.earliestPayableDate!),
                                                  statement: widget.creditAccount!.statementAt(selectedDay),
                                                  onDateTap: (dateTime) => setState(() {
                                                    _currentMonthView = dateTime;
                                                  }),
                                                )
                                              : IconWithText(
                                                  iconPath: AppIcons.today,
                                                  header:
                                                      'Select a payment day.\n Spending transaction can be paid will be displayed here'
                                                          .hardcoded,
                                                ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                    child: _DateTimeWidget(
                      dateTime: _outputDateTime ?? widget.initialDate,
                    ),
                  )
                ],
              ),
              _DisableOverlay(
                disable: widget.creditAccount == null,
                height: _size.height,
                width: _size.width,
                text: widget.disableText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _Details on _DateTimeSelectorCreditState {
  Widget _dayBuilder(BuildContext context,
      {required DateTime date,
      BoxDecoration? decoration,
      bool? isDisabled,
      bool? isSelected,
      bool? isToday,
      TextStyle? textStyle}) {
    final foregroundColor = isDisabled != null && isDisabled
        ? AppColors.greyBgr(context)
        : isSelected != null && isSelected
            ? context.appTheme.onPrimary
            : context.appTheme.onBackground.withOpacity(_canAddTransaction(date) ? 1 : 0.33);

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
        !_isStatementDate(date) &&
                    !_isDueDate(date) &&
                    !_hasSpendingTransaction(date) &&
                    !_hasPaymentTransaction(date) ||
                isSelected!
            ? Text(
                date.day.toString(),
                style: kHeader3TextStyle.copyWith(
                    color: foregroundColor, height: 0.99, fontSize: kHeader4TextStyle.fontSize),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isStatementDate(date)
                      ? _hasCheckpointTransaction(date)
                          ? icon(AppIcons.statementCheckpoint)
                          : icon(AppIcons.budgets)
                      : Gap.noGap,
                  _isDueDate(date) ? icon(AppIcons.handCoin) : Gap.noGap,
                  _hasSpendingTransaction(date)
                      ? icon(AppIcons.receiptDollar,
                          color: context.appTheme.negative.withOpacity(_canAddTransaction(date) ? 1 : 0.33))
                      : Gap.noGap,
                  _hasPaymentTransaction(date)
                      ? icon(AppIcons.receiptCheck,
                          color: context.appTheme.positive.withOpacity(_canAddTransaction(date) ? 1 : 0.33))
                      : Gap.noGap,
                ],
              ),
      ],
    );
  }

  bool _canAddTransaction(DateTime dateTime) {
    if (widget.creditAccount == null) {
      throw ErrorDescription('Must specify a credit account first');
    }

    return !dateTime.isBefore(_lastCheckpointDateTime) &&
        dateTime.isAfter(_canAddTransactionSinceDateTime) &&
        !dateTime.isAfter(_todayStatementDueDate);
  }

  bool _hasSpendingTransaction(DateTime dateTime) {
    if (widget.creditAccount == null) {
      throw ErrorDescription('Must specify a credit account first');
    }
    final list = widget.creditAccount!.spendingTransactions.map((e) => e.dateTime.onlyYearMonthDay);
    final dateTimeYMD = dateTime.onlyYearMonthDay;
    if (list.contains(dateTimeYMD)) {
      return true;
    }
    return false;
  }

  bool _hasCheckpointTransaction(DateTime dateTime) {
    if (widget.creditAccount == null) {
      throw ErrorDescription('Must specify a credit account first');
    }
    final list = widget.creditAccount!.checkpointTransactions.map((e) => e.dateTime.onlyYearMonthDay);
    final dateTimeYMD = dateTime.onlyYearMonthDay;
    if (list.contains(dateTimeYMD)) {
      return true;
    }
    return false;
  }

  bool _hasPaymentTransaction(DateTime dateTime) {
    if (widget.creditAccount == null) {
      throw ErrorDescription('Must specify a credit account first');
    }
    final list = widget.creditAccount!.paymentTransactions.map((e) => e.dateTime.onlyYearMonthDay);
    final dateTimeYMD = dateTime.onlyYearMonthDay;
    if (list.contains(dateTimeYMD)) {
      return true;
    }
    return false;
  }

  bool _isDueDate(DateTime dateTime) {
    if (widget.creditAccount == null) {
      throw ErrorDescription('Must specify a credit account first');
    }
    final list = widget.creditAccount!.statementsList.map((e) => e.dueDate.onlyYearMonthDay).toList();
    if (widget.creditAccount!.statementsList.isNotEmpty) {
      list.add(widget.creditAccount!.statementsList.first.previousStatement.dueDate);
    }
    final dateTimeYMD = dateTime.onlyYearMonthDay;
    if (list.contains(dateTimeYMD)) {
      return true;
    }
    return false;
  }

  bool _isStatementDate(DateTime dateTime) {
    return dateTime.day == _statementDay;
  }
}
