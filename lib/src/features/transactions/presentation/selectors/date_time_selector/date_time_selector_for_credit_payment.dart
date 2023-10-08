part of 'date_time_selector_components.dart';

class DateTimeSelectorForCreditPayment extends ConsumerStatefulWidget {
  const DateTimeSelectorForCreditPayment(
      {Key? key, this.creditAccount, this.initialDate, required this.onChanged, this.disableText})
      : super(key: key);

  final CreditAccount? creditAccount;
  final DateTime? initialDate;
  final Function(DateTime, List<CreditSpending>) onChanged;
  final String? disableText;

  @override
  ConsumerState<DateTimeSelectorForCreditPayment> createState() => _DateTimeSelectorForCreditPaymentState();
}

class _DateTimeSelectorForCreditPaymentState extends ConsumerState<DateTimeSelectorForCreditPayment> {
  late DateTime? _outputDateTime = widget.initialDate;
  List<CreditSpending> _outputSpendingTxnList = List.empty(growable: true);

  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;

  DateTime _currentMonthView = DateTime.now();

  late int? _statementDay;
  late int? _paymentDueDay;

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
                        widget.onChanged(_outputDateTime!, _outputSpendingTxnList);
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
                                  _outputSpendingTxnList =
                                      widget.creditAccount!.spendingTxnsInThisStatementBefore(_outputDateTime!);

                                  widget.onChanged(_outputDateTime!, _outputSpendingTxnList);
                                }
                              },
                              contentBuilder: ({required DateTime monthView, DateTime? selectedDay}) => AnimatedSize(
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
                                            ? CreditSpendingsList(
                                                title: 'Transactions require payment:'.hardcoded,
                                                transactions: widget.creditAccount!
                                                    .spendingTxnsInThisStatementBefore(selectedDay),
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
                              ),
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
              : _hasUnpaidSpendingTransaction(date)
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
                      : _hasUnpaidSpendingTransaction(date)
                          ? context.appTheme.onNegative
                          : context.appTheme.backgroundNegative,
            ),
          ),
        ),
      ),
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

  bool _hasUnpaidSpendingTransaction(DateTime dateTime) {
    if (widget.creditAccount == null) {
      throw ErrorDescription('Must specify a credit account first');
    }
    final list = widget.creditAccount!.spendingTransactionsList.map((e) => e.dateTime.onlyYearMonthDay);
    final dateTimeYMD = dateTime.onlyYearMonthDay;
    if (list.contains(dateTimeYMD)) {
      return true;
    }
    return false;
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
