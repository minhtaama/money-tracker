part of 'date_time_selector.dart';

class CreditDateTimeSelector extends StatefulWidget {
  const CreditDateTimeSelector(
      {Key? key, required this.onChanged, this.selectableDayPredicate, this.disable = false, this.disableText})
      : super(key: key);

  final ValueSetter<DateTime?> onChanged;
  final bool Function(DateTime)? selectableDayPredicate;
  final bool disable;
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
          border: Border.all(color: context.appTheme.backgroundNegative.withOpacity(widget.disable ? 0.1 : 0.4)),
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
                              year: currentDateTime!.year, month: currentDateTime!.month, day: currentDateTime!.day);
                        });
                        widget.onChanged(currentDateTime);
                      }
                    },
                  ),
                  CustomInkWell(
                    // onTap: () async {
                    //   final results = await showCustomCalendarDatePicker(
                    //       context: context, selectableDayPredicate: widget.selectableDayPredicate);
                    //   if (results != null && results[0] != null) {
                    //     setState(() {
                    //       currentDateTime =
                    //           results[0]!.copyWith(hour: currentDateTime.hour, minute: currentDateTime.minute);
                    //       widget.onChanged(currentDateTime);
                    //     });
                    //   }
                    // },
                    onTap: () async {
                      final results = await showDialog(
                          context: context,
                          builder: (_) {
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
                                        config: _customConfig(context,
                                            selectableDayPredicate: widget.selectableDayPredicate),
                                        value: const [],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    inkColor: AppColors.grey(context),
                    child: _DateTimeWidget(
                      dateTime: currentDateTime,
                    ),
                  )
                ],
              ),
              _DisableOverlay(
                disable: widget.disable,
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
