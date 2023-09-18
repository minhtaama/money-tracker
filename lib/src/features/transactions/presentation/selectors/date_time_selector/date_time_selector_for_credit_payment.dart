part of 'date_time_selector_components.dart';

class DateTimeSelectorForCreditPayment extends ConsumerStatefulWidget {
  const DateTimeSelectorForCreditPayment(
      {Key? key, this.creditAccount, required this.onChanged, this.selectableDayPredicate, this.disableText})
      : super(key: key);

  final CreditAccount? creditAccount;
  final Function(DateTime?, List<CreditSpending>) onChanged;
  final bool Function(DateTime)? selectableDayPredicate;
  final String? disableText;

  @override
  ConsumerState<DateTimeSelectorForCreditPayment> createState() => _DateTimeSelectorForCreditPaymentState();
}

class _DateTimeSelectorForCreditPaymentState extends ConsumerState<DateTimeSelectorForCreditPayment> {
  DateTime? _outputDateTime;
  List<CreditSpending> _outputSpendingTxnList = List.empty(growable: true);

  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  DateTime _currentMonthView = DateTime.now();

  final _key = GlobalKey();
  Size _size = const Size(0.0, 0.0);

  late final transactionRepo = ref.read(transactionRepositoryProvider);

  late int? _statementDay;
  late int? _paymentDueDay;

