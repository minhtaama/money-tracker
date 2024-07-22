import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/inline_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../../common_widgets/custom_radio.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../selectors/presentation/date_time_selector/date_time_selector.dart';

String _recurrenceExpression(BuildContext context, RecurrenceForm form) {
  String everyN;
  String repeatPattern;

  switch (form.type) {
    case RepeatEvery.xDay || null:
      everyN = context.loc.everyNDay(form.interval);
      repeatPattern = '';
      break;

    case RepeatEvery.xWeek:
      final sort = List<DateTime>.from(form.patterns)..sort((a, b) => a.weekday - b.weekday);
      final list = sort
          .map(
            (date) => date.weekdayToString(
              context,
            ),
          )
          .toList();

      everyN = context.loc.everyNWeek(form.interval);
      repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xWeek', list.join(', '));
      break;

    case RepeatEvery.xMonth:
      final sort = List<DateTime>.from(form.patterns)..sort((a, b) => a.day - b.day);
      final list = sort
          .map(
            (date) => date.dayToString(context),
          )
          .toList();

      everyN = context.loc.everyNMonth(form.interval);
      repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xMonth', list.join(', '));
      break;

    case RepeatEvery.xYear:
      final sort = List<DateTime>.from(form.patterns)..sort((a, b) => a.compareTo(b));
      final list = sort
          .map(
            (date) => date.toShortDate(context, noYear: true),
          )
          .toList();

      everyN = context.loc.everyNYear(form.interval);
      repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xYear', list.join(', '));
      break;
  }

  String startDate =
      form.startOn.isSameDayAs(DateTime.now()) ? context.loc.today.toLowerCase() : form.startOn.toShortDate(context);
  String endDate = form.endOn != null ? context.loc.untilEndDate(form.endOn!.toShortDate(context)) : '';

  return form.type == null
      ? context.loc.quoteRecurrence1
      : context.loc.quoteRecurrence2(
          everyN,
          repeatPattern,
          form.startOn.isSameDayAs(DateTime.now()).toString(),
          startDate,
          endDate,
        );
}

class CreateRecurrenceWidget extends ConsumerStatefulWidget {
  const CreateRecurrenceWidget({
    super.key,
    required this.initialForm,
    required this.transactionDateTime,
    required this.onChanged,
  });

  final RecurrenceForm? initialForm;
  final DateTime transactionDateTime;
  final void Function(RecurrenceForm? recurrenceForm) onChanged;

  @override
  ConsumerState<CreateRecurrenceWidget> createState() => _CreateRecurrenceWidgetState();
}

class _CreateRecurrenceWidgetState extends ConsumerState<CreateRecurrenceWidget> {
  late RecurrenceForm? _recurrenceForm = widget.initialForm;

