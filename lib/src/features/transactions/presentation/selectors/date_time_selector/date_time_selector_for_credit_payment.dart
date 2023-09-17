part of 'date_time_selector.dart';

class DateTimeSelectorForCreditPayment extends StatefulWidget {
  const DateTimeSelectorForCreditPayment(
      {Key? key, this.creditAccount, required this.onChanged, this.selectableDayPredicate, this.disableText})
      : super(key: key);

  final CreditAccount? creditAccount;
  final Function(DateTime?, List<CreditSpending>) onChanged;
  final bool Function(DateTime)? selectableDayPredicate;
  final String? disableText;

  @override
  State<DateTimeSelectorForCreditPayment> createState() => _DateTimeSelectorForCreditPaymentState();
}

class _DateTimeSelectorForCreditPaymentState extends State<DateTimeSelectorForCreditPayment> {
  DateTime? _currentDateTime;
  List<CreditSpending> _spendingTxnList = List.empty(growable: true);

  int _hour = DateTime.now().hour;
  int _minute = DateTime.now().minute;

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
                      _hour = newTime.hour;
                      _minute = newTime.minute;

                      if (_currentDateTime != null) {
                        setState(() {
                          _currentDateTime = _currentDateTime!.copyWith(hour: _hour, minute: _minute);
                        });
                        widget.onChanged(_currentDateTime, _spendingTxnList);
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
                            return _CreditCalendarDialog(
                              creditAccount: widget.creditAccount!,
                            );
                          },
                        );
                        if (results != null) {
                          _currentDateTime = (results[0] as DateTime).copyWith(hour: _hour, minute: _minute);
                          _spendingTxnList = List.from(results[1]);

                          widget.onChanged(_currentDateTime, _spendingTxnList);
                        }
                      }
                    },
                    child: _DateTimeWidget(
                      dateTime: _currentDateTime,
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
