part of '../credit_details.dart';

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.statement, required this.isClosedStatement});

  final Statement statement;
  final bool isClosedStatement;

  Widget _buildText(BuildContext context, {String? text, String? richText, int color = 0, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          text != null
              ? Expanded(
                  child: Text(
                    text,
                    style: bold
                        ? kHeader2TextStyle.copyWith(
                            color: context.appTheme.onBackground.withOpacity(0.9),
                            fontSize: 18,
                          )
                        : kHeader3TextStyle.copyWith(
                            color: context.appTheme.onBackground.withOpacity(0.75),
                            fontSize: 15,
                          ),
                  ),
                )
              : Gap.noGap,
          richText != null
              ? EasyRichText(
                  richText,
                  defaultStyle: kHeader3TextStyle.copyWith(
                    color: color < 0
                        ? context.appTheme.negative
                        : color > 0
                            ? context.appTheme.positive
                            : context.appTheme.isDarkTheme
                                ? context.appTheme.onBackground
                                : context.appTheme.onSecondary,
                    fontSize: bold ? 18 : 15,
                  ),
                  textAlign: TextAlign.right,
                  patternList: [
                    EasyRichTextPattern(
                      targetString: '.',
                      hasSpecialCharacters: true,
                      style: kHeader1TextStyle.copyWith(
                        color: color < 0
                            ? context.appTheme.negative
                            : color > 0
                                ? context.appTheme.positive
                                : context.appTheme.isDarkTheme
                                    ? context.appTheme.onBackground
                                    : context.appTheme.onSecondary,
                        fontSize: 15,
                      ),
                    ),
                    EasyRichTextPattern(
                      targetString: ',',
                      hasSpecialCharacters: true,
                      style: kHeader1TextStyle.copyWith(
                        color: color < 0
                            ? context.appTheme.negative
                            : color > 0
                                ? context.appTheme.positive
                                : context.appTheme.isDarkTheme
                                    ? context.appTheme.onBackground
                                    : context.appTheme.onSecondary,
                        fontSize: 15,
                      ),
                    ),
                    EasyRichTextPattern(
                      targetString: '[0-9]+',
                      style: kHeader1TextStyle.copyWith(
                        color: color < 0
                            ? context.appTheme.negative
                            : color > 0
                                ? context.appTheme.positive
                                : context.appTheme.isDarkTheme
                                    ? context.appTheme.onBackground
                                    : context.appTheme.onSecondary,
                        fontSize: bold ? 18 : 15,
                      ),
                    ),
                  ],
                )
              : Gap.noGap,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
      child: statement.checkpoint == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isClosedStatement
                    ? IconWithText(
                        iconPath: AppIcons.done,
                        iconSize: 30,
                        header: 'This statement has been closed'.hardcoded,
                      )
                    : Gap.noGap,
                isClosedStatement ? Gap.h16 : Gap.noGap,
                _buildText(
                  context,
                  text: 'Carrying-over:',
                  richText: '${carryString(context, statement)} ${context.appSettings.currency.code}',
                  color: carry.roundBySetting(context) <= 0 ? 0 : -1,
                ),
                statement.carry.interest > 0
                    ? _buildText(
                        context,
                        text: 'Interest:',
                        richText: '~ ${interestString(context, statement)} ${context.appSettings.currency.code}',
                        color: interest.roundBySetting(context) <= 0 ? 0 : -1,
                      )
                    : Gap.noGap,
                _buildText(
                  context,
                  text: 'Spent in billing cycle:',
                  richText: '${spentString(context, statement)} ${context.appSettings.currency.code}',
                  color: spent.roundBySetting(context) <= 0 ? 0 : -1,
                ),
                _buildText(
                  context,
                  text: 'Paid for statement:',
                  richText: '${paidString(context, statement)} ${context.appSettings.currency.code}',
                  color: paid.roundBySetting(context) <= 0 ? 0 : 1,
                ),
                Gap.h8,
                _buildText(
                  context,
                  text: 'Balance:',
                  bold: true,
                  richText: '${balanceString(context, statement)} ${context.appSettings.currency.code}',
                  color: balance.roundBySetting(context) <= 0 ? 0 : -1,
                ),
              ],
            )
          : Column(
              children: [
                IconWithText(
                  iconPath: AppIcons.statementCheckpoint,
                  iconSize: 30,
                  header: 'This statement has checkpoint',
                ),
                Gap.h16,
                _buildText(
                  context,
                  text: 'Spent at checkpoint:',
                  richText: '${spentString(context, statement)} ${context.appSettings.currency.code}',
                  color: spent <= 0 ? 0 : -1,
                ),
                _buildText(
                  context,
                  text: 'Paid in grace period:',
                  richText: '${paidString(context, statement)} ${context.appSettings.currency.code}',
                  color: paid <= 0 ? 0 : 1,
                ),
                Gap.h4,
                _buildText(
                  context,
                  bold: true,
                  text: 'Statement balance:',
                  richText: '${balanceString(context, statement)} ${context.appSettings.currency.code}',
                  color: balance <= 0 ? 0 : -1,
                ),
              ],
            ),
    );
  }
}

