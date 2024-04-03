import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/transactions/domain/template_transaction.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/components/txn_components.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../../utils/constants.dart';
import '../../../data/template_transaction_repo.dart';

class AddTemplateTransactionModalScreen extends ConsumerWidget {
  const AddTemplateTransactionModalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateRepository = ref.watch(tempTransactionRepositoryRealmProvider);

    List<TemplateTransaction> templateTransactions = templateRepository.getTransactions();

    ref.watch(tempTransactionsChangesStreamProvider).whenData((_) {
      templateTransactions = templateRepository.getTransactions();
    });

    List<Widget> buildTemplateTiles(BuildContext context) {
      return templateTransactions.isNotEmpty
          ? List.generate(
              templateTransactions.length,
              (index) {
                TemplateTransaction model = templateTransactions[index];
                return _TemplateTransactionTile(model: model);
              },
            )
          : [
              IconWithText(
                iconPath: AppIcons.heartOutline,
                header: 'No template transaction',
              ),
            ];
    }

    return CustomSection(
      isWrapByCard: false,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      onReorder: (oldIndex, newIndex) => templateRepository.reorder(oldIndex, newIndex),
      sections: buildTemplateTiles(context),
    );
  }
}

class _TemplateTransactionTile extends StatelessWidget {
  const _TemplateTransactionTile({required this.model});

  final TemplateTransaction model;

  @override
  Widget build(BuildContext context) {
    final accountIcon = switch (model.type) {
      TransactionType.transfer => AppIcons.upload,
      TransactionType.income => AppIcons.download,
      TransactionType.expense => AppIcons.upload,
      TransactionType.creditPayment ||
      TransactionType.creditSpending ||
      TransactionType.creditCheckpoint ||
      TransactionType.installmentToPay =>
        null
    };

    final templateIcon = switch (model.type) {
      TransactionType.transfer => AppIcons.transfer,
      TransactionType.income => AppIcons.income,
      TransactionType.expense => AppIcons.expense,
      TransactionType.creditPayment ||
      TransactionType.creditSpending ||
      TransactionType.creditCheckpoint ||
      TransactionType.installmentToPay =>
        AppIcons.defaultIcon
    };

    final templateColor = switch (model.type) {
      TransactionType.transfer => AppColors.grey(context),
      TransactionType.income => context.appTheme.positive,
      TransactionType.expense => context.appTheme.negative,
      TransactionType.creditPayment ||
      TransactionType.creditSpending ||
      TransactionType.creditCheckpoint ||
      TransactionType.installmentToPay =>
        null
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        //onTap: () => context.push(RoutePath.accountScreen, extra: model.databaseObject.id.hexString),
        child: CardItem(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              model.note != null
                  ? Text(
                      model.note!,
                      style: kHeader4TextStyle.copyWith(
                        color: context.appTheme.onBackground,
                        fontSize: 12,
                      ),
                    )
                  : Gap.noGap,
              model.note != null ? Gap.divider(context) : Gap.noGap,
              Row(
                children: [
                  SvgIcon(
                    templateIcon,
                    color: templateColor,
                    size: 20,
                  ),
                  Gap.w8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Component(model.category?.iconPath, model.category?.name),
                        model.categoryTag?.name != null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 24.0),
                                child: Text(
                                  '# ${model.categoryTag!.name}',
                                  style: kHeader4TextStyle.copyWith(
                                    color: context.appTheme.onBackground,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : Gap.noGap,
                        Gap.h2,
                        _Component(accountIcon, model.account?.name),
                        model.type == TransactionType.transfer
                            ? _Component(AppIcons.download, model.toAccount?.name)
                            : Gap.noGap,
                      ],
                    ),
                  ),
                  model.amount != null ? MoneyAmount(amount: model.amount!, noAnimation: true) : Gap.noGap,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Component extends StatelessWidget {
  const _Component(this.iconPath, this.name, {super.key});
  final String? iconPath;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIcon(
          iconPath ?? AppIcons.defaultIcon,
          size: 15,
        ),
        Gap.w8,
        Text(
          name ?? 'Not specified',
          style: kHeader4TextStyle.copyWith(
            color: context.appTheme.onBackground.withOpacity(name == null ? 0.5 : 1),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
