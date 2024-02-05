part of 'calendar_dialog.dart';

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
  late DateTime _latestCheckpointDateTime = widget.creditAccount!.latestCheckpointDateTime;
  late DateTime _latestStatementDueDate = widget.creditAccount!.latestStatementDueDate;
  late DateTime _todayStatementDueDate = widget.creditAccount!.todayStatementDueDate;
  late Iterable<DateTime> _paymentDateTimes =
      widget.creditAccount!.paymentTransactions.map((e) => e.dateTime.onlyYearMonthDay);
  late Iterable<DateTime> _spendingDateTimes =
      widget.creditAccount!.spendingTransactions.map((e) => e.dateTime.onlyYearMonthDay);
  late Iterable<DateTime> _checkpointDateTimes =
      widget.creditAccount!.checkpointTransactions.map((e) => e.dateTime.onlyYearMonthDay);

  late DateTime? _outputDateTime = widget.initialDate;
  Statement? _outputStatement;

  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  DateTime _currentMonthView = DateTime.now();

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
      _outputDateTime = widget.initialDate;
      _latestCheckpointDateTime = widget.creditAccount!.latestCheckpointDateTime;
      _latestStatementDueDate = widget.creditAccount!.latestStatementDueDate;
      _todayStatementDueDate = widget.creditAccount!.todayStatementDueDate;
      _paymentDateTimes = widget.creditAccount!.paymentTransactions.map((e) => e.dateTime.onlyYearMonthDay);
      _spendingDateTimes = widget.creditAccount!.spendingTransactions.map((e) => e.dateTime.onlyYearMonthDay);
      _checkpointDateTimes = widget.creditAccount!.checkpointTransactions.map((e) => e.dateTime.onlyYearMonthDay);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _submit(DateTime dateTime) {
    _currentMonthView = dateTime;

    _outputDateTime = dateTime.copyWith(hour: _selectedHour, minute: _selectedMinute);
    _outputStatement = widget.creditAccount!.statementAt(_outputDateTime!, upperGapAtDueDate: true);

    widget.onChanged(_outputDateTime!, _outputStatement);
    context.pop();
  }

  Widget _contentBuilder(StateSetter setState, {required DateTime monthView, DateTime? selectedDay}) {
    if (widget.creditAccount!.earliestPayableDate == null) {
      return IconWithText(
        iconPath: AppIcons.done,
        header: 'This credit account currently has no credit/BNPL transaction needed to pay'.hardcoded,
      );
    }

    if (monthView.isBefore(widget.creditAccount!.earliestPayableDate!
        .copyWith(month: widget.creditAccount!.earliestPayableDate!.month - 1))) {
      return IconWithText(
        iconPath: AppIcons.done,
        header: 'No transactions before this time'.hardcoded,
      );
    }

    if (selectedDay != null) {
      return CreditInfo(
        chosenDateTime: selectedDay,
        showPaymentAmount: widget.isForPayment && !selectedDay.isBefore(widget.creditAccount!.earliestPayableDate!),
        statement: widget.creditAccount!.statementAt(selectedDay, upperGapAtDueDate: true),
        onDateTap: (dateTime) => setState(() {
          _currentMonthView = dateTime;
        }),
      );
    }

    return IconWithText(
      iconPath: AppIcons.today,
      header: 'Select a payment day.\n Spending transaction can be paid will be displayed here'.hardcoded,
    );
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
                        await showStatefulDialog(
                          context: context,
                          builder: (context, setState) {
                            return _CustomCalendarDialog(
                              config: _customConfig(context, dayBuilder: _dayBuilder),
                              currentDay: _outputDateTime,
                              currentMonthView: _currentMonthView,
                              onActionButtonTap: (dateTime) {
                                if (dateTime != null && _canSubmit(dateTime)) {
                                  _submit(dateTime);
                                }
                              },
                              contentBuilder: ({required DateTime monthView, DateTime? selectedDay}) {
                                return AnimatedSize(
                                  duration: k150msDuration,
                                  child: _contentBuilder(setState, monthView: monthView, selectedDay: selectedDay),
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
  Widget _dayBuilder(
    BuildContext context, {
    required DateTime date,
    BoxDecoration? decoration,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday,
    TextStyle? textStyle,
  }) {
    final dateTimeYMD = date.onlyYearMonthDay;

    bool isDueDate = date.day == widget.creditAccount!.paymentDueDay;
    bool isStatementDate = date.day == widget.creditAccount!.statementDay;
    bool hasPaymentTransaction = _paymentDateTimes.contains(dateTimeYMD);
    bool hasSpendingTransaction = _spendingDateTimes.contains(dateTimeYMD);
    bool hasCheckpointTransaction = _checkpointDateTimes.contains(dateTimeYMD);

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
        !isStatementDate && !isDueDate && !hasSpendingTransaction && !hasPaymentTransaction || isSelected!
            ? Text(
                date.day.toString(),
                style: kHeader3TextStyle.copyWith(
                    color: foregroundColor, height: 0.99, fontSize: kHeader4TextStyle.fontSize),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isStatementDate
                      ? hasCheckpointTransaction
                          ? icon(AppIcons.statementCheckpoint)
                          : icon(AppIcons.budgets)
                      : Gap.noGap,
                  isDueDate ? icon(AppIcons.handCoin) : Gap.noGap,
                  hasSpendingTransaction
                      ? icon(AppIcons.receiptDollar,
                          color: context.appTheme.negative.withOpacity(_canAddTransaction(date) ? 1 : 0.33))
                      : Gap.noGap,
                  hasPaymentTransaction
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

    if (widget.creditAccount!.statementType == StatementType.payOnlyInGracePeriod && widget.isForPayment) {
      return !dateTime.isBefore(_latestCheckpointDateTime) &&
          dateTime.isAfter(_latestStatementDueDate) &&
          !dateTime.isAfter(_todayStatementDueDate) &&
          widget.creditAccount!.isInGracePeriod(dateTime);
    }

    return !dateTime.isBefore(_latestCheckpointDateTime) &&
        dateTime.isAfter(_latestStatementDueDate) &&
        !dateTime.isAfter(_todayStatementDueDate);
  }

  bool _canSubmit(DateTime dateTime) {
    final beforeLatestCheckpoint = dateTime.isBefore(_latestCheckpointDateTime);
    final notInLatestStatement = !dateTime.isAfter(_latestStatementDueDate);
    final inFuture = dateTime.isAfter(_todayStatementDueDate);
    final canPayOnlyInGracePeriod = widget.creditAccount!.statementType == StatementType.payOnlyInGracePeriod;
    final isPayment = widget.isForPayment;
    final notInGracePeriod = !widget.creditAccount!.isInGracePeriod(dateTime);

    if (beforeLatestCheckpoint) {
      showErrorDialog(
        context,
        'You can only add transaction after [latest checkpoint]'.hardcoded,
      );
      return false;
    }

    if (notInLatestStatement) {
      showErrorDialog(
        context,
        'Oops! You can only add transactions since [the statement contains the latest payment]'.hardcoded,
      );
      return false;
    }

    if (inFuture) {
      showErrorDialog(
        context,
        'Oops! This is future statement!'.hardcoded,
      );
      return false;
    }

    if (isPayment && canPayOnlyInGracePeriod && notInGracePeriod) {
      showErrorDialog(
        context,
        'Oops! Can only pay in grace period (Account preference)'.hardcoded,
      );
      return false;
    }

    return true;
  }
}