  @override
  void didUpdateWidget(covariant CreateRecurrenceWidget oldWidget) {
    if (widget.initialForm != oldWidget.initialForm) {
      setState(() {
        _recurrenceForm = widget.initialForm;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      color: context.appTheme.primary.withOpacity(_recurrenceForm == null ? 0 : 1),
      border: Border.all(color: context.appTheme.onBackground.withOpacity(_recurrenceForm == null ? 0.4 : 0)),
      width: double.infinity,
      child: CustomInkWell(
        inkColor: _recurrenceForm == null ? context.appTheme.onBackground : context.appTheme.onPrimary,
        onTap: () async {
          final returnedForm = await showCustomModal<RecurrenceForm>(
            context: context,
            builder: (controller, isScrollable) => _CreateRecurrenceModal(
              controller,
              isScrollable,
              initialForm: _recurrenceForm,
              transactionDateTime: widget.transactionDateTime,
            ),
          );

          if (returnedForm != null) {
            setState(() {
              if (returnedForm.type == null) {
                _recurrenceForm = null;
              } else {
                _recurrenceForm = returnedForm;
              }
            });

            widget.onChanged(_recurrenceForm);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SvgIcon(
                AppIcons.switchTwoTone,
                color: _recurrenceForm == null
                    ? context.appTheme.onBackground.withOpacity(0.4)
                    : context.appTheme.onPrimary,
                size: 22,
              ),
              Gap.w8,
              Expanded(
                child: Text(
                  _recurrenceForm == null ? context.loc.doNotRepeat : _recurrenceExpression(context, _recurrenceForm!),
                  style: kHeader3TextStyle.copyWith(
                      color: _recurrenceForm == null
                          ? context.appTheme.onBackground.withOpacity(0.4)
                          : context.appTheme.onPrimary,
                      fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////

class _CreateRecurrenceModal extends StatefulWidget {
  const _CreateRecurrenceModal(
    this.controller,
    this.isScrollable, {
    required this.initialForm,
    required this.transactionDateTime,
  });

  final RecurrenceForm? initialForm;
  final DateTime transactionDateTime;
  final ScrollController controller;
  final bool isScrollable;

  @override
  State<_CreateRecurrenceModal> createState() => _CreateRecurrenceModalState();
}

class _CreateRecurrenceModalState extends State<_CreateRecurrenceModal> {
  late RecurrenceForm _form = widget.initialForm ?? RecurrenceForm.initial(widget.transactionDateTime);

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        secondaryTitle: context.loc.recurrence,
        subTitle: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            _recurrenceExpression(context, _form),
            style: kHeader1TextStyle.copyWith(
              color: context.appTheme.onBackground.withOpacity(0.8),
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: [
        _wrapper(
          repeat: null,
          children: [
            CustomRadio<RepeatEvery?>(
              labelWidget: _label(null),
              value: null,
              groupValue: _form.type,
              onChanged: (value) => setState(() {
                _form = _form.copyWith(type: () => null);
              }),
            ),
          ],
        ),
        _wrapper(
          repeat: RepeatEvery.xDay,
          children: [
            CustomRadio<RepeatEvery?>(
              labelWidget: _label(RepeatEvery.xDay),
              value: RepeatEvery.xDay,
              groupValue: _form.type,
              onChanged: (value) => setState(() {
                _form = _form.copyWith(type: () => value);
                _form.patterns.clear();
              }),
            ),
          ],
        ),
        _wrapper(
          repeat: RepeatEvery.xWeek,
          children: [
            CustomRadio<RepeatEvery?>(
              labelWidget: _label(RepeatEvery.xWeek),
              value: RepeatEvery.xWeek,
              groupValue: _form.type,
              onChanged: (value) => setState(() {
                _form = _form.copyWith(type: () => value);
                _form.patterns.clear();
              }),
            ),
            HideableContainer(
              hide: _form.type != RepeatEvery.xWeek,
              child: _patternOnRepeatByWeek(),
            ),
          ],
        ),
        _wrapper(
          repeat: RepeatEvery.xMonth,
          children: [
            CustomRadio<RepeatEvery?>(
              labelWidget: _label(RepeatEvery.xMonth),
              value: RepeatEvery.xMonth,
              groupValue: _form.type,
              onChanged: (value) => setState(() {
                _form = _form.copyWith(type: () => value);
                _form.patterns.clear();
              }),
            ),
            HideableContainer(
              hide: _form.type != RepeatEvery.xMonth,
              child: _patternOnRepeatByMonth(),
            ),
          ],
        ),
        _wrapper(
          repeat: RepeatEvery.xYear,
          children: [
            CustomRadio<RepeatEvery?>(
              labelWidget: _label(RepeatEvery.xYear),
              value: RepeatEvery.xYear,
              groupValue: _form.type,
              onChanged: (value) => setState(() {
                _form = _form.copyWith(type: () => value);
                _form.patterns.clear();
              }),
            ),
            HideableContainer(
              hide: _form.type != RepeatEvery.xYear,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CustomCalendar(
                  value: _form.patterns,
                  onValueChanged: (list) => setState(() {
                    _form.patterns.clear();
                    _form.patterns.addAll(list.whereType<DateTime>());
                  }),
                ),
              ),
            ),
          ],
        ),
        Gap.h12,
        HideableContainer(
          hide: _form.type == null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Until:',
                  style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 16),
                ),
                Gap.w4,
                DateSelector(
                  initial: _form.endOn,
                  selectableDayPredicate: (dateTime) =>
                      dateTime.onlyYearMonthDay.isAfter(_form.startOn.onlyYearMonthDay),
                  onChangedNullable: (dateTime) => setState(() {
                    _form = _form.copyWith(endOn: () => dateTime);
                  }),
                  labelBuilder: (dateTime) {
                    return dateTime == null ? context.loc.forever : dateTime.toLongDate(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: _isBigButtonDisabled(),
        bigButtonLabel: context.loc.done,
        bigButtonIcon: AppIcons.doneLight,
        onBigButtonTap: () {
          if (!_isBigButtonDisabled()) {
            context.pop(_form);
          }
        },
        optional: _validatorWidget(),
      ),
    );
  }

  Widget _label(RepeatEvery? repeat) {
    final suffix = switch (repeat) {
      RepeatEvery.xDay => context.loc.dayS,
      RepeatEvery.xWeek => context.loc.weekS,
      RepeatEvery.xMonth => context.loc.monthS,
      RepeatEvery.xYear => context.loc.yearS,
      null => context.loc.doNotRepeat,
    };

    if (repeat == null) {
      return Text(
        suffix,
        style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground),
      );
    }

    return InlineTextFormField(
      prefixText: context.loc.repeatEvery,
      suffixText: suffix,
      width: 30,
      maxLength: 2,
      initialValue: _form.interval.toString(),
      onChanged: (value) {
        if (value != '') {
          setState(() {
            _form = _form.copyWith(interval: int.tryParse(value));
          });
        }
      },
    );
  }

  Widget _patternOnRepeatByWeek() {
    final range = DateTime.now().weekRange(context);
    final datePatterns = [
      for (DateTime dateTime = range.start;
          !dateTime.isAfter(range.end);
          dateTime = dateTime.add(const Duration(days: 1)))
        dateTime
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: datePatterns.map(
          (date) {
            final isAdded = _form.patterns.contains(date);
            final isSun = date.weekday == 7;

            final bgColor = context.appTheme.primary.withOpacity(isAdded ? 1 : 0);

            final fgColor = isAdded
                ? context.appTheme.onPrimary
                : isSun
                    ? context.appTheme.negative
                    : context.appTheme.onBackground;

            return Expanded(
              child: CardItem(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.appTheme.primary.withOpacity(date.isSameDayAs(DateTime.now()) ? 1 : 0),
                ),
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                child: CustomInkWell(
                  inkColor: context.appTheme.primary,
                  onTap: () {
                    HapticFeedback.vibrate();
                    if (_form.patterns.contains(date)) {
                      setState(() {
                        _form.patterns.remove(date);
                      });
                    } else {
                      setState(() {
                        _form.patterns.add(date);
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Center(
                      child: Text(
                        date.weekdayToString(context, short: true).toUpperCase(),
                        style: kHeader2TextStyle.copyWith(color: fgColor, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _patternOnRepeatByMonth() {
    Widget item(int i) {
      final date = DateTime(2024, 5, i);

      final isAdded = _form.patterns.contains(date);

      final bgColor = context.appTheme.primary.withOpacity(isAdded ? 1 : 0);

      final fgColor = isAdded ? context.appTheme.onPrimary : context.appTheme.onBackground;

      return Center(
        child: CardItem(
          color: bgColor,
          height: 33,
          width: 33,
          borderRadius: BorderRadius.circular(1000),
          border: Border.all(
            color: context.appTheme.primary.withOpacity(date.isSameDayAs(DateTime.now()) ? 1 : 0),
          ),
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: CustomInkWell(
            inkColor: context.appTheme.primary,
            onTap: () {
              HapticFeedback.vibrate();
              if (_form.patterns.contains(date)) {
                setState(() {
                  _form.patterns.remove(date);
                });
              } else {
                setState(() {
                  _form.patterns.add(date);
                });
              }
            },
            child: Center(
              child: Text(
                date.day.toString(),
                style: kHeader2TextStyle.copyWith(color: fgColor, fontSize: 15, height: 0.99),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 16.0),
      child: Table(children: [
        TableRow(children: [Gap.noGap, for (int i = 1; i <= 6; i++) item(i)]),
        TableRow(children: [for (int i = 7; i <= 13; i++) item(i)]),
        TableRow(children: [for (int i = 14; i <= 20; i++) item(i)]),
        TableRow(children: [for (int i = 21; i <= 27; i++) item(i)]),
        TableRow(children: [for (int i = 28; i <= 31; i++) item(i), Gap.noGap, Gap.noGap, Gap.noGap]),
      ]),
    );
  }

  Widget _wrapper({RepeatEvery? repeat, bool alwaysShow = false, required List<Widget> children}) {
    return CardItem(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 2),
      color: context.appTheme.primary.withOpacity(_form.type == repeat || alwaysShow ? 0.08 : 0),
      border: Border.all(color: context.appTheme.primary.withOpacity(_form.type == repeat || alwaysShow ? 0.5 : 0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _validatorWidget() {
    return Column(
      children: [
        HideableContainer(
          hide: _form.patterns.isNotEmpty || _form.type == null || _form.type == RepeatEvery.xDay,
          child: Row(
            children: [
              SvgIcon(
                AppIcons.editLight,
                color: context.appTheme.onBackground,
                size: 17,
              ),
              Gap.w4,
              Expanded(
                child: Text(
                  context.loc.selectRepeatCondition,
                  style: kNormalTextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 11,
                  ),
                ),
              ),
              Gap.w10,
            ],
          ),
        ),
        HideableContainer(
          hide: _form.interval >= 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              children: [
                SvgIcon(
                  AppIcons.sadFaceBulk,
                  color: context.appTheme.negative,
                  size: 17,
                ),
                Gap.w4,
                Expanded(
                  child: Text(
                    context.loc.wrongInterval,
                    style: kNormalTextStyle.copyWith(
                      color: context.appTheme.negative,
                      fontSize: 11,
                    ),
                  ),
                ),
                Gap.w10,
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isBigButtonDisabled() {
    return (_form.patterns.isEmpty && _form.type != null && _form.type != RepeatEvery.xDay) || _form.interval <= 0;
  }
}

////////////////////////////////////////////

class RecurrenceForm {
  final RepeatEvery? type;

  final int interval;

  /// Only year, month, day
  final List<DateTime> patterns;

  /// Only year, month, day
  final DateTime startOn;

  //TODO: change startOn

  /// Only year, month, day
  final DateTime? endOn;

  final bool autoCreateTransaction;

  factory RecurrenceForm.initial(DateTime txnDateTime) {
    final today = DateTime.now().onlyYearMonthDay;
    final startOn = txnDateTime.onlyYearMonthDay.isAfter(today) ? txnDateTime.onlyYearMonthDay : today;

    return RecurrenceForm._(
      startOn: startOn,
      interval: 1,
      patterns: [],
      autoCreateTransaction: true,
    );
  }

  RecurrenceForm._({
    this.type,
    required this.interval,
    required this.patterns,
    required this.startOn,
    this.endOn,
    required this.autoCreateTransaction,
  });

  RecurrenceForm copyWith({
    RepeatEvery? Function()? type,
    int? interval,
    DateTime? Function()? endOn,
    bool? autoCreateTransaction,
  }) {
    return RecurrenceForm._(
      type: type != null ? type() : this.type,
      interval: interval ?? this.interval,
      endOn: endOn != null ? endOn() : this.endOn,
      patterns: patterns,
      autoCreateTransaction: autoCreateTransaction ?? this.autoCreateTransaction,
      startOn: startOn,
    );
  }

  RecurrenceForm updateStartOnDate(DateTime dateTime) {
    final today = DateTime.now().onlyYearMonthDay;
    final startOn = dateTime.onlyYearMonthDay.isAfter(today) ? dateTime.onlyYearMonthDay : today;

    return RecurrenceForm._(
      type: type,
      interval: interval,
      endOn: endOn,
      patterns: patterns,
      autoCreateTransaction: autoCreateTransaction,
      startOn: startOn,
    );
  }

  @override
  String toString() {
    return 'RecurrenceForm{runtimeType: $runtimeType, type: $type, interval: $interval, repeatOn: $patterns, endOn: $endOn, autoCreateTransaction: $autoCreateTransaction}';
  }
}
