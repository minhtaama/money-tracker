import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/animated_swipe_tile.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/recurrence/data/recurrence_repo.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/modal_and_dialog.dart';
import '../../../common_widgets/rounded_icon_button.dart';
import '../../../theme_and_ui/colors.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../domain/recurrence.dart';
import 'transaction_data_tile.dart';

class PlannedTransactionsModalScreen extends ConsumerWidget {
  const PlannedTransactionsModalScreen(this.controller, this.isScrollable, {super.key, required this.dateTime});

  final ScrollController controller;
  final bool isScrollable;
  final DateTime dateTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    List<TransactionData> plannedTxns = recRepo.getPlannedTransactionsInMonth(context, dateTime);

    ref.watch(recurrenceChangesStreamProvider).whenData((_) {
      plannedTxns = recRepo.getPlannedTransactionsInMonth(context, dateTime);
    });

    return ModalContent(
      header: ModalHeader(
        title: 'Planned transactions'.hardcoded,
        secondaryTitle: dateTime.toLongDate(context),
      ),
      body: _buildDays(context, ref, plannedTxns),
      footer: Gap.noGap,
    );
  }

  List<Widget> _buildDays(BuildContext context, WidgetRef ref, List<TransactionData> plannedTransactions) {
    Widget swipeTile(TransactionData txn) => AnimatedSwipeTile(
          buttons: [
            RoundedIconButton(
              iconPath: AppIcons.delete,
              size: 38,
              iconPadding: 6,
              elevation: 18,
              backgroundColor: context.appTheme.negative,
              iconColor: context.appTheme.onNegative,
              onTap: () => showConfirmModal(
                context: context,
                label: 'Delete this transaction?'.hardcoded,
                subLabel: 'All related transactions will be deleted, too.'.hardcoded,
                onConfirm: () {
                  final repo = ref.read(recurrenceRepositoryRealmProvider);
                  repo.delete(txn.recurrence);
                },
              ),
            ),
            Gap.w12,
          ],
          child: _Tile(model: txn),
        );

    final result = <Widget>[];

    final upcomingTxns = plannedTransactions.where((e) => e.state == PlannedState.upcoming).toList().reversed;

    result.add(
      TextHeader(
        'Upcoming transactions'.hardcoded,
        fontSize: 12,
      ),
    );

    for (TransactionData txn in upcomingTxns) {
      result.add(swipeTile(txn));
    }

    final todayTxns = plannedTransactions.where((e) => e.state == PlannedState.today).toList().reversed;

    result.add(
      TextHeader(
        context.loc.today,
        fontSize: 12,
      ),
    );

    for (TransactionData txn in todayTxns) {
      result.add(swipeTile(txn));
    }

    final overdueTxns = plannedTransactions.where((e) => e.state == PlannedState.overdue).toList().reversed;

    result.add(
      TextHeader(
        'Overdue'.hardcoded,
        fontSize: 12,
      ),
    );

    for (TransactionData txn in overdueTxns) {
      result.add(swipeTile(txn));
    }

    return result;
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
    final color = widget.model.category?.backgroundColor ?? AppColors.greyBgr(context);
    final onColor = widget.model.category?.iconColor ?? context.appTheme.onBackground;

    return TapRegion(
      onTapOutside: (_) => setState(() {
        _showButtons = false;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: CardItem(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          border: Border.all(
            color: color.withOpacity(widget.model.state == PlannedState.today ? 0.65 : 0),
          ),
          color: color.withOpacity(context.appTheme.isDarkTheme ? 0.1 : 0.2),
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
                    withoutIconColor: true,
                    showDateTime: true,
                  ),
                  HideableContainer(
                      hide: !_showButtons,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.model.recurrence.expression(context),
                                style: kHeader4TextStyle.copyWith(
                                  color: context.appTheme.onBackground,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: IconWithTextButton(
                                    iconPath: AppIcons.add,
                                    backgroundColor: color,
                                    color: onColor,
                                    label: 'Add'.hardcoded,
                                    labelSize: 12,
                                    iconSize: 14,
                                    width: 1,
                                    height: 30,
                                    onTap: () {},
                                  ),
                                ),
                                Gap.w24,
                                Expanded(
                                  child: IconWithTextButton(
                                    iconPath: AppIcons.turn,
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
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
