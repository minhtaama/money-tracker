import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/statement/base_class/statement.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_widget.dart';
import 'package:money_tracker_app/src/features/recurrence/data/recurrence_repo.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../common_widgets/money_amount.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../utils/constants.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../recurrence/domain/recurrence.dart';
import '../../../recurrence/presentation/transaction_data_tile.dart';

class UpcomingWidget extends ConsumerWidget {
  const UpcomingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    final accountRepo = ref.watch(accountRepositoryProvider);

    final today = DateTime.now();

    final creditAccountList = accountRepo.getList(AccountType.credit).whereType<CreditAccount>();

    final recList =
        recRepo.getRecurrences().where((rec) => rec.getAllPlannedTransactionsInMonth(context, today).isNotEmpty);

    return DashboardWidget(
      title: 'Upcoming'.hardcoded,
      isEmpty: creditAccountList.isEmpty && recList.isEmpty,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (CreditAccount account in creditAccountList)
                _creditPayment(
                  context,
                  account: account,
                  currentDateTime: today,
                ),
              creditAccountList.isNotEmpty && recList.isNotEmpty
                  ? Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Gap.divider(context, indent: 20))
                  : Gap.noGap,
              for (Recurrence rec in recList)
                _tile(
                  context,
                  model: rec.transactionData,
                  repeatOn: rec.getAllPlannedTransactionsInMonth(context, today).map((e) => e.dateTime!).toList(),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, {required TransactionData model, required List<DateTime> repeatOn}) {
    if (repeatOn.isEmpty) {
      return Gap.noGap;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: CardItem(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              border: Border.all(
                color: (model.type == TransactionType.income
                        ? context.appTheme.positive
                        : model.type == TransactionType.expense
                            ? context.appTheme.negative
                            : context.appTheme.onBackground)
                    .withOpacity(0.65),
              ),
              color: (model.type == TransactionType.income
                      ? context.appTheme.positive
                      : model.type == TransactionType.expense
                          ? context.appTheme.negative
                          : context.appTheme.onBackground)
                  .withOpacity(0.075),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: TransactionDataTile(
                  model: model,
                  withoutIconColor: true,
                ),
              ),
            ),
          ),
          Gap.w4,
          Text(
            '×',
            style: kHeader4TextStyle.copyWith(
              fontSize: 22,
              color: (model.type == TransactionType.income
                      ? context.appTheme.positive
                      : model.type == TransactionType.expense
                          ? context.appTheme.negative
                          : context.appTheme.onBackground)
                  .withOpacity(0.85),
            ),
          ),
          Gap.w4,
          Text(
            repeatOn.length.toString(),
            style: kHeader2TextStyle.copyWith(
              fontSize: 20,
              color: (model.type == TransactionType.income
                      ? context.appTheme.positive
                      : model.type == TransactionType.expense
                          ? context.appTheme.negative
                          : context.appTheme.onBackground)
                  .withOpacity(0.85),
            ),
          ),
          Gap.w4,
        ],
      ),
    );
  }

  Widget _creditPayment(BuildContext context, {required CreditAccount account, required DateTime currentDateTime}) {
    final currentStatement = account.statementAt(currentDateTime, upperGapAtDueDate: true);

    if (currentStatement == null) {
      return Gap.noGap;
    }

    final balance = currentStatement.balance;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: CardItem(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              border: Border.all(
                color: account.backgroundColor.withOpacity(0.65),
              ),
              color: account.backgroundColor.withOpacity(0.075),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    SvgIcon(
                      account.iconPath,
                      color: context.appTheme.onBackground,
                      size: 25,
                    ),
                    Gap.w8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment for:'.hardcoded,
                            style: kHeader3TextStyle.copyWith(
                              fontSize: 11,
                              color: context.appTheme.onBackground.withOpacity(0.65),
                            ),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                          Text(
                            account.name,
                            style: kHeader3TextStyle.copyWith(
                              fontSize: 13,
                              color: context.appTheme.onBackground,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    MoneyAmount(
                      amount: balance,
                      noAnimation: true,
                      style: kHeader2TextStyle.copyWith(
                        color: balance > 0 ? context.appTheme.negative : context.appTheme.onBackground,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Gap.w8,
          _DateTime(
            statement: currentStatement,
            backgroundColor: account.backgroundColor,
            color: account.iconColor,
          ),
        ],
      ),
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({required this.statement, this.backgroundColor, this.color});

  final Statement statement;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          statement.date.statement.toShortDate(context, noYear: true),
          style: kHeader3TextStyle.copyWith(
            fontSize: 10,
            color: context.appTheme.onBackground.withOpacity(0.65),
            height: 0.99,
          ),
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        Text(
          "-",
          style: kHeader3TextStyle.copyWith(
            fontSize: 11,
            color: context.appTheme.onBackground.withOpacity(0.65),
            height: 0.8,
          ),
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        Text(
          statement.date.due.toShortDate(context, noYear: true),
          style: kHeader3TextStyle.copyWith(
            fontSize: 10,
            color: context.appTheme.onBackground.withOpacity(0.65),
            height: 0.8,
          ),
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      ],
    );
  }
}
