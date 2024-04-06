import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/transactions/domain/template_transaction.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
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
                forceIconOnTop: true,
                header: 'Empty'.hardcoded,
              ),
            ];
    }

    return CustomSection(
      isWrapByCard: false,
      sectionsClipping: false,
      title: 'Favorite Transactions'.hardcoded,
      subTitle: Text(
        'Hold to re-order'.hardcoded,
        style: kHeader4TextStyle.copyWith(
          fontSize: 13,
          color: context.appTheme.onBackground,
        ),
      ),
      margin: EdgeInsets.zero,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      onReorder: (oldIndex, newIndex) => templateRepository.reorder(oldIndex, newIndex),
      sections: buildTemplateTiles(context),
    );
  }
}

class _TemplateTransactionTile extends ConsumerWidget {
  const _TemplateTransactionTile({required this.model});

  final TemplateTransaction model;

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

    // final text = switch (model.type) {
    //   TransactionType.transfer => context.localize.transfer,
    //   TransactionType.income => context.localize.income,
    //   TransactionType.expense => context.localize.expense,
    //   TransactionType.creditPayment ||
    //   TransactionType.creditSpending ||
    //   TransactionType.creditCheckpoint ||
    //   TransactionType.installmentToPay =>
    //     '',
    // };

    return Stack(
      children: [
        CardItem(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.only(top: 2.0, left: 2.0),
          border: context.appTheme.isDarkTheme ? Border.all(color: AppColors.greyBorder(context)) : null,
          child: GestureDetector(
            // onTap: () => onTransactionTap?.call(transaction),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _CategoryIcon(model: model),
                      Gap.w8,
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
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-3, -3),
          child: RoundedIconButton(
            iconPath: AppIcons.close,
            size: 15,
            iconPadding: 3,
            backgroundColor: context.appTheme.negative,
            useContainerInsteadOfInk: true,
            iconColor: context.appTheme.onNegative,
            onTap: () => showConfirmModalBottomSheet(
              context: context,
              label: 'Delete this favorite transaction?'.hardcoded,
              onConfirm: () {
                final tempRepo = ref.read(tempTransactionRepositoryRealmProvider);
                tempRepo.delete(model);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.model});

  final TemplateTransaction model;

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
        color: model.category?.iconColor ?? context.appTheme.onBackground,
      );
    }

    return Container(
      height: 28,
      width: 28,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color(),
        borderRadius: BorderRadius.circular(100),
      ),
      child: child(),
    );
  }
}

class _AccountIcon extends ConsumerWidget {
  const _AccountIcon({super.key, required this.model});

  final TemplateTransaction model;

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

  final TemplateTransaction model;
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

  final TemplateTransaction model;

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

  final TemplateTransaction model;

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

  final TemplateTransaction model;

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

  final TemplateTransaction model;

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

  final TemplateTransaction model;

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