extension _StatementDetails on _SummaryCard {
  double get interest => statement.carry.interest;
  double get carry => statement.carry.balanceToPay;
  double get spent => statement.spent.inBillingCycle.toPay + statement.installmentsToPay;
  double get paid => statement.paid;
  double get balance => statement.balance;

  String? interestString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, interest);
  }

  String? carryString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, carry);
  }

  String? spentString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, spent);
  }

  String? paidString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, paid);
  }

  String? balanceString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, math.max(0, balance));
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key, this.dateTime, required this.h1, this.h2, this.dateColor, this.dateBgColor, this.color});

  final DateTime? dateTime;
  final Color? dateColor;
  final Color? color;
  final Color? dateBgColor;
  final String h1;
  final String? h2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _DateTime(
            dateTime: dateTime,
            color: dateColor,
            backgroundColor: dateBgColor ?? color,
            noMonth: false,
          ),
          Gap.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h1,
                  style: kHeader2TextStyle.copyWith(fontSize: 16, color: color ?? context.appTheme.onBackground),
                ),
                h2 != null
                    ? Text(
                        h2!,
                        style: kHeader3TextStyle.copyWith(fontSize: 14, color: color ?? context.appTheme.onBackground),
                      )
                    : Gap.noGap,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Transaction extends StatelessWidget {
  const _Transaction({super.key, required this.statement, required this.transaction, this.dateTime});
  final Statement statement;
  final DateTime? dateTime;
  final BaseCreditTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePath.transaction, extra: transaction.databaseObject.id.hexString),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _DateTime(
                dateTime: dateTime,
              ),
              Gap.w4,
              Expanded(
                child: CardItem(
                  margin: const EdgeInsets.only(left: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  elevation: 0.7,
                  child: Row(
                    children: [
                      Expanded(
                        child: _Details(
                          transaction: transaction,
                          statement: statement,
                        ),
                      ),
                      transaction is! CreditCheckpoint
                          ? TxnAmount(
                              currencyCode: context.appSettings.currency.code,
                              transaction: transaction,
                              fontSize: 15,
                              color: transaction is CreditSpending
                                  ? (transaction as CreditSpending).hasInstallment
                                      ? AppColors.grey(context)
                                      : context.appTheme.negative
                                  : context.appTheme.positive,
                            )
                          : Gap.noGap,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstallmentToPayTransaction extends StatelessWidget {
  const _InstallmentToPayTransaction({required this.transaction});
  final CreditSpending transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          RoutePath.transaction,
          extra: (
            string: transaction.databaseObject.id.hexString,
            type: TransactionScreenType.installmentToPay,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              const _DateTime(),
              Gap.w4,
              Expanded(
                child: CardItem(
                  margin: const EdgeInsets.only(left: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  elevation: 0.7,
                  child: Row(
                    children: [
                      TxnCategoryIcon(
                        transaction: transaction,
                        color: context.appTheme.negative,
                      ),
                      Gap.w8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instm. payment of:',
                              style: kHeader3TextStyle.copyWith(fontSize: 12, color: AppColors.grey(context)),
                            ),
                            TxnCategoryName(
                              transaction: transaction,
                              fontSize: 14,
                            )
                          ],
                        ),
                      ),
                      Gap.w4,
                      TxnAmount(
                        currencyCode: context.appSettings.currency.code,
                        transaction: transaction,
                        showPaymentAmount: true,
                        color: context.appTheme.negative,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.transaction, required this.statement});

  final BaseCreditTransaction transaction;
  final Statement statement;

  String? get _categoryTag {
    final txn = transaction;
    switch (txn) {
      case CreditSpending():
        return txn.categoryTag != null ? '#${txn.categoryTag!.name}' : null;
      case CreditPayment() || CreditCheckpoint():
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (transaction) {
      CreditSpending() => _Spending(
          transaction: transaction as CreditSpending,
          categoryTag: _categoryTag,
        ),
      CreditPayment() => _Payment(transaction: transaction as CreditPayment),
      CreditCheckpoint() => _Checkpoint(
          transaction: transaction as CreditCheckpoint,
          statement: statement,
        ),
    };
  }
}

class _Spending extends StatelessWidget {
  const _Spending({required this.transaction, this.categoryTag});

  final CreditSpending transaction;
  final String? categoryTag;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TxnCategoryIcon(
          transaction: transaction,
          color: transaction.hasInstallment ? null : context.appTheme.negative,
        ),
        Gap.w8,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TxnCategoryName(
                transaction: transaction,
                fontSize: 14,
              ),
              categoryTag != null
                  ? Text(
                      categoryTag!,
                      style: kHeader3TextStyle.copyWith(
                          fontSize: 13, color: context.appTheme.onBackground.withOpacity(0.7)),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Gap.noGap,
            ],
          ),
        ),
        transaction.hasInstallment ? const TxnInstallmentIcon() : Gap.noGap,
        Gap.w4,
      ],
    );
  }
}

class _Payment extends StatelessWidget {
  const _Payment({required this.transaction});

  final CreditPayment transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgIcon(
          AppIcons.receiptCheck,
          color: context.appTheme.positive,
          size: 20,
        ),
        Gap.w8,
        Expanded(
          child: Text(
            'Payment'.hardcoded,
            style: kHeader3TextStyle.copyWith(fontSize: 15, color: context.appTheme.onBackground),
          ),
        ),
        TxnAdjustmentIcon(transaction: transaction),
        Gap.w4,
      ],
    );
  }
}

