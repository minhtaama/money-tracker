import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../common_widgets/custom_inkwell.dart';
import '../../../routing/app_router.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../utils/constants.dart';
import '../../transactions/domain/transaction_base.dart';
import '../../transactions/presentation/transaction/txn_components.dart';
import '../domain/statement/statement.dart';

class CheckpointInstallmentsList extends StatelessWidget {
  const CheckpointInstallmentsList({
    super.key,
    required this.statement,
    required this.onMarkAsDone,
  });

  final Statement? statement;
  final void Function(List<Installment>, double) onMarkAsDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ongoing installments:',
          style: kHeader4TextStyle.copyWith(fontSize: 15, color: context.appTheme.onBackground),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        Gap.h8,
        CustomBox(
          child: statement != null
              ? _List(
                  statement: statement!,
                  onMarkAsDone: (list, value) => onMarkAsDone(list, value),
                )
              : Gap.noGap,
        ),
      ],
    );
  }
}

class _List extends StatefulWidget {
  const _List({required this.statement, required this.onMarkAsDone});

  final Statement statement;
  final void Function(List<Installment>, double) onMarkAsDone;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final List<Installment> _installmentsMarkAsDone = [];

  late List<Installment> _installmentsList = widget.statement.installments;

  @override
  void initState() {
    widget.onMarkAsDone(_installmentsMarkAsDone, _totalUnpaid);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _List oldWidget) {
    setState(() {
      _installmentsList = widget.statement.installments;
      _installmentsMarkAsDone.clear();
      widget.onMarkAsDone(_installmentsMarkAsDone, _totalUnpaid);
    });
    super.didUpdateWidget(oldWidget);
  }

  double get _totalUnpaid {
    double result = 0;
    for (Installment ins in widget.statement.installments) {
      result += ins.txn.paymentAmount!.roundBySetting(context) * ins.monthsLeft;
    }
    for (Installment ins in _installmentsMarkAsDone) {
      result -= ins.txn.paymentAmount!.roundBySetting(context) * ins.monthsLeft;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _installmentsList.isEmpty
                ? [
                    IconWithText(
                      iconPath: AppIcons.done,
                      header: 'No ongoing installments at selected date',
                    )
                  ]
                : [
                    for (Installment ins in _installmentsList)
                      _InstallmentDetails(
                        ins.txn,
                        ins.monthsLeft,
                        isDone: _installmentsMarkAsDone.contains(ins),
                        onMarkAsDone: (isDone) {
                          isDone ? _installmentsMarkAsDone.add(ins) : _installmentsMarkAsDone.remove(ins);
                          setState(() {
                            widget.onMarkAsDone(_installmentsMarkAsDone, _totalUnpaid);
                          });
                        },
                      ),
                  ],
          ),
        ),
        Gap.divider(context, indent: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            'Total unpaid installment balance:',
            style: kHeader4TextStyle.copyWith(fontSize: 13, color: context.appTheme.onBackground),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            Gap.w4,
            Text(
              CalService.formatCurrency(context, _totalUnpaid),
              style: kHeader2TextStyle.copyWith(fontSize: 15, color: context.appTheme.onBackground),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            Gap.w4,
            Text(
              context.currentSettings.currency.code,
              style: kHeader3TextStyle.copyWith(fontSize: 15, color: context.appTheme.onBackground),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Gap.h4,
      ],
    );
  }
}

class _InstallmentDetails extends StatefulWidget {
  const _InstallmentDetails(this.transaction, this.monthsLeft, {required this.isDone, required this.onMarkAsDone});

  final CreditSpending transaction;
  final int monthsLeft;
  final bool isDone;
  final ValueChanged<bool> onMarkAsDone;

  @override
  State<_InstallmentDetails> createState() => _InstallmentDetailsState();
}

class _InstallmentDetailsState extends State<_InstallmentDetails> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: k150msDuration,
    lowerBound: 0.3,
    upperBound: 1,
    value: 1,
  );

  late bool _isDone = widget.isDone;

  @override
  void didUpdateWidget(covariant _InstallmentDetails oldWidget) {
    setState(() {
      _isDone = widget.isDone;
    });
    _isDone ? _animationController.reverse() : _animationController.forward();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? categoryTag = widget.transaction.categoryTag?.name;

    return Material(
      color: Colors.transparent,
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: _isDone ? null : () => context.push(RoutePath.transaction, extra: widget.transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (BuildContext context, Widget? child) {
                    return Opacity(
                      opacity: _animationController.value,
                      child: child,
                    );
                  },
                  child: Row(
                    children: [
                      TxnCategoryIcon(
                        transaction: widget.transaction,
                      ),
                      Gap.w4,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TxnCategoryName(
                              transaction: widget.transaction,
                              fontSize: 12,
                            ),
                            categoryTag != null
                                ? Text(
                                    categoryTag,
                                    style: kHeader3TextStyle.copyWith(
                                        fontSize: 11, color: context.appTheme.onBackground.withOpacity(0.7)),
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Gap.noGap,
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              TxnAmount(
                                currencyCode: context.currentSettings.currency.code,
                                transaction: widget.transaction,
                                fontSize: 12,
                                color: AppColors.grey(context),
                                showPaymentAmount: true,
                              ),
                              Text(
                                '/m'.hardcoded,
                                style: kHeader3TextStyle.copyWith(
                                    fontSize: 11, color: context.appTheme.onBackground.withOpacity(0.7)),
                              )
                            ],
                          ),
                          Text(
                            '${widget.monthsLeft.toString()} months left',
                            style: kHeader3TextStyle.copyWith(
                                fontSize: 11, color: context.appTheme.onBackground.withOpacity(0.7)),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Gap.w8,
              RoundedIconButton(
                iconPath: AppIcons.done,
                iconColor: _isDone ? context.appTheme.onPrimary : context.appTheme.onBackground,
                backgroundColor: _isDone ? context.appTheme.primary : AppColors.greyBgr(context),
                size: 27,
                iconPadding: 2,
                onTap: () {
                  setState(() {
                    _isDone = !_isDone;
                  });
                  _isDone ? _animationController.reverse() : _animationController.forward();
                  widget.onMarkAsDone(_isDone);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
