import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/icons.dart';

part 'credit_date_time_selector.dart';

class DateTimeSelector extends StatefulWidget {
  const DateTimeSelector({Key? key, required this.onChanged}) : super(key: key);

  final ValueSetter<DateTime> onChanged;

  @override
  State<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  late DateTime currentDateTime = DateTime.now();

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
                        year: currentDateTime.year,
                        month: currentDateTime.month,
                        day: currentDateTime.day);
                  });
                  widget.onChanged(currentDateTime);
                },
              ),
              CustomInkWell(
                onTap: () async {
                  final results = await showCustomCalendarDatePicker(context: context);
                  if (results != null && results[0] != null) {
                    setState(() {
                      currentDateTime = results[0]!
                          .copyWith(hour: currentDateTime.hour, minute: currentDateTime.minute);
                      widget.onChanged(currentDateTime);
                    });
                  }
                },
                inkColor: AppColors.grey(context),
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

///////////////// COMPONENTS ///////////////////////

class _CustomTimePickSpinner extends StatelessWidget {
  const _CustomTimePickSpinner({this.time, this.onTimeChange});
  final DateTime? time;
  final void Function(DateTime)? onTimeChange;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TimePickerSpinner(
          time: time,
          spacing: 0,
          itemHeight: 26,
          alignment: Alignment.center,
          normalTextStyle: kHeader3TextStyle.copyWith(
              height: 0, color: context.appTheme.backgroundNegative.withOpacity(0.4), fontSize: 15),
          highlightedTextStyle: kHeader1TextStyle.copyWith(
              height: 0.9,
              color:
                  context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary,
              fontSize: 25),
          isForce2Digits: true,
          onTimeChange: onTimeChange,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              ':',
              style: kHeader1TextStyle.copyWith(
                  fontSize: 23,
                  color: context.appTheme.isDarkTheme
                      ? context.appTheme.secondary
                      : context.appTheme.primary),
            ),
          ),
        )
      ],
    );
  }
}

class _DateTimeWidget extends StatelessWidget {
  const _DateTimeWidget({this.dateTime});

  final DateTime? dateTime;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      height: 60,
      width: 75,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      elevation: 0,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color:
                  context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary,
              child: Center(
                child: Text(
                  dateTime != null
                      ? dateTime!.getFormattedDate(type: DateTimeType.ddmmmyyyy, hasYear: false)
                      : '- -   - - -',
                  style: kHeader1TextStyle.copyWith(
                      color: context.appTheme.isDarkTheme
                          ? context.appTheme.secondaryNegative
                          : context.appTheme.primaryNegative,
                      fontSize: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.grey(context),
              child: Center(
                child: Text(
                  dateTime != null ? dateTime!.year.toString() : DateTime.now().year.toString(),
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.isDarkTheme
                        ? context.appTheme.secondary
                        : context.appTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<DateTime?>?> showCustomCalendarDatePicker(
    {required BuildContext context,
    int? firstDayOfWeek,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime)? selectableDayPredicate}) {
  return showCalendarDatePicker2Dialog(
    context: context,
    dialogSize: const Size(325, 400),
    dialogBackgroundColor:
        context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.background,
    borderRadius: BorderRadius.circular(16),
    value: [DateTime.now()],
    config: _customConfig(context,
        firstDate: firstDate,
        lastDate: lastDate,
        firstDayOfWeek: firstDayOfWeek,
        selectableDayPredicate: selectableDayPredicate),
  );
}

CalendarDatePicker2WithActionButtonsConfig _customConfig(BuildContext context,
    {DateTime? firstDate,
    DateTime? lastDate,
    int? firstDayOfWeek,
    bool Function(DateTime)? selectableDayPredicate,
    Widget? Function(
            {BoxDecoration? decoration,
            bool? isCurrentYear,
            bool? isDisabled,
            bool? isSelected,
            TextStyle? textStyle,
            required int year})?
        yearBuilder}) {
  return CalendarDatePicker2WithActionButtonsConfig(
    firstDate: firstDate,
    lastDate: lastDate,
    firstDayOfWeek: firstDayOfWeek,
    selectableDayPredicate: selectableDayPredicate,
    weekdayLabels: [
      'Sun'.hardcoded,
      'Mon'.hardcoded,
      'Tue'.hardcoded,
      'Wed'.hardcoded,
      'Thu'.hardcoded,
      'Fri'.hardcoded,
      'Sat'.hardcoded
    ],
    selectedDayHighlightColor:
        context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary,
    selectedRangeHighlightColor: context.appTheme.isDarkTheme
        ? context.appTheme.secondary.withOpacity(0.5)
        : context.appTheme.primary.withOpacity(0.5),
    controlsTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
    dayTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
    lastMonthIcon: SvgIcon(
      AppIcons.arrowLeft,
      color: context.appTheme.backgroundNegative,
    ),
    nextMonthIcon: SvgIcon(
      AppIcons.arrowRight,
      color: context.appTheme.backgroundNegative,
    ),
    weekdayLabelTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
    selectedDayTextStyle: kHeader4TextStyle.copyWith(
        color: context.appTheme.isDarkTheme
            ? context.appTheme.secondaryNegative
            : context.appTheme.primaryNegative),
    selectedYearTextStyle: kHeader4TextStyle.copyWith(
        color: context.appTheme.isDarkTheme
            ? context.appTheme.secondaryNegative
            : context.appTheme.primaryNegative),
    yearTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
    yearBuilder: yearBuilder,
    cancelButtonTextStyle: kHeader2TextStyle.copyWith(
        fontSize: 15,
        color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary),
    okButtonTextStyle: kHeader2TextStyle.copyWith(
        fontSize: 15,
        color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary),
  );
}
