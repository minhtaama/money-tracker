part of 'date_time_selector.dart';

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
  late DateTime _latestStatementDueDate = widget.creditAccount!.latestClosedStatementDueDate;
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
      _latestStatementDueDate = widget.creditAccount!.latestClosedStatementDueDate;
      _todayStatementDueDate = widget.creditAccount!.todayStatementDueDate;
      _paymentDateTimes =
          widget.creditAccount!.paymentTransactions.map((e) => e.dateTime.onlyYearMonthDay);
      _spendingDateTimes =
          widget.creditAccount!.spendingTransactions.map((e) => e.dateTime.onlyYearMonthDay);
      _checkpointDateTimes =
          widget.creditAccount!.checkpointTransactions.map((e) => e.dateTime.onlyYearMonthDay);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _submitDay(DateTime dateTime) {
    _currentMonthView = dateTime;

    _outputDateTime = dateTime.copyWith(hour: _selectedHour, minute: _selectedMinute);
    _outputStatement = widget.creditAccount!.statementAt(_outputDateTime!, upperGapAtDueDate: true);

    widget.onChanged(_outputDateTime!, _outputStatement);
    context.pop();
  }

  void _updateTime(DateTime dateTime) {
    _selectedHour = dateTime.hour;
    _selectedMinute = dateTime.minute;

    if (_outputDateTime != null) {
      setState(() {
        _outputDateTime = _outputDateTime!.copyWith(hour: _selectedHour, minute: _selectedMinute);
      });
      widget.onChanged(_outputDateTime!, _outputStatement);
    }
  }

  Widget _contentBuilder(StateSetter setState, DateTime monthView, DateTime? selectedDay) {
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
        showPaymentAmount:
            widget.isForPayment && !selectedDay.isBefore(widget.creditAccount!.earliestPayableDate!),
        statement: widget.creditAccount!.statementAt(selectedDay, upperGapAtDueDate: true),
        onDateTap: (dateTime) => setState(() {
          _currentMonthView = dateTime;
        }),
      );
    }

    return IconWithText(
      iconPath: AppIcons.today,
      header:
          'Select a payment day.\n Spending transaction can be paid will be displayed here'.hardcoded,
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
          border: Border.all(
              color:
                  context.appTheme.onBackground.withOpacity(widget.creditAccount == null ? 0.1 : 0.4)),
          color: Colors.transparent,
          child: Stack(
            children: [
              Column(
                key: _key,
                children: [
                  _CustomTimePickSpinner(
                    onTimeChange: _updateTime,
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
                                if (dateTime != null && _canSubmit(dateTime, showDialog: true)) {
                                  _submitDay(dateTime);
                                }
                              },
                              contentBuilder: ({required DateTime monthView, DateTime? selectedDay}) {
                                return AnimatedSize(
                                  duration: k150msDuration,
                                  child: _contentBuilder(setState, monthView, selectedDay),
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

class DateSelectorForCheckpoint extends StatefulWidget {
  const DateSelectorForCheckpoint(
      {super.key,
      required this.onChanged,
      required this.labelBuilder,
      this.initial,
      this.selectableDayPredicate});

  final DateTime? initial;
  final bool Function(DateTime)? selectableDayPredicate;
  final ValueSetter<DateTime> onChanged;
  final String Function(DateTime?) labelBuilder;

  @override
  State<DateSelectorForCheckpoint> createState() => _DateSelectorForCheckpointState();
}

class _DateSelectorForCheckpointState extends State<DateSelectorForCheckpoint> {
  late DateTime _outputDateTime = widget.initial ?? DateTime.now();
  //late DateTime _selectedDay = DateTime.now();

  @override
  void didUpdateWidget(covariant DateSelectorForCheckpoint oldWidget) {
    if (widget.initial != null) {
      _outputDateTime = widget.initial!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: CustomInkWell(
        borderRadius: BorderRadius.circular(1000),
        inkColor: AppColors.grey(context),
        onTap: () async {
          await showStatefulDialog(
            context: context,
            builder: (_, __) {
              return _CustomCalendarDialog(
                config: _customConfig(
                  context,
                  dayBuilder: _dayBuilderRegular,
                  selectableDayPredicate: widget.selectableDayPredicate,
                ),
                currentDay: _outputDateTime,
                onActionButtonTap: (dateTime) {
                  if (dateTime != null) {
                    setState(() {
                      _outputDateTime =
                          dateTime.copyWith(hour: _outputDateTime.hour, minute: _outputDateTime.minute);
                    });
                    context.pop();
                  }
                },
              );
            },
          );
          widget.onChanged(_outputDateTime);
        },
        child: _DateWidget(
          dateTime: _outputDateTime,
          labelBuilder: widget.labelBuilder,
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

    return _DayBuilder.forCredit(
      context,
      date,
      isDisabled,
      isSelected,
      isToday,
      canAddTransaction: _canSubmit(date),
      hasPayment: _paymentDateTimes.contains(dateTimeYMD),
      hasSpending: _spendingDateTimes.contains(dateTimeYMD),
      hasCheckpoint: _checkpointDateTimes.contains(dateTimeYMD),
      isStatementDay: date.day == widget.creditAccount!.statementDay,
      isDueDay: date.day == widget.creditAccount!.paymentDueDay,
    );
  }

  bool _canSubmit(DateTime dateTime, {bool showDialog = false}) {
    final beforeLatestCheckpoint = dateTime.isBefore(_latestCheckpointDateTime);
    final notInLatestStatement = !dateTime.isAfter(_latestStatementDueDate);
    final inFuture = dateTime.isAfter(_todayStatementDueDate);
    final canPayOnlyInGracePeriod =
        widget.creditAccount!.statementType == StatementType.payOnlyInGracePeriod;
    final isPayment = widget.isForPayment;
    final notInGracePeriod = !widget.creditAccount!.isInGracePeriod(dateTime);

    if (beforeLatestCheckpoint) {
      showErrorDialog(
        context,
        'You can only add transaction after [latest checkpoint]'.hardcoded,
        enable: showDialog,
      );
      return false;
    }

    if (notInLatestStatement) {
      showErrorDialog(
        context,
        'Oops! You can only add transactions since [the statement contains the latest payment]'
            .hardcoded,
        enable: showDialog,
      );
      return false;
    }

    if (inFuture) {
      showErrorDialog(
        context,
        'Oops! This is future statement!'.hardcoded,
        enable: showDialog,
      );
      return false;
    }

    if (isPayment && canPayOnlyInGracePeriod && notInGracePeriod) {
      showErrorDialog(
        context,
        'Oops! Can only pay in grace period (Account preference)'.hardcoded,
        enable: showDialog,
      );
      return false;
    }

    return true;
  }
}
