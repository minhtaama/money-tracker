import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

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
  });

  final Statement? statement;

  @override
  Widget build(BuildContext context) {
    return CustomBox(
      child: statement != null
          ? _List(
              statement: statement!,
            )
          : Gap.noGap,
    );
  }
}

class _List extends StatefulWidget {
  const _List({required this.statement});

  final Statement statement;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  late List<Installment> _installmentsList = widget.statement.installments;

  List<_InstallmentDetails> buildTransactions() {
    final list = <_InstallmentDetails>[];

    for (int i = 0; i < _installmentsList.length; i++) {
      list.add(_InstallmentDetails(_installmentsList[i].txn, _installmentsList[i].monthsLeft));
    }

    return list;
  }

  @override
  void didUpdateWidget(covariant _List oldWidget) {
    setState(() {
      _installmentsList = widget.statement.installments;
    });
    super.didUpdateWidget(oldWidget);
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
            children: buildTransactions(),
          ),
        ),
      ],
    );
  }
}

class _InstallmentDetails extends StatelessWidget {
  const _InstallmentDetails(this.transaction, this.monthsLeft);

  final CreditSpending transaction;
  final int monthsLeft;

  @override
  Widget build(BuildContext context) {
    String? categoryTag = transaction.categoryTag?.name;

    return Material(
      color: Colors.transparent,
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePath.transaction, extra: transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              _DateTime(
                dateTime: transaction.dateTime,
              ),
              Gap.w4,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TxnCategoryIcon(
                      transaction: transaction,
                    ),
                    Gap.w4,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TxnCategoryName(
                            transaction: transaction,
                            fontSize: 12,
                          ),
                          categoryTag != null
                              ? Text(
                                  categoryTag,
                                  style: kHeader3TextStyle.copyWith(
                                      fontSize: 11,
                                      color: context.appTheme.backgroundNegative.withOpacity(0.7)),
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Gap.noGap,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              transaction.hasInstallment ? const TxnInstallmentIcon(size: 16) : Gap.noGap,
              Column(
                children: [
                  TxnAmount(
                    currencyCode: context.currentSettings.currency.code,
                    transaction: transaction,
                    fontSize: 13,
                    color: AppColors.grey(context),
                  ),
                  Text(
                    monthsLeft.toString(),
                    style: kHeader3TextStyle.copyWith(
                        fontSize: 11, color: context.appTheme.backgroundNegative.withOpacity(0.7)),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({this.dateTime});

  final DateTime? dateTime;

  @override
  Widget build(BuildContext context) {
    return dateTime != null
        ? Container(
            decoration: BoxDecoration(
              color: AppColors.greyBgr(context),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 20,
            constraints: const BoxConstraints(minHeight: 18),
            padding: const EdgeInsets.all(3),
            child: Center(
              child: Column(
                children: [
                  Text(
                    dateTime!.getFormattedDate(hasMonth: false, hasYear: false),
                    style: kHeader2TextStyle.copyWith(
                        color: context.appTheme.backgroundNegative, fontSize: 10, height: 1),
                  ),
                  Text(
                    dateTime!.getFormattedDate(hasDay: false, hasYear: false),
                    style: kHeader3TextStyle.copyWith(
                        color: context.appTheme.backgroundNegative, fontSize: 10, height: 1),
                  ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 6, right: 6),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyBgr(context),
                borderRadius: BorderRadius.circular(1000),
              ),
              height: 7,
              width: 7,
            ),
          );
  }
}
