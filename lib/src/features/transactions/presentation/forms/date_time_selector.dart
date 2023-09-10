import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

class DateTimeSelector extends StatefulWidget {
  const DateTimeSelector({Key? key, required this.onChanged}) : super(key: key);

  final ValueSetter<DateTime> onChanged;
  @override
  State<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  DateTime currentDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      elevation: 0,
      border: Border.all(color: context.appTheme.backgroundNegative.withOpacity(0.4)),
      color: Colors.transparent,
      child: Column(
        children: [
          Stack(
            children: [
              TimePickerSpinner(
                time: currentDateTime,
                spacing: 0,
                itemHeight: 26,
                alignment: Alignment.center,
                normalTextStyle: kHeader3TextStyle.copyWith(
                    height: 0,
                    color: context.appTheme.backgroundNegative.withOpacity(0.4),
                    fontSize: 15),
                highlightedTextStyle: kHeader1TextStyle.copyWith(
                    height: 0.9,
                    color: context.appTheme.isDarkTheme
                        ? context.appTheme.secondary
                        : context.appTheme.primary,
                    fontSize: 25),
                isForce2Digits: true,
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
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    ':',
                    style: kHeader1TextStyle.copyWith(fontSize: 23, color: context.appTheme.secondary),
                  ),
                ),
              )
            ],
          ),
          CustomInkWell(
            onTap: () async {
              final results = await showCalendarDatePicker2Dialog(
                context: context,
                dialogSize: const Size(325, 400),
                dialogBackgroundColor: context.appTheme.isDarkTheme
                    ? context.appTheme.background3
                    : context.appTheme.background,
                borderRadius: BorderRadius.circular(16),
                value: [DateTime.now()],
                config: CalendarDatePicker2WithActionButtonsConfig(
                  firstDayOfWeek: 1,
                  selectedDayHighlightColor: context.appTheme.primary,
                  selectedRangeHighlightColor: context.appTheme.primary.withOpacity(0.5),
                  controlsTextStyle:
                      kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                  dayTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                  lastMonthIcon: SvgIcon(
                    AppIcons.arrowLeft,
                    color: context.appTheme.backgroundNegative,
                  ),
                  nextMonthIcon: SvgIcon(
                    AppIcons.arrowRight,
                    color: context.appTheme.backgroundNegative,
                  ),
                  weekdayLabelTextStyle:
                      kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                  selectedDayTextStyle:
                      kHeader4TextStyle.copyWith(color: context.appTheme.primaryNegative),
                  selectedYearTextStyle:
                      kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                  yearTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                ),
              );
              // TODO: Extract dateTime picker function to a seperate one
              if (results != null && results[0] != null) {
                setState(() {
                  currentDateTime =
                      results[0]!.copyWith(hour: currentDateTime.hour, minute: currentDateTime.minute);
                  widget.onChanged(currentDateTime);
                });
              }
            },
            inkColor: AppColors.grey(context),
            child: CardItem(
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
                      color: context.appTheme.isDarkTheme
                          ? context.appTheme.secondary
                          : context.appTheme.primary,
                      child: Center(
                        child: Text(
                          currentDateTime.getFormattedDate(type: DateTimeType.ddmmmyyyy, hasYear: false),
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
                          currentDateTime.year.toString(),
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
            ),
          )
        ],
      ),
    );
  }
}
