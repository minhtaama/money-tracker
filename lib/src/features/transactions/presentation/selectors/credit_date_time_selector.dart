part of 'date_time_selector.dart';

class CreditDateTimeSelector extends StatefulWidget {
  const CreditDateTimeSelector(
      {Key? key,
      this.creditAccount,
      required this.onChanged,
      this.selectableDayPredicate,
      this.disableText})
      : super(key: key);

  final CreditAccount? creditAccount;
  final ValueSetter<DateTime?> onChanged;
  final bool Function(DateTime)? selectableDayPredicate;
  final String? disableText;

  @override
  State<CreditDateTimeSelector> createState() => _CreditDateTimeSelectorState();
}

class _CreditDateTimeSelectorState extends State<CreditDateTimeSelector> {
  DateTime? currentDateTime;

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
              color: context.appTheme.backgroundNegative
                  .withOpacity(widget.creditAccount == null ? 0.1 : 0.4)),
          color: Colors.transparent,
          child: Stack(
            children: [
              Column(
                key: _key,
                children: [
                  _CustomTimePickSpinner(
                    time: currentDateTime,
                    onTimeChange: (newTime) {
                      if (currentDateTime != null) {
                        setState(() {
                          currentDateTime = newTime.copyWith(
                              year: currentDateTime!.year,
                              month: currentDateTime!.month,
                              day: currentDateTime!.day);
                        });
                        widget.onChanged(currentDateTime);
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
                            return _CreditCalendarDialog(creditAccount: widget.creditAccount!);
                          },
                        );
                      }
                    },
                    child: _DateTimeWidget(
                      dateTime: currentDateTime,
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

class _CreditCalendarDialog extends StatefulWidget {
  const _CreditCalendarDialog({required this.creditAccount});

  final CreditAccount creditAccount;

  @override
  State<_CreditCalendarDialog> createState() => _CreditCalendarDialogState();
}

class _CreditCalendarDialogState extends State<_CreditCalendarDialog> {
  bool _selectableDayPredicate(DateTime date) {
    if (date.day >= widget.creditAccount.creditDetails!.statementDay ||
        date.day <= widget.creditAccount.creditDetails!.paymentDueDay) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: context.appTheme.background,
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          children: [
            Placeholder(),
            //TODO: Implement the logic get payment period and spending credit transaction to pay in that period
            SizedBox(
              height: 300,
              width: 350,
              child: CalendarDatePicker2(
                config: _customConfig(context, selectableDayPredicate: _selectableDayPredicate),
                value: const [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisableOverlay extends StatelessWidget {
  const _DisableOverlay({required this.disable, required this.height, required this.width, this.text});
  final bool disable;
  final double height;
  final double width;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !disable,
      child: AnimatedOpacity(
        duration: k150msDuration,
        opacity: disable ? 1 : 0,
        child: Container(
          height: height,
          width: width,
          padding: const EdgeInsets.all(8),
          color: context.appTheme.isDarkTheme
              ? context.appTheme.background3.withOpacity(0.95)
              : context.appTheme.background.withOpacity(0.95),
          child: Center(
              child: Text(
            text ?? '',
            textAlign: TextAlign.center,
            style: kHeader2TextStyle.copyWith(color: AppColors.darkestGrey(context), fontSize: 12),
          )),
        ),
      ),
    );
  }
}
