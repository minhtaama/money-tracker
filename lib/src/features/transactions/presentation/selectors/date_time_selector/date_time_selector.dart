import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/empty_info.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/transactions_list.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../../../common_widgets/svg_icon.dart';
import '../../../../../theme_and_ui/icons.dart';
import '../../../data/transaction_repo.dart';
import '../../../domain/transaction.dart';

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
              color: AppColors.grey(context),
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

class _CreditCalendarDialog extends ConsumerStatefulWidget {
  const _CreditCalendarDialog({required this.creditAccount});

  final CreditAccount creditAccount;

  @override
  ConsumerState<_CreditCalendarDialog> createState() => _CreditCalendarDialogState();
}

class _CreditCalendarDialogState extends ConsumerState<_CreditCalendarDialog> {
  late final transactionRepo = ref.read(transactionRepositoryProvider);

  late final _statementDay = widget.creditAccount.creditDetails.statementDay;
  late final _paymentDueDay = widget.creditAccount.creditDetails.paymentDueDay;

  late final _spendingTransactionsDateTimeList = transactionRepo
      .getAll(Calendar.minDate, Calendar.maxDate)
      .whereType<CreditSpending>()
      .map((txn) => txn.dateTime.onlyYearMonthDay)
      .toList();

  DateTime _currentMonthView = DateTime.now();

  DateTime? _selectedDay;

  String get _currencyCode {
    final settingsRepo = ref.read(settingsControllerProvider);
    return settingsRepo.currency.code;
  }

  DateTime get _earliestPayableDate {
    DateTime time = DateTime.now();
    // Get earliest spending transaction un-done
    for (CreditSpending txn in _spendingTransactionsToPay(DateTime.now())) {
      if (!txn.isDone && txn.dateTime.isBefore(time)) {
        time = txn.dateTime;
      }
    }

    // Earliest day that payment can happens
    if (time.day <= _paymentDueDay) {
      time = time.copyWith(day: _paymentDueDay + 1);
    }
    if (time.day >= _statementDay) {
      time = time.copyWith(day: _paymentDueDay + 1, month: time.month + 1);
    }

    return time;
  }

  DateTime get _earliestMonthViewable {
    return DateTime(_earliestPayableDate.year, _earliestPayableDate.month - 1);
  }

  bool _hasSpendingTransaction(DateTime dateTime) {
    final dateTimeYMD = dateTime.onlyYearMonthDay;
    if (_spendingTransactionsDateTimeList.contains(dateTimeYMD)) {
      return true;
    }
    return false;
  }

  bool _selectableDayPredicate(DateTime date) {
    if ((date.day >= _statementDay || date.day <= _paymentDueDay) && date.isAfter(_earliestPayableDate)) {
      return true;
    } else {
      return false;
    }
  }

  List<CreditSpending> _spendingTransactionsToPay(DateTime selectedDate) {
    DateTime dayBegin = Calendar.minDate;
    DateTime dayEnd;
    if (selectedDate.day >= _statementDay) {
      dayEnd = selectedDate.copyWith(day: _statementDay);
    } else if (selectedDate.day <= _paymentDueDay) {
      dayEnd = selectedDate.copyWith(day: _statementDay, month: selectedDate.month - 1);
    } else {
      dayEnd = selectedDate;
    }

    return transactionRepo.getAll(dayBegin, dayEnd).whereType<CreditSpending>().where((txn) => !txn.isDone).toList();
  }

  //TODO: move this function into customConfig
  //TODO: make some tweaks about app color grey
  Widget _dayBuilder(
      {required DateTime date,
      BoxDecoration? decoration,
      bool? isDisabled,
      bool? isSelected,
      bool? isToday,
      TextStyle? textStyle}) {
    return CustomInkWell(
      onTap: () {
        if (isDisabled != null && !isDisabled) {
          setState(() {
            if (_selectedDay == date) {
              _selectedDay = null;
            } else {
              _selectedDay = date;
            }
          });
        }
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            border: isToday != null && isToday
                ? Border.all(
                    color: isDisabled != null && isDisabled ? AppColors.grey(context) : context.appTheme.primary,
                  )
                : null,
            color: isSelected != null && isSelected
                ? context.appTheme.primary
                : _hasSpendingTransaction(date)
                    ? context.appTheme.negative.withOpacity(isDisabled != null && isDisabled ? 0.7 : 1)
                    : Colors.transparent,
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: kHeader4TextStyle.copyWith(
                color: isDisabled != null && isDisabled
                    ? AppColors.grey(context)
                    : isSelected != null && isSelected
                        ? context.appTheme.primaryNegative
                        : _hasSpendingTransaction(date)
                            ? context.appTheme.onNegative
                            : context.appTheme.backgroundNegative,
              ),
            ),
          ),
        ),
      ),
    );
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
          onTap: () {
            if (_selectedDay != null) {
              context.pop([_selectedDay as DateTime, _spendingTransactionsToPay(_selectedDay!)]);
            } else {
              context.pop();
            }
          },
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedSize(
                duration: k150msDuration,
                child: _currentMonthView.isAtSameMomentAs(_earliestMonthViewable)
                    ? EmptyInfo(
                        iconPath: AppIcons.done,
                        infoText: 'No spending transaction is needed to pay before this time'.hardcoded,
                      )
                    : _selectedDay != null
                        ? TransactionsList(
                            transactions: _spendingTransactionsToPay(_selectedDay!), currencyCode: _currencyCode)
                        : EmptyInfo(
                            iconPath: AppIcons.today,
                            infoText: 'Select a payment day.\n Spending transaction can be paid will be displayed here'
                                .hardcoded,
                          ),
              ),
            ),
            SizedBox(
              height: 300,
              width: 350,
              child: CalendarDatePicker2(
                config: _customConfig(
                  context,
                  firstDate: _earliestMonthViewable,
                  selectableDayPredicate: _selectableDayPredicate,
                  dayBuilder: _dayBuilder,
                ),
                value: [_selectedDay],
                onDisplayedMonthChanged: (dateTime) => setState(() {
                  _currentMonthView = dateTime;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    yearBuilder: yearBuilder,
    dayBuilder: dayBuilder,
    cancelButtonTextStyle: kHeader2TextStyle.copyWith(
        fontSize: 15, color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary),
    okButtonTextStyle: kHeader2TextStyle.copyWith(
        fontSize: 15, color: context.appTheme.isDarkTheme ? context.appTheme.secondary : context.appTheme.primary),
  );
}
