import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tile.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/custom_section.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../domain/transaction.dart';

class TransactionDetails extends ConsumerWidget {
  const TransactionDetails({super.key, required this.transaction});

  final Transaction transaction;

  String get _title {
    return switch (transaction) {
      Income() => 'Income'.hardcoded,
      Expense() => 'Expense'.hardcoded,
      Transfer() => 'Transfer'.hardcoded,
      CreditSpending() => 'Credit Spending'.hardcoded,
      CreditPayment() => 'Credit Payment'.hardcoded,
    };
  }

  String get _iconPath {
    return switch (transaction) {
      Income() => AppIcons.download,
      Expense() => AppIcons.upload,
      Transfer() => AppIcons.transfer,
      CreditSpending() => AppIcons.upload,
      CreditPayment() => AppIcons.upload,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsObject = ref.read(settingsControllerProvider);

    return CustomSection(
      title: _title,
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CardItem(
              height: 50,
              width: 50,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: EdgeInsets.zero,
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(1000),
              child: FittedBox(
                child: SvgIcon(_iconPath),
              ),
            ),
            Gap.w16,
            Expanded(
              child: Text(
                '${CalculatorService.formatCurrency(transaction.amount)}  ${settingsObject.currency.code}',
                style: kHeader1TextStyle.copyWith(
                  color: context.appTheme.backgroundNegative,
                ),
              ),
            ),
          ],
        ),
        Gap.h8,
        Gap.divider(context),
        _ItemDisplay(model: transaction.account!),
        switch (transaction) {
          TransactionWithCategory() => _ItemDisplay(
              model: (transaction as TransactionWithCategory).category!,
              categoryTag: (transaction as TransactionWithCategory).categoryTag,
            ),
          Transfer() => Gap.noGap,
          CreditPayment() => Gap.noGap,
        },
        transaction.note != null ? _Note(note: transaction.note!) : Gap.noGap,
        Gap.h16,
      ],
    );
  }
}

class _ItemDisplay extends StatelessWidget {
  const _ItemDisplay({required this.model, this.categoryTag});
  final IsarModelWithIcon model;
  final CategoryTag? categoryTag;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                model is Account
                    ? (model as Account).type == AccountType.credit
                        ? 'CREDIT ACCOUNT:'
                        : 'ACCOUNT:'
                    : 'CATEGORY:',
                style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.backgroundNegative.withOpacity(0.6), fontSize: 11),
              ),
              Gap.h4,
              IntrinsicWidth(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        model.name,
                        style: kHeader2TextStyle.copyWith(color: model.color, fontSize: 20),
                      ),
                    ),
                    Gap.w48,
                  ],
                ),
              ),
              categoryTag != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: model.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '# ${categoryTag!.name}',
                        style: kHeader4TextStyle.copyWith(color: model.backgroundColor, fontSize: 13),
                      ),
                    )
                  : const SizedBox(),
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
    return Container(
      margin: const EdgeInsets.only(left: 4, top: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: context.appTheme.backgroundNegative.withOpacity(0.4), width: 10)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        constraints: const BoxConstraints(minHeight: 50, minWidth: double.infinity),
        decoration: BoxDecoration(
          color: context.appTheme.backgroundNegative.withOpacity(0.07),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOTE:',
              style:
                  kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative.withOpacity(0.6), fontSize: 11),
            ),
            Gap.h4,
            Text(
              note,
              style: kHeader4TextStyle.copyWith(
                color: context.appTheme.backgroundNegative,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
