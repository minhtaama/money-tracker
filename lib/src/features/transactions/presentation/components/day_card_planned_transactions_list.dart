import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../common_widgets/hideable_container.dart';
import '../../../../common_widgets/icon_with_text_button.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
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
  const _Tile({super.key, required this.model});

  final TransactionData model;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _showButtons = false;

  @override
  Widget build(BuildContext context) {
    // final color = widget.model.type == TransactionType.income
    //     ? context.appTheme.positive
    //     : widget.model.type == TransactionType.expense
    //         ? context.appTheme.negative
    //         : context.appTheme.onBackground;

    final color = widget.model.category?.backgroundColor ?? AppColors.greyBgr(context);
    final onColor = widget.model.category?.iconColor ?? context.appTheme.onBackground;

    return TapRegion(
      onTapOutside: (_) => setState(() {
        _showButtons = false;
      }),
      child: CardItem(
        borderRadius: BorderRadius.circular(12),
        // margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        color: color.withOpacity(_showButtons ? 0.1 : 0.0),
        child: CustomInkWell(
          inkColor: color,
          onTap: () => setState(() {
            _showButtons = !_showButtons;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            child: Column(
              children: [
                TransactionDataTile(
                  model: widget.model,
                  smaller: true,
                  withoutIconColor: true,
                  showState: true,
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
                              label: 'Add'.hardcoded,
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
                              label: 'Skip'.hardcoded,
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
    );
  }
}
