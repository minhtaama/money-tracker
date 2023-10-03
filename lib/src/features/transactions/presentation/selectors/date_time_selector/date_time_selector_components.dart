import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/empty_info.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/credit_spendings_list.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../../../common_widgets/svg_icon.dart';
import '../../../../../theme_and_ui/icons.dart';
import '../../../domain/transaction_base.dart';

part 'date_time_selector_for_credit_payment.dart';
part 'date_time_selector_regular.dart';

////////////////////// COMPONENTS //////////////////////

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
          highlightedTextStyle: kHeader1TextStyle.copyWith(height: 0.9, color: context.appTheme.primary, fontSize: 25),
          isForce2Digits: true,
          onTimeChange: onTimeChange,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              ':',
              style: kHeader1TextStyle.copyWith(fontSize: 23, color: context.appTheme.primary),
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
              color: context.appTheme.primary,
              child: Center(
                child: Text(
                  dateTime != null
                      ? dateTime!.getFormattedDate(type: DateTimeType.ddmmmyyyy, hasYear: false)
                      : '- -   - - -',
                  style: kHeader1TextStyle.copyWith(color: context.appTheme.primaryNegative, fontSize: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.greyBgr(context),
              child: Center(
                child: Text(
                  dateTime != null ? dateTime!.year.toString() : DateTime.now().year.toString(),
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.primary,
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
            style: kHeader2TextStyle.copyWith(color: AppColors.grey(context), fontSize: 12),
          )),
        ),
      ),
    );
  }
}

class _CustomCalendarDialog extends StatefulWidget {
  const _CustomCalendarDialog(
      {required this.config,
      this.currentDay,
      this.currentMonthView,
      required this.onActionButtonTap,
      this.contentBuilder});

  final CalendarDatePicker2Config config;
  final DateTime? currentDay;
  final DateTime? currentMonthView;
  final ValueSetter<DateTime?>? onActionButtonTap;
  final Widget? Function({required DateTime monthView, DateTime? selectedDay})? contentBuilder;

  @override
  State<_CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<_CustomCalendarDialog> {
  late DateTime _currentMonthView = widget.currentMonthView ?? DateTime.now();
  late DateTime? _selectedDay = widget.currentDay;

  @override
  void didUpdateWidget(covariant _CustomCalendarDialog oldWidget) {
    if (widget.currentMonthView != null) {
      _currentMonthView = widget.currentMonthView!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.background,
      contentPadding: EdgeInsets.zero,
      actions: [
        IconWithTextButton(
          iconPath: _selectedDay != null ? AppIcons.done : AppIcons.back,
          label: _selectedDay != null ? 'Select'.hardcoded : 'Back'.hardcoded,
          height: 30,
          width: 100,
          labelSize: 13,
          iconSize: 20,
          isDisabled: _selectedDay == null,
          backgroundColor: context.appTheme.primary,
          color: context.appTheme.primaryNegative,
          onTap: () {
            widget.onActionButtonTap?.call(_selectedDay);
            context.pop();
          },
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              child: widget.contentBuilder?.call(monthView: _currentMonthView, selectedDay: _selectedDay),
            ),
            widget.contentBuilder != null ? Gap.divider(context, indent: 20) : Gap.noGap,
            SizedBox(
              height: 300,
              width: 350,
              child: CalendarDatePicker2(
                config: widget.config,
                value: [_selectedDay],
                displayedMonthDate: _currentMonthView,
                onDisplayedMonthChanged: (dateTime) {
                  setState(() {
                    _currentMonthView = dateTime;
                  });
                },
                onValueChanged: (dateList) {
                  setState(() {
                    _selectedDay = dateList[0];
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> _showCustomCalendarDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext, StateSetter) builder,
}) {
  return showDialog<T>(
      useRootNavigator: false,
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: builder);
      });
}

////////////////////// CONFIG //////////////////////

CalendarDatePicker2WithActionButtonsConfig _customConfig(
  BuildContext context, {
  DateTime? firstDate,
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
      yearBuilder,
  Widget? Function(
          {required DateTime date,
          BoxDecoration? decoration,
          bool? isDisabled,
          bool? isSelected,
          bool? isToday,
          TextStyle? textStyle})?
      dayBuilder,
}) {
  return CalendarDatePicker2WithActionButtonsConfig(
    calendarType: CalendarDatePicker2Type.single,
    firstDate: firstDate,
    lastDate: lastDate,
    firstDayOfWeek: firstDayOfWeek,
    selectableDayPredicate: selectableDayPredicate,
    selectedDayHighlightColor: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary,
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
        color: context.appTheme.isDarkTheme ? context.appTheme.secondaryNegative : context.appTheme.primaryNegative),
    selectedYearTextStyle: kHeader4TextStyle.copyWith(
        color: context.appTheme.isDarkTheme ? context.appTheme.secondaryNegative : context.appTheme.primaryNegative),
    yearTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
    cancelButtonTextStyle: kHeader2TextStyle.copyWith(
        fontSize: 15, color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary),
    okButtonTextStyle: kHeader2TextStyle.copyWith(
        fontSize: 15, color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary),
    yearBuilder: yearBuilder,
    dayBuilder: dayBuilder,
  );
}