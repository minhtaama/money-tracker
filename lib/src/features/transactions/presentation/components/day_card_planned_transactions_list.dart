import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../common_widgets/hideable_container.dart';
import '../../../../common_widgets/icon_with_text_button.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../recurrence/data/recurrence_repo.dart';
import '../../../recurrence/domain/recurrence.dart';
import '../../../recurrence/presentation/transaction_data_tile.dart';

class DayCardPlannedTransactionsList extends StatelessWidget {
  const DayCardPlannedTransactionsList({
    super.key,
    required this.plannedTransactions,
    this.onPlannedTransactionTap,
  });

  final List<TransactionData> plannedTransactions;
  final void Function(TransactionData)? onPlannedTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        plannedTransactions.length,
        (index) => _Tile(model: plannedTransactions[index]),
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({required this.model});

  final TransactionData model;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _showButtons = false;

  @override
  Widget build(BuildContext context) {
    final onColor = widget.model.category?.iconColor ?? context.appTheme.onBackground;

    final color = switch (widget.model.type) {
      TransactionType.transfer => AppColors.grey(context),
      TransactionType.income => context.appTheme.positive,
      TransactionType.expense => context.appTheme.negative,
      TransactionType.creditPayment ||
      TransactionType.creditSpending ||
      TransactionType.creditCheckpoint ||
      TransactionType.installmentToPay =>
        AppColors.grey(context),
    };

    return TapRegion(
      onTapOutside: (_) => setState(() {
        _showButtons = false;
      }),
      child: AnimatedContainer(
        duration: k250msDuration,
        color: color.withOpacity(_showButtons ? 0.15 : 0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
                color.withOpacity(0),
                color.withOpacity(0),
                color.withOpacity(0.55),
                color.withOpacity(0.55),
              ],
              stops: const [0, 0.25, 0.99, 0.99, 0.99, 1],
            ),
          ),
          child: CustomInkWell(
            inkColor: color,
            onTap: () => setState(() {
              _showButtons = !_showButtons;
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  TransactionDataTile(
                    model: widget.model,
                    smaller: true,
                    withoutIconColor: true,
                    showState: true,
                    amountColor: context.appTheme.onBackground,
                  ),
                  HideableContainer(
                    hide: !_showButtons,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 5.0),
                      child: Consumer(
                        builder: (BuildContext context, WidgetRef ref, Widget? child) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: IconWithTextButton(
                                iconPath: AppIcons.addLight,
                                backgroundColor: color,
                                color: onColor,
                                label: context.loc.add,
                                labelSize: 12,
                                iconSize: 14,
                                width: 1,
                                height: 30,
                                onTap: () {
                                  setState(() {
                                    _showButtons = !_showButtons;
                                  });
                                  Future.delayed(k350msDuration, () {
                                    final recRepo = ref.read(recurrenceRepositoryRealmProvider);
                                    recRepo.addTransaction(ref, widget.model);
                                  });
                                },
                              ),
                            ),
                            Gap.w24,
                            Expanded(
                              child: IconWithTextButton(
                                iconPath: AppIcons.turnTwoTone,
                                backgroundColor: Colors.transparent,
                                color: context.appTheme.onBackground,
                                label: context.loc.skip,
                                border: Border.all(
                                  color: context.appTheme.onBackground,
                                ),
                                labelSize: 12,
                                iconSize: 14,
                                width: 1,
                                height: 30,
                                onTap: () {
                                  setState(() {
                                    _showButtons = !_showButtons;
                                  });
                                  Future.delayed(k350msDuration, () {
                                    final recRepo = ref.read(recurrenceRepositoryRealmProvider);
                                    recRepo.addSkipped(widget.model);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
