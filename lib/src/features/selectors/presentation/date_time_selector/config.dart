part of 'calendar_dialog.dart';

CalendarDatePicker2WithActionButtonsConfig _customConfig(
  BuildContext context, {
  DateTime? firstDate,
  DateTime? lastDate,
  int? firstDayOfWeek,
  double? controlsHeight,
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
    BuildContext context, {
    required DateTime date,
    BoxDecoration? decoration,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday,
    TextStyle? textStyle,
  })? dayBuilder,
}) {
  return CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.single,
      firstDate: firstDate,
      lastDate: lastDate,
      firstDayOfWeek: firstDayOfWeek,
      selectableDayPredicate: selectableDayPredicate,
      selectedDayHighlightColor: context.appTheme.isDarkTheme ? context.appTheme.secondary1 : context.appTheme.primary,
      selectedRangeHighlightColor: context.appTheme.isDarkTheme
          ? context.appTheme.secondary1.withOpacity(0.5)
          : context.appTheme.primary.withOpacity(0.5),
      controlsTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
      dayTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
      lastMonthIcon: SvgIcon(
        AppIcons.arrowLeft,
        color: context.appTheme.onBackground,
      ),
      nextMonthIcon: SvgIcon(
        AppIcons.arrowRight,
        color: context.appTheme.onBackground,
      ),
      weekdayLabelTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
      selectedDayTextStyle: kHeader4TextStyle.copyWith(
          color: context.appTheme.isDarkTheme ? context.appTheme.onSecondary : context.appTheme.onPrimary),
      selectedYearTextStyle: kHeader4TextStyle.copyWith(
          color: context.appTheme.isDarkTheme ? context.appTheme.onSecondary : context.appTheme.onPrimary),
      yearTextStyle: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
      cancelButtonTextStyle: kHeader2TextStyle.copyWith(
          fontSize: 15, color: context.appTheme.isDarkTheme ? context.appTheme.secondary1 : context.appTheme.primary),
      okButtonTextStyle: kHeader2TextStyle.copyWith(
          fontSize: 15, color: context.appTheme.isDarkTheme ? context.appTheme.secondary1 : context.appTheme.primary),
      yearBuilder: yearBuilder,
      dayBuilder: (
              {required DateTime date,
              BoxDecoration? decoration,
              bool? isDisabled,
              bool? isSelected,
              bool? isToday,
              TextStyle? textStyle}) =>
          dayBuilder != null
              ? dayBuilder(context,
                  date: date,
                  decoration: decoration,
                  isDisabled: isDisabled,
                  isSelected: isSelected,
                  isToday: isToday,
                  textStyle: textStyle)
              : null,
      controlsHeight: controlsHeight ?? 40);
}
