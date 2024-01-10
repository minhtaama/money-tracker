import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/txn_components.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/custom_section.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../category/domain/category.dart';
import '../../domain/transaction_base.dart';

class TransactionDetailsModalScreen extends ConsumerWidget {
  const TransactionDetailsModalScreen({super.key, required this.transaction});

  final BaseTransaction transaction;

  String get _title {
    return switch (transaction) {
      Income() => (transaction as Income).isInitialTransaction ? 'Initial Balance'.hardcoded : 'Income'.hardcoded,
      Expense() => 'Expense'.hardcoded,
      Transfer() => 'Transfer'.hardcoded,
      CreditSpending() => 'Credit Spending'.hardcoded,
      CreditPayment() => 'Credit Payment'.hardcoded,
      CreditCheckpoint() => 'Credit Checkpoint'.hardcoded,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountRepo = ref.watch(accountRepositoryProvider);

    return CustomSection(
      title: _title,
      subTitle: _DateTime(transaction: transaction),
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(transaction: transaction),
        Gap.h8,
        transaction is CreditSpending ? Gap.h8 : Gap.noGap,
        Gap.divider(context, indent: 6),
        Row(
          children: [
            transaction is Transfer
                ? const TxnTransferLine(
                    height: 100,
                    width: 30,
                    strokeWidth: 1.5,
                    opacity: 0.5,
                  )
                : Gap.noGap,
            transaction is Transfer ? Gap.w4 : Gap.noGap,
            Expanded(
              child: Column(
                children: [
                  _AccountCard(model: transaction.account!),
                  switch (transaction) {
                    IBaseTransactionWithCategory() =>
                      transaction is Income && (transaction as Income).isInitialTransaction
                          ? Gap.noGap
                          : _CategoryCard(
                              model: (transaction as IBaseTransactionWithCategory).category!,
                              categoryTag: (transaction as IBaseTransactionWithCategory).categoryTag,
                            ),
                    Transfer() => _AccountCard(model: (transaction as Transfer).transferAccount!),
                    CreditPayment() || CreditCheckpoint() => Gap.noGap,
                  },
                ],
              ),
            ),
          ],
        ),
        transaction.note != null ? _Note(note: transaction.note!) : Gap.noGap,
        Gap.h16,
      ],
    );
  }
}

class _Amount extends ConsumerWidget {
  const _Amount({required this.transaction});

  final BaseTransaction transaction;

  String get _iconPath {
    return switch (transaction) {
      Income() => AppIcons.download,
      Expense() => AppIcons.upload,
      Transfer() => AppIcons.transfer,
      CreditSpending() => AppIcons.upload,
      CreditPayment() => AppIcons.upload,
      CreditCheckpoint() => AppIcons.transfer
    };
  }

  Color _color(BuildContext context) {
    return switch (transaction) {
      Income() => context.appTheme.positive,
      Expense() => context.appTheme.negative,
      Transfer() => context.appTheme.onBackground,
      CreditSpending() => context.appTheme.negative,
      CreditPayment() => context.appTheme.negative,
      CreditCheckpoint() => AppColors.grey(context),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CardItem(
          height: 50,
          width: 50,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: EdgeInsets.zero,
          color: _color(context).withOpacity(0.2),
          borderRadius: BorderRadius.circular(1000),
          child: FittedBox(
            child: SvgIcon(
              _iconPath,
              color: _color(context),
            ),
          ),
        ),
        Gap.w16,
        Expanded(
          child: Row(
            children: [
              Text(
                CalService.formatCurrency(context, transaction.amount),
                style: kHeader1TextStyle.copyWith(
                  color: _color(context),
                ),
              ),
              Gap.w8,
              Text(
                context.appSettings.currency.code,
                style: kHeader4TextStyle.copyWith(color: _color(context), fontSize: kHeader1TextStyle.fontSize),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({required this.transaction});

  final BaseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Row(
        children: [
          Text(
            '${transaction.dateTime.hour}:${transaction.dateTime.minute}',
            style:
                kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: kHeader4TextStyle.fontSize),
          ),
          Gap.w8,
          Text(
            transaction.dateTime.getFormattedDate(format: DateTimeFormat.mmmmddyyyy),
            style: kHeader4TextStyle.copyWith(
              color: context.appTheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.model});
  final Account model;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: model.backgroundColor.addDark(context.appTheme.isDarkTheme ? 0.2 : 0.0),
      constraints: const BoxConstraints(minHeight: 65, minWidth: double.infinity),
      child: Stack(
        children: [
          Positioned(
            right: 1.0,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(-120.0, -30.0)
                ..scale(7.0),
              child: Opacity(
                opacity: 0.25,
                child: SvgIcon(model.iconPath),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                model is CreditAccount ? 'CREDIT ACCOUNT:' : 'ACCOUNT:',
                style: kHeader2TextStyle.copyWith(color: model.iconColor.withOpacity(0.6), fontSize: 11),
              ),
              Gap.h4,
              IntrinsicWidth(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        model.name,
                        style: kHeader2TextStyle.copyWith(color: model.iconColor, fontSize: 20),
                      ),
                    ),
                    Gap.w48,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.model, this.categoryTag});
  final Category model;
  final CategoryTag? categoryTag;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: context.appTheme.isDarkTheme ? model.backgroundColor.addDark(0.62) : model.backgroundColor.addWhite(0.7),
      elevation: 1,
      constraints: const BoxConstraints(minHeight: 65, minWidth: double.infinity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATEGORY:',
            style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 11),
          ),
          Gap.h8,
          Row(
            children: [
              RoundedIconButton(
                iconPath: model.iconPath,
                size: 50,
                iconPadding: 7,
                backgroundColor: model.backgroundColor,
                iconColor: model.iconColor,
              ),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      model.name,
                      style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 20),
                    ),
                    categoryTag != null
                        ? Text(
                            '# ${categoryTag!.name}',
                            style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 15),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      border: Border.all(color: context.appTheme.onBackground.withOpacity(0.5)),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTE:',
            style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 11),
          ),
          Gap.h4,
          Text(
            note,
            style: kHeader4TextStyle.copyWith(
              color: context.appTheme.onBackground,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
