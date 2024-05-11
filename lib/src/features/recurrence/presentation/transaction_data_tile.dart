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

class TransactionDataTile extends ConsumerWidget {
  const TransactionDataTile({
    super.key,
    required this.model,
    this.withoutIconColor = false,
    this.smaller = false,
    this.showState = false,
    this.showDateTime = false,
  });

  final TransactionData model;
  final bool withoutIconColor;
  final bool smaller;
  final bool showState;
  final bool showDateTime;

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CategoryIcon(
          model: model,
          withoutIconColor: withoutIconColor,
          smaller: smaller,
        ),
        withoutIconColor ? Gap.w4 : Gap.w8,
        Expanded(
          child: switch (model.type) {
            TransactionType.transfer => _TransferDetails(
                model: model,
                smaller: smaller,
              ),
            _ => _WithCategoryDetails(
                model: model,
                smaller: smaller,
                showState: showState,
                showDateTime: showDateTime,
              ),
          },
        ),
        Gap.w8,
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MoneyAmount(
              amount: model.amount,
              noAnimation: true,
              style: smaller
                  ? kHeader3TextStyle.copyWith(
                      color: color.withOpacity(0.65),
                      fontSize: 11,
                    )
                  : kHeader2TextStyle.copyWith(
                      color: color,
                      fontSize: 13,
                    ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AccountName(
                  model: model,
                  smaller: smaller,
                ),
                Gap.w4,
                _AccountIcon(
                  model: model,
                  smaller: smaller,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.model,
    required this.withoutIconColor,
    required this.smaller,
  });

  final TransactionData model;
  final bool withoutIconColor;
  final bool smaller;

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
          size: 25,
        );
      }

      return SvgIcon(
        model.category?.iconPath ?? AppIcons.defaultIcon,
        color: withoutIconColor
            ? context.appTheme.onBackground
            : model.category?.iconColor ?? context.appTheme.onBackground,
        size: 25,
      );
    }

    return Container(
      height: smaller ? 24 : 28,
      width: smaller ? 24 : 28,
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
  const _AccountIcon({required this.model, required this.smaller});

  final TransactionData model;
  final bool smaller;

  String _iconPath(WidgetRef ref) {
    return model.account?.iconPath ?? AppIcons.defaultIcon;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.translate(
      offset: const Offset(0, -1.5),
      child: SvgIcon(
        _iconPath(ref),
        size: smaller ? 12 : 14,
        color: context.appTheme.onBackground.withOpacity(0.65),
      ),
    );
  }
}

class _AccountName extends ConsumerWidget {
  const _AccountName({required this.model, this.destination = false, required this.smaller});

  final TransactionData model;
  final bool destination;
  final bool smaller;

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
        fontSize: smaller ? 9 : 11,
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class _CategoryName extends StatelessWidget {
  const _CategoryName({required this.model, required this.smaller});

  final TransactionData model;
  final bool smaller;

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
        fontSize: smaller ? 11 : 13,
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

  @override
  Widget build(BuildContext context) {
    String categoryTag = model.categoryTag?.name ?? '';

    String note = model.note != null ? 'Note: ${model.note}' : '';

    bool hasBoth = model.categoryTag != null && model.note != null;
    bool notBoth = model.categoryTag == null && model.note == null;

    return notBoth
        ? Gap.noGap
        : Text(
            '$categoryTag${hasBoth ? ' / ' : ''}$note',
            style: kHeader3TextStyle.copyWith(
              fontSize: 12,
              color: context.appTheme.onBackground.withOpacity(0.65),
            ),
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );
  }
}

class _WithCategoryDetails extends StatelessWidget {
  const _WithCategoryDetails(
      {required this.model, required this.smaller, required this.showDateTime, required this.showState});

  final TransactionData model;
  final bool smaller;
  final bool showState;
  final bool showDateTime;

  @override
  Widget build(BuildContext context) {
    final state = model.state != null
        ? switch (model.state!) {
            PlannedState.upcoming => 'Upcoming'.hardcoded,
            PlannedState.today => 'Today'.hardcoded,
            PlannedState.added => 'Added'.hardcoded,
            PlannedState.skipped => 'Skipped'.hardcoded,
            PlannedState.overdue => 'Overdue'.hardcoded,
          }
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        showDateTime || showState
            ? Text(
                showState
                    ? state
                    : '${model.dateTime!.weekdayToString(context, short: true)}, ${model.dateTime!.toShortDate(context, noYear: true)}',
                style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 10),
                softWrap: false,
                overflow: TextOverflow.fade,
              )
            : Gap.noGap,
        _CategoryName(model: model, smaller: smaller),
        smaller ? Gap.noGap : _CategoryTag(model: model),
      ],
    );
  }
}

class _TransferDetails extends StatelessWidget {
  const _TransferDetails({required this.model, required this.smaller});

  final TransactionData model;
  final bool smaller;

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
          smaller: smaller,
        ),
      ],
    );
  }
}