  late final _spendingTransactionsDateTimeList = transactionRepo
      .getAll(Calendar.minDate, Calendar.maxDate)
      .whereType<CreditSpending>()
      .map((txn) => txn.dateTime.onlyYearMonthDay)
      .toList();

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
      _statementDay = widget.creditAccount!.creditDetails.statementDay;
      _paymentDueDay = widget.creditAccount!.creditDetails.paymentDueDay;
    }
    super.didUpdateWidget(oldWidget);
  }

  String get _currencyCode {
    final settingsRepo = ref.read(settingsControllerProvider);
    return settingsRepo.currency.code;
  }

  DateTime get _earliestPayableDate {
    if (_paymentDueDay == null || _statementDay == null) {
      throw ErrorDescription('Must specify a credit account first');
    }

    DateTime time = DateTime.now();
    // Get earliest spending transaction un-done
    for (CreditSpending txn in _spendingTransactionsToPay(DateTime.now())) {
      if (!txn.isDone && txn.dateTime.isBefore(time)) {
        time = txn.dateTime;
      }
    }

    // Earliest day that payment can happens
    if (time.day <= _paymentDueDay!) {
      time = time.copyWith(day: _paymentDueDay! + 1);
    }
    if (time.day >= _statementDay!) {
      time = time.copyWith(day: _paymentDueDay! + 1, month: time.month + 1);
    }

    return time;
  }

  DateTime get _earliestMonthViewable {
    return DateTime(_earliestPayableDate.year, _earliestPayableDate.month - 1);
  }

  bool _hasSpendingTransaction(DateTime dateTime) {
    final dateTimeYMD = dateTime.onlyYearMonthDay;
    if (_spendingTransactionsDateTimeList.contains(dateTimeYMD)) {
      return true;
    }
    return false;
  }

  bool _selectableDayPredicate(DateTime date) {
    if (_paymentDueDay == null || _statementDay == null) {
      throw ErrorDescription('Must specify a credit account first');
    }

    if ((date.day >= _statementDay! || date.day <= _paymentDueDay!) && date.isAfter(_earliestPayableDate)) {
      return true;
    } else {
      return false;
    }
  }

  Widget _dayBuilder(
      {required DateTime date,
      BoxDecoration? decoration,
      bool? isDisabled,
      bool? isSelected,
      bool? isToday,
      TextStyle? textStyle}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 33,
        width: 33,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1000),
          border: isToday != null && isToday
              ? Border.all(
                  color: isDisabled != null && isDisabled ? AppColors.greyBgr(context) : context.appTheme.primary,
                )
              : null,
          color: isSelected != null && isSelected
              ? context.appTheme.primary
              : _hasSpendingTransaction(date)
                  ? context.appTheme.negative.withOpacity(isDisabled != null && isDisabled ? 0.7 : 1)
                  : Colors.transparent,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: kHeader4TextStyle.copyWith(
              color: isDisabled != null && isDisabled
                  ? AppColors.greyBgr(context)
                  : isSelected != null && isSelected
                      ? context.appTheme.primaryNegative
                      : _hasSpendingTransaction(date)
                          ? context.appTheme.onNegative
                          : context.appTheme.backgroundNegative,
            ),
          ),
        ),
      ),
    );
  }

  List<CreditSpending> _spendingTransactionsToPay(DateTime selectedDate) {
    if (_paymentDueDay == null || _statementDay == null) {
      throw ErrorDescription('Must specify a credit account first');
    }

    DateTime dayBegin = Calendar.minDate;
    DateTime dayEnd;
    if (selectedDate.day >= _statementDay!) {
      dayEnd = selectedDate.copyWith(day: _statementDay);
    } else if (selectedDate.day <= _paymentDueDay!) {
      dayEnd = selectedDate.copyWith(day: _statementDay, month: selectedDate.month - 1);
    } else {
      dayEnd = selectedDate;
    }

    return transactionRepo.getAll(dayBegin, dayEnd).whereType<CreditSpending>().where((txn) => !txn.isDone).toList();
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
                        widget.onChanged(_outputDateTime, _outputSpendingTxnList);
                      }
                    },
                  ),
                  CustomInkWell(
                    inkColor: AppColors.grey(context),
                    onTap: () async {
                      if (widget.creditAccount != null) {
                        final results = await showDialog(
                          useRootNavigator: false,
                          context: context,
                          builder: (_) {
                            return StatefulBuilder(builder: (_, StateSetter setState) {
                              return _CustomCalendarDialog(
                                config: _customConfig(
                                  context,
                                  firstDate: _earliestMonthViewable,
                                  selectableDayPredicate: _selectableDayPredicate,
                                  dayBuilder: _dayBuilder,
                                ),
                                initialDay: _outputDateTime,
                                currentMonthView: _currentMonthView,
                                onMonthViewChange: (dateTime) {
                                  setState(() {
                                    _currentMonthView = dateTime;
                                  });
                                },
                                onDayChange: (date) {
                                  setState(() {
                                    _outputDateTime = date;
                                  });
                                },
                                onActionButtonTap: () {
                                  if (_outputDateTime != null) {
                                    context.pop(
                                        [_outputDateTime as DateTime, _spendingTransactionsToPay(_outputDateTime!)]);
                                  } else {
                                    context.pop();
                                  }
                                },
                                content: AnimatedSize(
                                  duration: k150msDuration,
                                  child: _currentMonthView.isAtSameMomentAs(_earliestMonthViewable)
                                      ? EmptyInfo(
                                          iconPath: AppIcons.done,
                                          infoText:
                                              'No spending transaction is needed to pay before this time'.hardcoded,
                                        )
                                      : _outputDateTime != null
                                          ? CreditSpendingsInfoList(
                                              transactions: _spendingTransactionsToPay(_outputDateTime!),
                                              currencyCode: _currencyCode,
                                              onDateTap: (dateTime) => setState(() {
                                                _currentMonthView = dateTime;
                                              }),
                                              onTap: (txn) => context.push(RoutePath.transaction, extra: txn),
                                            )
                                          : EmptyInfo(
                                              iconPath: AppIcons.today,
                                              infoText:
                                                  'Select a payment day.\n Spending transaction can be paid will be displayed here'
                                                      .hardcoded,
                                            ),
                                ),
                              );
                            });
                          },
                        );

                        if (results != null) {
                          _outputDateTime =
                              (results[0] as DateTime).copyWith(hour: _selectedHour, minute: _selectedMinute);
                          _outputSpendingTxnList = List.from(results[1]);

                          widget.onChanged(_outputDateTime, _outputSpendingTxnList);
                        }
                      }
                    },
                    child: _DateTimeWidget(
                      dateTime: _outputDateTime,
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
