part of 'date_time_selector.dart';

class DateTimeSelector extends StatefulWidget {
  const DateTimeSelector({super.key, required this.onChanged});

  final ValueSetter<DateTime> onChanged;

  @override
  State<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  late DateTime _outputDateTime = DateTime.now();
  //late DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: CardItem(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          elevation: 0,
          border: Border.all(color: context.appTheme.onBackground.withOpacity(0.4)),
          color: Colors.transparent,
          child: Column(
            children: [
              _CustomTimePickSpinner(
                time: _outputDateTime,
                onTimeChange: (newTime) {
                  setState(() {
                    _outputDateTime = newTime.copyWith(
                        year: _outputDateTime.year, month: _outputDateTime.month, day: _outputDateTime.day);
                  });
                  widget.onChanged(_outputDateTime);
                },
              ),
              CustomInkWell(
                inkColor: AppColors.grey(context),
                onTap: () async {
                  await showStatefulDialog(
                    context: context,
                    builder: (_, __) {
                      return _CustomCalendarDialog(
                        config: _customConfig(context, dayBuilder: _dayBuilderRegular),
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
                child: _DateTimeWidget(
                  dateTime: _outputDateTime,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DateSelector extends StatefulWidget {
  const DateSelector(
      {super.key, required this.onChanged, required this.labelBuilder, this.initial, this.selectableDayPredicate});

  final DateTime? initial;
  final bool Function(DateTime)? selectableDayPredicate;
  final ValueSetter<DateTime> onChanged;
  final String Function(DateTime?) labelBuilder;

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime _outputDateTime = widget.initial ?? DateTime.now();
  //late DateTime _selectedDay = DateTime.now();

  @override
  void didUpdateWidget(covariant DateSelector oldWidget) {
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
                      _outputDateTime = dateTime.copyWith(hour: _outputDateTime.hour, minute: _outputDateTime.minute);
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

Widget _dayBuilderRegular(BuildContext context,
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
        color: isSelected != null && isSelected ? context.appTheme.primary : Colors.transparent,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: kNormalTextStyle.copyWith(
            color: isDisabled != null && isDisabled
                ? AppColors.greyBgr(context)
                : isSelected != null && isSelected
                    ? context.appTheme.onPrimary
                    : context.appTheme.onBackground,
          ),
        ),
      ),
    ),
  );
}
