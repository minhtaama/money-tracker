import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/animated_swipe_tile.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/scaffold_with_navigation_rail_shell.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/transactions/domain/template_transaction.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/add_model_screen/add_regular_txn_modal_screen.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../common_widgets/custom_inkwell.dart';
import '../../../../../utils/constants.dart';
import '../../../data/template_transaction_repo.dart';

class AddTemplateTransactionModalScreen extends ConsumerWidget {
  const AddTemplateTransactionModalScreen(this.controller, this.isScrollable, {super.key});

  final ScrollController controller;
  final bool isScrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateRepository = ref.watch(tempTransactionRepositoryRealmProvider);

    List<TemplateTransaction> templateTransactions = templateRepository.getTemplates();

    ref.watch(tempTransactionsChangesStreamProvider).whenData((_) {
      templateTransactions = templateRepository.getTemplates();
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
                iconPath: AppIcons.heartLight,
                forceIconOnTop: true,
                header: 'Empty'.hardcoded,
              ),
            ];
    }

    return ModalContent(
      controller: controller,
      isScrollable: isScrollable,
      header: ModalHeader(
        title: 'Favorite Transactions'.hardcoded,
        secondaryTitle: 'Hold to re-order'.hardcoded,
      ),
      body: buildTemplateTiles(context),
      onReorder: templateRepository.reorder,
      footer: Gap.noGap,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSwipeTile(
          buttons: [
            RoundedIconButton(
              iconPath: AppIcons.deleteBulk,
              size: 35,
              iconPadding: 6,
              elevation: 18,
              backgroundColor: context.appTheme.negative,
              iconColor: context.appTheme.onNegative,
              onTap: () => showConfirmModal(
                context: context,
                label: 'Delete this favorite transaction?'.hardcoded,
                onConfirm: () {
                  final tempRepo = ref.read(tempTransactionRepositoryRealmProvider);
                  tempRepo.delete(model);
                },
              ),
            ),
          ],
          child: CardItem(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            border: context.appTheme.isDarkTheme ? Border.all(color: AppColors.greyBorder(context)) : null,
            child: CustomInkWell(
              inkColor: AppColors.grey(context),
              onTap: () {
                context.pop();
                showCustomModal(
                  context: context,
                  builder: (controller, isScrollable) => Material(
                    type: MaterialType.transparency,
                    child: AddRegularTxnModalScreen(
                      controller,
                      isScrollable,
                      model.type,
                      template: model,
                    ),
                  ),
                );
              },
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
        ),
      ),
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
          AppIcons.transferLight,
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
  const _AccountIcon({required this.model});

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
