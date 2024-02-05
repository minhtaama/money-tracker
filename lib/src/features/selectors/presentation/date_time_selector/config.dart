part of 'calendar_dialog.dart';

class _DayBuilder {
  static Widget background(
    BuildContext context,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday,
    Color bgrColor,
    Border? bgrBorder,
  ) {
    return Container(
      height: 33,
      width: 33,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        border: bgrBorder,
        color: bgrColor,
      ),
    );
  }

  static Widget dayWithIcon(
    BuildContext context,
    Color foregroundColor,
    bool canAddTransaction,
    bool hasPayment,
    bool hasSpending,
    bool hasCheckpoint,
    bool isStatementDay,
    bool isDueDay,
  ) {
    Widget icon(String path, {Color? color}) =>
        Expanded(child: SvgIcon(path, color: color ?? foregroundColor, size: 23));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isStatementDay
            ? hasCheckpoint
                ? icon(AppIcons.statementCheckpoint)
                : icon(AppIcons.budgets)
            : Gap.noGap,
        isDueDay ? icon(AppIcons.handCoin) : Gap.noGap,
        hasSpending
            ? icon(
                AppIcons.receiptDollar,
                color: context.appTheme.negative.withOpacity(canAddTransaction ? 1 : 0.33),
              )
            : Gap.noGap,
        hasPayment
            ? icon(
                AppIcons.receiptCheck,
                color: context.appTheme.positive.withOpacity(canAddTransaction ? 1 : 0.33),
              )
            : Gap.noGap,
      ],
    );
  }

  static Widget normalDay(
    DateTime date,
    Color foregroundColor,
  ) {
    return Text(
      date.day.toString(),
      style: kHeader3TextStyle.copyWith(color: foregroundColor, height: 0.99, fontSize: kHeader4TextStyle.fontSize),
    );
  }

  static Color foregroundColor(
    BuildContext context,
    bool? isDisabled,
    bool? isSelected,
    bool canAddTransaction,
  ) {
    if (isDisabled != null && isDisabled) {
      return AppColors.greyBgr(context);
    }

    if (isSelected != null && isSelected) {
      return context.appTheme.onPrimary;
    }

    return context.appTheme.onBackground.withOpacity(canAddTransaction ? 1 : 0.33);
  }

  static Color bgrColor(
    BuildContext context,
    bool? isDisabled,
    bool? isSelected,
    bool canAddTransaction,
  ) {
    return isSelected != null && isSelected ? context.appTheme.primary : Colors.transparent;
  }

  static Border? bgrBorder(
    BuildContext context,
    bool? isDisabled,
    bool? isToday,
    bool canAddTransaction,
  ) {
    if (isToday != null && isToday) {
      return Border.all(
        color: isDisabled != null && isDisabled ? AppColors.greyBgr(context) : context.appTheme.primary,
      );
    }

    return null;
  }

  static Widget forCredit(
    BuildContext context,
    DateTime date,
    bool? isDisabled,
    bool? isSelected,
    bool? isToday, {
    required bool canAddTransaction,
    required bool hasPayment,
    required bool hasSpending,
    required bool hasCheckpoint,
    required bool isStatementDay,
    required bool isDueDay,
  }) {
    final foregroundColor = _DayBuilder.foregroundColor(context, isDisabled, isSelected, canAddTransaction);
    final bgrColor = _DayBuilder.bgrColor(context, isDisabled, isSelected, canAddTransaction);
    final bgrBorder = _DayBuilder.bgrBorder(context, isDisabled, isToday, canAddTransaction);

    return Stack(
      alignment: Alignment.center,
      children: [
        _DayBuilder.background(context, isDisabled, isSelected, isToday, bgrColor, bgrBorder),
        !isStatementDay && !isDueDay && !hasSpending && !hasPayment || isSelected!
            ? _DayBuilder.normalDay(date, foregroundColor)
            : _DayBuilder.dayWithIcon(
                context,
                foregroundColor,
                canAddTransaction,
                hasPayment,
                hasSpending,
                hasCheckpoint,
                isStatementDay,
                isDueDay,
              )
      ],
    );
  }
}

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
