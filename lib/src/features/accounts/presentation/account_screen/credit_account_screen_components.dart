part of 'credit_account_screen.dart';

class _Header extends StatelessWidget {
  const _Header(
      {super.key,
      this.dateTime,
      required this.h1,
      this.h2,
      this.dateColor,
      this.dateBgColor,
      this.color});

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
                  style: kHeader2TextStyle.copyWith(
                      fontSize: 16, color: color ?? context.appTheme.onBackground),
                ),
                h2 != null
                    ? Text(
                        h2!,
                        style: kHeader3TextStyle.copyWith(
                            fontSize: 14, color: color ?? context.appTheme.onBackground),
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
        onTap: () => context.push(RoutePath.transaction, extra: transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _DateTime(
                dateTime: dateTime,
              ),
              Gap.w4,
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
    );
  }
}

class _InstallmentPayTransaction extends StatelessWidget {
  const _InstallmentPayTransaction({required this.transaction});
  final CreditSpending transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePath.transaction, extra: transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              const _DateTime(),
              Gap.w4,
              TxnCategoryIcon(
                transaction: transaction,
                color: context.appTheme.negative,
              ),
              Gap.w4,
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
        Gap.w4,
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
        Gap.w4,
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
        Gap.w4,
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
                              style: kHeader3TextStyle.copyWith(
                                  fontSize: 12, color: context.appTheme.onBackground),
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
                style: kHeader4TextStyle.copyWith(fontSize: 15, color: context.appTheme.onBackground),
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
              color: backgroundColor ?? AppColors.greyBgr(context),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 25,
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