class _Checkpoint extends StatelessWidget {
  const _Checkpoint({required this.transaction, required this.statement});

  final CreditCheckpoint transaction;
  final Statement statement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgIcon(
          AppIcons.statementCheckpoint,
          color: context.appTheme.onBackground,
          size: 20,
        ),
        Gap.w8,
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oustd. balance: ${statement.checkpoint!.unpaidOfInstallments != 0 ? CalService.formatCurrency(context, transaction.amount) : ''} ${statement.checkpoint!.unpaidOfInstallments != 0 ? context.appSettings.currency.code : ''}'
                            .hardcoded,
                        style: kHeader3TextStyle.copyWith(
                            fontSize: statement.checkpoint!.unpaidOfInstallments != 0 ? 12 : 15,
                            color: context.appTheme.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      statement.checkpoint!.unpaidOfInstallments != 0
                          ? Text(
                              'Inst. left: ${CalService.formatCurrency(context, statement.checkpoint!.unpaidOfInstallments)} ${context.appSettings.currency.code}'
                                  .hardcoded,
                              style: kHeader3TextStyle.copyWith(fontSize: 12, color: context.appTheme.onBackground),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                            )
                          : Gap.noGap,
                    ],
                  ),
                ),
              ),
              const FittedBox(child: _CheckpointArrow()),
              Text(
                CalService.formatCurrency(context, statement.checkpoint!.unpaidToPay).hardcoded,
                style: kHeader2TextStyle.copyWith(fontSize: 15, color: context.appTheme.onBackground),
              ),
              Gap.w4,
              Text(
                context.appSettings.currency.code.hardcoded,
                style: kNormalTextStyle.copyWith(fontSize: 15, color: context.appTheme.onBackground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({this.dateTime, this.backgroundColor, this.color, this.noMonth = true});

  final DateTime? dateTime;
  final bool noMonth;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return dateTime != null
        ? Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.greyBorder(context),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 26,
            constraints: const BoxConstraints(minHeight: 18),
            padding: const EdgeInsets.all(3),
            child: Center(
              child: Column(
                children: [
                  Text(
                    dateTime!.getFormattedDate(hasMonth: false, hasYear: false),
                    style: kHeader2TextStyle.copyWith(
                        color: color ?? context.appTheme.onBackground, fontSize: 14, height: 1),
                  ),
                  noMonth
                      ? Gap.noGap
                      : Text(
                          dateTime!.getFormattedDate(hasDay: false, hasYear: false),
                          style: kHeader3TextStyle.copyWith(
                              color: color ?? context.appTheme.onBackground, fontSize: 14, height: 1),
                        ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 7.5, right: 8.5),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColors.greyBorder(context),
                borderRadius: BorderRadius.circular(1000),
              ),
              height: 10,
              width: 10,
            ),
          );
  }
}

class _CheckpointArrow extends StatelessWidget {
  const _CheckpointArrow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        SvgIcon(
          AppIcons.arrowRight,
          color: context.appTheme.onBackground,
          size: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 15,
            height: 1.5,
            color: context.appTheme.onBackground,
          ),
        ),
      ],
    );
  }
}
