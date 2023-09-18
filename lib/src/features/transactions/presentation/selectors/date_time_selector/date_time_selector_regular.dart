part of 'date_time_selector_components.dart';

class DateTimeSelector extends StatefulWidget {
  const DateTimeSelector({Key? key, required this.onChanged}) : super(key: key);

  final ValueSetter<DateTime> onChanged;

  @override
  State<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  late DateTime currentDateTime = DateTime.now();

  Future<List<DateTime?>?> _showCustomCalendarDatePicker(
      {required BuildContext context,
      int? firstDayOfWeek,
      DateTime? firstDate,
      DateTime? lastDate,
      bool Function(DateTime)? selectableDayPredicate}) {
    return showCalendarDatePicker2Dialog(
      context: context,
      dialogSize: const Size(325, 400),
      dialogBackgroundColor: context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.background,
      borderRadius: BorderRadius.circular(16),
      value: [DateTime.now()],
      config: _customConfig(context,
          firstDate: firstDate,
          lastDate: lastDate,
          firstDayOfWeek: firstDayOfWeek,
          selectableDayPredicate: selectableDayPredicate),
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
          border: Border.all(color: context.appTheme.backgroundNegative.withOpacity(0.4)),
          color: Colors.transparent,
          child: Column(
            children: [
              _CustomTimePickSpinner(
                time: currentDateTime,
                onTimeChange: (newTime) {
                  setState(() {
                    currentDateTime = newTime.copyWith(
                        year: currentDateTime.year, month: currentDateTime.month, day: currentDateTime.day);
                  });
                  widget.onChanged(currentDateTime);
                },
              ),
              CustomInkWell(
                inkColor: AppColors.grey(context),
                onTap: () async {
                  //final results = await _showCustomCalendarDatePicker(context: context);
                  final DateTime? results = await showDialog(
                    useRootNavigator: false,
                    context: context,
                    builder: (_) {
                      return _CustomCalendarDialog(config: _customConfig(context));
                    },
                  );
                  if (results != null) {
                    setState(() {
                      currentDateTime = results.copyWith(hour: currentDateTime.hour, minute: currentDateTime.minute);
                      widget.onChanged(currentDateTime);
                    });
                  }
                },
                child: _DateTimeWidget(
                  dateTime: currentDateTime,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
