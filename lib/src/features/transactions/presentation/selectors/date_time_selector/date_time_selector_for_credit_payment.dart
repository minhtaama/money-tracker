part of 'date_time_selector_components.dart';

class DateTimeSelectorForCreditPayment extends ConsumerStatefulWidget {
  const DateTimeSelectorForCreditPayment(
      {super.key, this.creditAccount, this.initialDate, required this.onChanged, this.disableText});

  final CreditAccount? creditAccount;
  final DateTime? initialDate;
  final Function(DateTime, Statement?) onChanged;
  final String? disableText;

  @override
  ConsumerState<DateTimeSelectorForCreditPayment> createState() => _DateTimeSelectorForCreditPaymentState();
}

class _DateTimeSelectorForCreditPaymentState extends ConsumerState<DateTimeSelectorForCreditPayment> {
  late DateTime? _outputDateTime = widget.initialDate;
  Statement? _outputStatement;

  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  DateTime _currentMonthView = DateTime.now();

  late int? _statementDay = widget.creditAccount?.statementDay;
  late int? _paymentDueDay = widget.creditAccount?.paymentDueDay;

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
  void didUpdateWidget(covariant DateTimeSelectorForCreditPayment oldWidget) {
    if (widget.creditAccount != null) {
      _statementDay = widget.creditAccount!.statementDay;
      _paymentDueDay = widget.creditAccount!.paymentDueDay;
      _outputDateTime = widget.initialDate;
    }
    super.didUpdateWidget(oldWidget);
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
              color: context.appTheme.backgroundNegative.withOpacity(widget.creditAccount == null ? 0.1 : 0.4)),
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
                        await _showCustomCalendarDialog(
                          context: context,
                          builder: (context, setState) {
                            return _CustomCalendarDialog(
                              config: _customConfig(
                                context,
                                firstDate: _earliestMonthViewable,
                                selectableDayPredicate: _selectableDayPredicate,
                                dayBuilder: _dayBuilder,
                              ),
                              currentDay: _outputDateTime,
                              currentMonthView: _currentMonthView,
                              onActionButtonTap: (dateTime) {
                                if (dateTime != null) {
                                  _currentMonthView = dateTime;

                                  _outputDateTime = dateTime.copyWith(hour: _selectedHour, minute: _selectedMinute);
                                  _outputStatement = widget.creditAccount!.statementAt(_outputDateTime!);

                                  widget.onChanged(_outputDateTime!, _outputStatement);
                                  context.pop();

                                  // if (widget.creditAccount!.canAddPaymentAt(dateTime)) {
                                  //   _currentMonthView = dateTime;
                                  //
                                  //   _outputDateTime = dateTime.copyWith(hour: _selectedHour, minute: _selectedMinute);
                                  //   _outputStatement = widget.creditAccount!.statementAt(_outputDateTime!);
                                  //
                                  //   widget.onChanged(_outputDateTime!, _outputStatement);
                                  //   context.pop();
                                  // } else {
                                  //   // TODO: Do some styling
                                  //   _showCustomCalendarDialog(
                                  //       context: context,
                                  //       builder: (_, __) {
                                  //         return const AlertDialog(
                                  //           content: EmptyInfo(
                                  //             infoText:
                                  //                 'You can only add payments since the statement contains the latest payment',
                                  //           ),
                                  //         );
                                  //       });
                                  // }
                                }
                              },
                              contentBuilder: ({required DateTime monthView, DateTime? selectedDay}) {
                                if (selectedDay != null) {
                                  // final statement = widget.creditAccount!.statementAt(selectedDay);
                                  // // print(widget.creditAccount!.statementsList);
                                  // print(statement.installments);
                                  // // print(statement.previousStatement.balance);
                                  // print(statement.checkpoint);
                                  // print(statement.getFullPaymentAmountAt(selectedDay));
                                }
                                return AnimatedSize(
                                  duration: k150msDuration,
                                  child: widget.creditAccount!.earliestPayableDate == null
                                      ? EmptyInfo(
                                          iconPath: AppIcons.done,
                                          infoText:
                                              'This credit account currently has no credit/BNPL transaction needed to pay'
                                                  .hardcoded,
                                        )
                                      : monthView.isBefore(widget.creditAccount!.earliestPayableDate!
                                              .copyWith(month: widget.creditAccount!.earliestPayableDate!.month - 1))
                                          ? EmptyInfo(
                                              iconPath: AppIcons.done,
                                              infoText: 'No payment is needed before this time'.hardcoded,
                                            )
                                          : selectedDay != null
                                              ? StatementTransactionsBox(
                                                  chosenDateTime: selectedDay,
                                                  statement: widget.creditAccount!.statementAt(selectedDay),
                                                  onDateTap: (dateTime) => setState(() {
                                                    _currentMonthView = dateTime;
                                                  }),
                                                )
                                              : EmptyInfo(
                                                  iconPath: AppIcons.today,
                                                  infoText:
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

extension _Details on _DateTimeSelectorForCreditPaymentState {
  Widget _dayBuilder(
      {required DateTime date,
      BoxDecoration? decoration,
      bool? isDisabled,
      bool? isSelected,
      bool? isToday,
      TextStyle? textStyle}) {
    final foregroundColor = isDisabled != null && isDisabled
        ? AppColors.greyBgr(context)
        : isSelected != null && isSelected
            ? context.appTheme.primaryNegative
            : context.appTheme.backgroundNegative;

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
                      ? icon(AppIcons.receiptDollar, color: context.appTheme.negative)
                      : Gap.noGap,
                  _hasPaymentTransaction(date)
                      ? icon(AppIcons.receiptCheck, color: context.appTheme.positive)
                      : Gap.noGap,
                ],
              ),
      ],
    );
  }

  DateTime get _earliestMonthViewable {
    if (widget.creditAccount == null) {
      throw ErrorDescription('Must specify a credit account first');
    }

    if (widget.creditAccount!.earliestPayableDate == null) {
      return DateTime(DateTime.now().year, DateTime.now().month);
    }

    return DateTime(
        widget.creditAccount!.earliestPayableDate!.year, widget.creditAccount!.earliestPayableDate!.month - 1);
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
    final list = widget.creditAccount!.statementsList.map((e) => e.dueDate.onlyYearMonthDay);
    final dateTimeYMD = dateTime.onlyYearMonthDay;
    if (list.contains(dateTimeYMD)) {
      return true;
    }
    return false;
  }

  bool _isStatementDate(DateTime dateTime) {
    return dateTime.day == _statementDay;
  }

  bool _selectableDayPredicate(DateTime date) {
    if (widget.creditAccount == null) {
      throw ErrorDescription('Must specify a credit account first');
    }

    if (widget.creditAccount!.earliestPayableDate == null) {
      return false;
    }

    if (date.isAfter(widget.creditAccount!.earliestPayableDate!) ||
        date.isAtSameMomentAs(widget.creditAccount!.earliestPayableDate!)) {
      return true;
    } else {
      return false;
    }
  }
}
