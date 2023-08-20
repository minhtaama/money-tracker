import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
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
                    height: 0, color: context.appTheme.backgroundNegative.withOpacity(0.4), fontSize: 15),
                highlightedTextStyle: kHeader1TextStyle.copyWith(
                    height: 0.9,
                    color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary,
                    fontSize: 25),
                isForce2Digits: true,
                onTimeChange: (newTime) {
                  setState(() {
                    currentDateTime = newTime.copyWith(
                        year: currentDateTime.year, month: currentDateTime.month, day: currentDateTime.day);
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
              final newDate = await showDatePicker(
                context: context,
                initialDate: currentDateTime,
                firstDate: Calendar.minDate,
                lastDate: Calendar.maxDate,
              );
              if (newDate != null) {
                setState(() {
                  currentDateTime = newDate.copyWith(hour: currentDateTime.hour, minute: currentDateTime.minute);
                  widget.onChanged(currentDateTime);
                });
              }
            },
            inkColor: AppColors.grey,
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
                      color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary,
                      child: Center(
                        child: Text(
                          '${currentDateTime.day} ${currentDateTime.monthStringShort()}',
                          style: kHeader4TextStyle.copyWith(
                              color: context.appTheme.isDarkTheme
                                  ? context.appTheme.secondaryNegative
                                  : context.appTheme.primaryNegative,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: AppColors.grey,
                      child: Center(
                        child: Text(
                          currentDateTime.year.toString(),
                          style: kHeader2TextStyle.copyWith(
                            color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary,
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
