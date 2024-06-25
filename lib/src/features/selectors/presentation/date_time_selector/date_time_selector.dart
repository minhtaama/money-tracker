import 'dart:ui';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/components/credit_payment_info.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../common_widgets/modal_and_dialog.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../accounts/domain/statement/base_class/statement.dart';

part 'for_credit_wrapper.dart';
part 'for_regular_wrapper.dart';
part 'for_editing_show_dialog.dart';
part 'components.dart';
part 'config.dart';

class _CustomCalendarDialog extends StatefulWidget {
  const _CustomCalendarDialog({
    required this.config,
    this.currentDay,
    this.currentMonthView,
    required this.onActionButtonTap,
    this.showReturnNullButton = false,
    this.contentBuilder,
  });

  final CalendarDatePicker2Config config;
  final DateTime? currentDay;
  final DateTime? currentMonthView;
  final ValueSetter<DateTime?>? onActionButtonTap;
  final bool showReturnNullButton;
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: context.isBigScreen ? bigScreenLayout() : smallScreenLayout(),
    );
  }

  Widget smallScreenLayout() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
              child: widget.contentBuilder?.call(monthView: _currentMonthView, selectedDay: _selectedDay),
            ),
            widget.contentBuilder != null ? Gap.divider(context, indent: 20) : Gap.noGap,
            calendarPicker(),
            actionButtons(),
          ],
        ),
      );

  Widget bigScreenLayout() => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: calendarPicker()),
                actionButtons(),
              ],
            ),
          ),
          widget.contentBuilder == null
              ? Gap.noGap
              : Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
                    child: widget.contentBuilder?.call(monthView: _currentMonthView, selectedDay: _selectedDay),
                  ),
                ),
        ],
      );

  Widget calendarPicker() => SizedBox(
        height: 290,
        width: context.isBigScreen ? 300 : 350,
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
      );

  Widget actionButtons() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.showReturnNullButton ? returnNullButton() : Gap.noGap,
          widget.showReturnNullButton ? Gap.w24 : Gap.noGap,
          button(),
        ],
      );

  Widget button() => IconWithTextButton(
        iconPath: _selectedDay != null ? AppIcons.doneLight : AppIcons.backLight,
        label: _selectedDay != null ? context.loc.select : context.loc.back,
        height: 30,
        width: 100,
        labelSize: 13,
        iconSize: 20,
        isDisabled: _selectedDay == null,
        backgroundColor: context.appTheme.primary,
        color: context.appTheme.onPrimary,
        onTap: () {
          widget.onActionButtonTap?.call(_selectedDay);
        },
      );

  Widget returnNullButton() => IconWithTextButton(
        iconPath: AppIcons.closeLight,
        label: 'Clear date'.hardcoded,
        height: 30,
        width: 100,
        labelSize: 13,
        iconSize: 20,
        isDisabled: false,
        backgroundColor: context.appTheme.negative,
        color: context.appTheme.onNegative,
        onTap: () {
          widget.onActionButtonTap?.call(null);
        },
      );
}
