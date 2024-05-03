import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/recurrence/domain/recurrence.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../common_widgets/money_amount.dart';
import '../../../common_widgets/svg_icon.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';

String recurrenceExpression(BuildContext context, Recurrence recurrence) {
  String everyN;
  String repeatPattern;

  switch (recurrence.type) {
    case RepeatEvery.xDay:
      everyN = context.loc.everyNDay(recurrence.interval);
      repeatPattern = '';
      break;

    case RepeatEvery.xWeek:
      final sort = List<DateTime>.from(recurrence.repeatOn)..sort((a, b) => a.weekday - b.weekday);
      final list = sort
          .map(
            (date) => date.weekdayToString(
              context,
              short: recurrence.repeatOn.length <= 2 ? false : true,
            ),
          )
          .toList();

      everyN = context.loc.everyNWeek(recurrence.interval);
      repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xWeek', list.join(', '));
      break;

    case RepeatEvery.xMonth:
      final sort = List<DateTime>.from(recurrence.repeatOn)..sort((a, b) => a.day - b.day);
      final list = sort
          .map(
            (date) => date.dayToString(context),
          )
          .toList();

      everyN = context.loc.everyNMonth(recurrence.interval);
      repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xMonth', list.join(', '));
      break;

    case RepeatEvery.xYear:
      final sort = List<DateTime>.from(recurrence.repeatOn)..sort((a, b) => a.compareTo(b));
      final list = sort
          .map(
            (date) => date.toShortDate(context, noYear: true),
          )
          .toList();

      everyN = context.loc.everyNYear(recurrence.interval);
      repeatPattern = list.isEmpty ? '' : context.loc.repeatPattern('xYear', list.join(', '));
      break;
  }

  String startDate = recurrence.startOn.isSameDayAs(DateTime.now())
      ? context.loc.today.toLowerCase()
      : recurrence.startOn.toShortDate(context);
  String endDate = recurrence.endOn != null ? context.loc.untilEndDate(recurrence.endOn!.toShortDate(context)) : '';

  return context.loc.quoteRecurrence3(
    everyN,
    repeatPattern,
    recurrence.startOn.isSameDayAs(DateTime.now()).toString(),
    startDate,
    endDate,
  );
}

class TransactionDataTile extends ConsumerWidget {
  const TransactionDataTile({super.key, required this.model, this.withoutIconColor = false});

  final TransactionData model;
  final bool withoutIconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (model.type) {
      TransactionType.transfer => AppColors.grey(context),
      TransactionType.income => context.appTheme.positive,
      TransactionType.expense => context.appTheme.negative,
      TransactionType.creditPayment ||
      TransactionType.creditSpending ||
      TransactionType.creditCheckpoint ||
      TransactionType.installmentToPay =>
        AppColors.grey(context),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CategoryIcon(
              model: model,
              withoutIconColor: withoutIconColor,
            ),
            withoutIconColor ? Gap.w4 : Gap.w8,
            Expanded(
              child: switch (model.type) {
                TransactionType.transfer => _TransferDetails(model: model),
                _ => _WithCategoryDetails(model: model),
              },
            ),
            Gap.w16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MoneyAmount(
                  amount: model.amount,
                  noAnimation: true,
                  style: kHeader2TextStyle.copyWith(
                    color: color,
                    fontSize: 13,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _AccountName(model: model),
                    Gap.w4,
                    _AccountIcon(model: model),
                  ],
                ),
              ],
            ),
          ],
        ),
        _Note(model: model),
      ],
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.model, required this.withoutIconColor});

  final TransactionData model;
  final bool withoutIconColor;

  @override
  Widget build(BuildContext context) {
    Color color() {
      return model.category?.backgroundColor ?? AppColors.greyBgr(context);
    }

    Widget? child() {
      if (model.type == TransactionType.transfer) {
        return SvgIcon(
          AppIcons.transfer,
          color: context.appTheme.onBackground,
        );
      }

      return SvgIcon(
        model.category?.iconPath ?? AppIcons.defaultIcon,
        color: withoutIconColor
            ? context.appTheme.onBackground
            : model.category?.iconColor ?? context.appTheme.onBackground,
      );
    }

    return Container(
      height: 28,
      width: 28,
      padding: EdgeInsets.all(withoutIconColor ? 2.5 : 4),
      decoration: BoxDecoration(
        color: withoutIconColor ? Colors.transparent : color(),
        borderRadius: BorderRadius.circular(100),
      ),
      child: child(),
    );
  }
}

class _AccountIcon extends ConsumerWidget {
  const _AccountIcon({required this.model});

  final TransactionData model;

  String _iconPath(WidgetRef ref) {
    return model.account?.iconPath ?? AppIcons.defaultIcon;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.translate(
      offset: const Offset(0, -1.5),
      child: SvgIcon(
        _iconPath(ref),
        size: 14,
        color: context.appTheme.onBackground.withOpacity(0.65),
      ),
    );
  }
}

class _AccountName extends ConsumerWidget {
  const _AccountName({required this.model, this.destination = false});

  final TransactionData model;
  final bool destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String name() {
      return (destination ? model.toAccount?.name : model.account?.name) ?? 'Not specified';
    }

    return Text(
      name(),
      style: kHeader4TextStyle.copyWith(
        color: context.appTheme.onBackground
            .withOpacity(destination ? (model.toAccount != null ? 0.65 : 0.25) : (model.account != null ? 0.65 : 0.25)),
        fontSize: 11,
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.model});

  final TransactionData model;

  @override
  Widget build(BuildContext context) {
    return model.note != null && model.note!.isNotEmpty
        ? Container(
            margin: const EdgeInsets.only(left: 15.5, top: 8),
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: context.appTheme.onBackground.withOpacity(0.3), width: 1)),
            ),
            child: Transform.translate(
              offset: const Offset(0, -1),
              child: Text(
                model.note!,
                style: kHeader4TextStyle.copyWith(
                  color: context.appTheme.onBackground.withOpacity(0.65),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 2,
              ),
            ),
          )
        : Gap.noGap;
  }
}

class _CategoryName extends StatelessWidget {
  const _CategoryName({required this.model});

  final TransactionData model;

  String get _name {
    if (model.category != null) {
      return model.category!.name;
    }
    return 'Not specified'.hardcoded;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _name,
      style: kHeader3TextStyle.copyWith(
        fontSize: 13,
        color: context.appTheme.onBackground.withOpacity(model.category == null ? 0.25 : 1),
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.model});

  final TransactionData model;

  String? get _categoryTag {
    return model.categoryTag?.name;
  }

  @override
  Widget build(BuildContext context) {
    return _categoryTag != null
        ? Text(
            _categoryTag!,
            style: kHeader3TextStyle.copyWith(
              fontSize: 12,
              color: context.appTheme.onBackground.withOpacity(0.65),
            ),
            softWrap: false,
            overflow: TextOverflow.fade,
          )
        : Gap.noGap;
  }
}

class _WithCategoryDetails extends StatelessWidget {
  const _WithCategoryDetails({required this.model});

  final TransactionData model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryName(model: model),
        _CategoryTag(model: model),
      ],
    );
  }
}

class _TransferDetails extends StatelessWidget {
  const _TransferDetails({required this.model});

  final TransactionData model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer to:'.hardcoded,
          style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 12),
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        _AccountName(
          model: model,
          destination: true,
        ),
      ],
    );
  }
}
