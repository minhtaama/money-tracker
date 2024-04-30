import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/inline_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/custom_radio.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../selectors/presentation/date_time_selector/date_time_selector.dart';

class RecurrenceWidget extends ConsumerStatefulWidget {
  const RecurrenceWidget({super.key, required this.onChanged});

  final void Function(RecurrenceForm recurrenceForm) onChanged;

  @override
  ConsumerState<RecurrenceWidget> createState() => _CreateRecurrenceWidgetState();
}

class _CreateRecurrenceWidgetState extends ConsumerState<RecurrenceWidget> {
  RecurrenceForm? _recurrenceForm;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      border: Border.all(color: context.appTheme.onBackground.withOpacity(0.4)),
      width: double.infinity,
      child: CustomInkWell(
        inkColor: context.appTheme.onBackground,
        onTap: () {
          showCustomModal(
            context: context,
            builder: (controller, isScrollable) => _CreateRecurrenceModal(
              controller,
              isScrollable,
              initialForm: _recurrenceForm,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SvgIcon(
                AppIcons.switchIcon,
                color: context.appTheme.onBackground.withOpacity(0.4),
                size: 22,
              ),
              Gap.w8,
              Text(
                'No repeat'.hardcoded,
                style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.4), fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateRecurrenceModal extends StatefulWidget {
  const _CreateRecurrenceModal(this.controller, this.isScrollable, {super.key, required this.initialForm});

  final RecurrenceForm? initialForm;
  final ScrollController controller;
  final bool isScrollable;

  @override
  State<_CreateRecurrenceModal> createState() => _CreateRecurrenceModalState();
}

class _CreateRecurrenceModalState extends State<_CreateRecurrenceModal> {
  final _formKey = GlobalKey<FormState>();

  late RecurrenceForm _form = widget.initialForm ?? RecurrenceForm.initial();

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      formKey: _formKey,
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: 'Recurring transaction'.hardcoded,
      ),
      body: [
        _wrapper(
          repeat: RepeatEvery.xDay,
          children: [
            CustomRadio<RepeatEvery?>(
              labelWidget: _label(RepeatEvery.xDay),
              value: RepeatEvery.xDay,
              groupValue: _form.type,
              onChanged: (value) => setState(() {
                _form = _form.copyWith(type: () => value);
                _form.repeatOn.clear();
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
                _form.repeatOn.clear();
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
                _form.repeatOn.clear();
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
                _form.repeatOn.clear();
              }),
            ),
            HideableContainer(
              hide: _form.type != RepeatEvery.xYear,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CustomCalendar(
                  value: _form.repeatOn,
                  onValueChanged: (list) => setState(() {
                    _form.repeatOn.clear();
                    _form.repeatOn.addAll(list.whereType<DateTime>());
                  }),
                ),
              ),
            ),
          ],
        ),
        Gap.divider(context, indent: 12),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 16.0),
          child: Row(
            children: [
              Text(
                'Until:',
                style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 16),
              ),
              Gap.w4,
              DateSelector(
                initial: _form.endOn,
                onChangedNullable: (dateTime) => setState(() {
                  _form = _form.copyWith(endOn: () => dateTime);
                }),
                labelBuilder: (dateTime) {
                  return dateTime == null ? 'Forever'.hardcoded : dateTime.toLongDate(context);
                },
              ),
            ],
          ),
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: true,
        onBigButtonTap: () => context.pop(_form),
      ),
    );
  }

  Widget _label(RepeatEvery repeat) {
    final suffix = switch (repeat) {
      RepeatEvery.xDay => 'day(s)'.hardcoded,
      RepeatEvery.xWeek => 'week(s)'.hardcoded,
      RepeatEvery.xMonth => 'month(s)'.hardcoded,
      RepeatEvery.xYear => 'year(s)'.hardcoded,
    };

    return InlineTextFormField(
      prefixText: 'Repeat every'.hardcoded,
      suffixText: suffix,
      width: 40,
      initialValue: _form.interval.toString(),
      onChanged: (value) {
        if (value != '') {
          setState(() {
            _form = _form.copyWith(interval: int.parse(value));
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
            final isAdded = _form.repeatOn.contains(date);
            final isSunSat = date.weekday == 6 || date.weekday == 7;

            final bgColor = context.appTheme.primary.withOpacity(isAdded ? 1 : 0);

            final fgColor = isAdded
                ? context.appTheme.onPrimary
                : isSunSat
                    ? context.appTheme.negative
                    : context.appTheme.onBackground;

            return Flexible(
              child: CardItem(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: CustomInkWell(
                  inkColor: context.appTheme.primary,
                  onTap: () {
                    if (_form.repeatOn.contains(date) && _form.repeatOn.length > 1) {
                      setState(() {
                        _form.repeatOn.remove(date);
                      });
                    } else {
                      setState(() {
                        _form.repeatOn.add(date);
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      date.weekdayToString(context, short: true).toUpperCase(),
                      style: kHeader2TextStyle.copyWith(color: fgColor, fontSize: 13),
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

      final isAdded = _form.repeatOn.contains(date);

      final bgColor = context.appTheme.primary.withOpacity(isAdded ? 1 : 0);

      final fgColor = isAdded ? context.appTheme.onPrimary : context.appTheme.onBackground;

      return Center(
        child: CardItem(
          color: bgColor,
          height: 33,
          width: 33,
          borderRadius: BorderRadius.circular(1000),
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: CustomInkWell(
            inkColor: context.appTheme.primary,
            onTap: () {
              if (_form.repeatOn.contains(date) && _form.repeatOn.length > 1) {
                setState(() {
                  _form.repeatOn.remove(date);
                });
              } else {
                setState(() {
                  _form.repeatOn.add(date);
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

  Widget _wrapper({required RepeatEvery repeat, required List<Widget> children}) {
    return CardItem(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 2),
      color: context.appTheme.primary.withOpacity(_form.type == repeat ? 0.08 : 0),
      border: Border.all(color: context.appTheme.primary.withOpacity(_form.type == repeat ? 0.5 : 0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class RecurrenceForm {
  final RepeatEvery? type;

  final int interval;

  /// Only year, month, day
  final List<DateTime> repeatOn;

  // /// Only year, month, day
  // final DateTime startOn;

  /// Only year, month, day
  final DateTime? endOn;

  final bool autoCreateTransaction;

  factory RecurrenceForm.initial() {
    return RecurrenceForm._(
      //startOn: DateTime.now(),
      interval: 1,
      repeatOn: [],
      autoCreateTransaction: true,
    );
  }

  RecurrenceForm._({
    this.type,
    required this.interval,
    required this.repeatOn,
    //required this.startOn,
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
      repeatOn: repeatOn,
      autoCreateTransaction: autoCreateTransaction ?? this.autoCreateTransaction,
      //startOn: startOn,
    );
  }
}
