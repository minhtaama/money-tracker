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
  const DateSelector({
    super.key,
    this.onChanged,
    this.onChangedNullable,
    required this.labelBuilder,
    this.initial,
    this.selectableDayPredicate,
  }) : assert(onChanged != null && onChangedNullable == null || onChanged == null && onChangedNullable != null);

  final DateTime? initial;
  final bool Function(DateTime)? selectableDayPredicate;
  final ValueSetter<DateTime>? onChanged;
  final ValueSetter<DateTime?>? onChangedNullable;
  final String Function(DateTime?) labelBuilder;

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime? _outputDateTime = widget.onChangedNullable != null ? widget.initial : widget.initial ?? DateTime.now();
  //late DateTime _selectedDay = DateTime.now();

  @override
  void didUpdateWidget(covariant DateSelector oldWidget) {
    if (widget.onChangedNullable != null) {
      _outputDateTime = widget.initial;
    } else if (widget.initial != null && widget.onChanged != null) {
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
                showReturnNullButton: widget.onChangedNullable != null,
                onActionButtonTap: (dateTime) {
                  // if (dateTime == null && widget.onChangedNullable != null) {
                  //   setState(() {
                  //     _outputDateTime = null;
                  //   });
                  //   context.pop();
                  // }
                  //
                  // else if (dateTime != null) {
                  //   setState(() {
                  //     _outputDateTime = dateTime.onlyYearMonthDay;
                  //   });
                  //   context.pop();
                  // }

                  setState(() {
                    _outputDateTime = dateTime?.onlyYearMonthDay;
                  });

                  context.pop();
                },
              );
            },
          );

          if (_outputDateTime != null) {
            widget.onChanged?.call(_outputDateTime!);
          }

          widget.onChangedNullable?.call(_outputDateTime);
        },
        child: _DateWidget(
          dateTime: _outputDateTime,
          labelBuilder: widget.labelBuilder,
        ),
      ),
    );
  }
}

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({
    super.key,
    required this.onValueChanged,
    this.displayedMonthDate,
    required this.value,
    this.selectableDayPredicate,
    this.constraintWidth = true,
    this.calendarType = CalendarDatePicker2Type.multi,
  });

  final void Function(List<DateTime?>) onValueChanged;
  final List<DateTime> value;
  final DateTime? displayedMonthDate;
  final bool constraintWidth;
  final bool Function(DateTime)? selectableDayPredicate;
  final CalendarDatePicker2Type calendarType;

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  List<DateTime?> _selected = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      width: widget.constraintWidth ? (context.isBigScreen ? 300 : 350) : null,
      child: CalendarDatePicker2(
        config: _customConfig(
          context,
          calendarType: widget.calendarType,
          dayBuilder: _dayBuilderRegular,
          selectableDayPredicate: widget.selectableDayPredicate,
        ),
        value: widget.value,
        displayedMonthDate: widget.displayedMonthDate,
        onValueChanged: (dateList) {
          setState(() {
            _selected = dateList;
          });

          widget.onValueChanged(_selected);
        },
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
    child: CardItem(
      height: 33,
      width: 33,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(1000),
      border: isToday != null && isToday
          ? Border.all(
              color: isDisabled != null && isDisabled ? AppColors.greyBgr(context) : context.appTheme.primary,
            )
          : null,
      color: context.appTheme.primary.withOpacity(isSelected != null && isSelected ? 1 : 0),
      child: Center(
        child: Text(
          date.day.toString(),
          style: kHeader2TextStyle.copyWith(
            color: isDisabled != null && isDisabled
                ? AppColors.greyBgr(context)
                : isSelected != null && isSelected
                    ? context.appTheme.onPrimary
                    : context.appTheme.onBackground,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}
