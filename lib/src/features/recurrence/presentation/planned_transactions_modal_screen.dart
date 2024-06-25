import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/animated_swipe_tile.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
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
        secondaryTitle: dateTime.toLongDate(context, noDay: true),
      ),
      body: _buildDays(context, ref, plannedTxns),
      footer: Gap.noGap,
    );
  }

  Widget _empty(BuildContext context) {
    return CardItem(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 50,
      width: double.infinity,
      border: Border.all(
        color: AppColors.greyBorder(context),
      ),
      child: Center(
        child: Text(
          'No transactions'.hardcoded,
          style: kNormalTextStyle.copyWith(color: AppColors.grey(context)),
        ),
      ),
    );
  }

  List<Widget> _buildDays(BuildContext context, WidgetRef ref, List<TransactionData> plannedTransactions) {
    final result = <Widget>[];

    final upcomingTxns = plannedTransactions.where((e) => e.state == PlannedState.upcoming).toList().reversed;

    result.add(
      TextHeader(
        'Upcoming transactions'.hardcoded,
        fontSize: 12,
      ),
    );

    if (upcomingTxns.isEmpty) {
      result.add(_empty(context));
    }

    for (TransactionData txn in upcomingTxns) {
      result.add(
        _Tile(key: ValueKey(txn.dateTime), model: txn),
      );
    }

    final todayTxns = plannedTransactions.where((e) => e.state == PlannedState.today).toList().reversed;

    result.add(
      TextHeader(
        context.loc.today,
        fontSize: 12,
      ),
    );

    if (todayTxns.isEmpty) {
      result.add(_empty(context));
    }

    for (TransactionData txn in todayTxns) {
      result.add(
        _Tile(key: ValueKey(txn.dateTime), model: txn),
      );
    }

    final overdueTxns = plannedTransactions.where((e) => e.state == PlannedState.overdue).toList().reversed;

    result.add(
      TextHeader(
        'Overdue'.hardcoded,
        fontSize: 12,
      ),
    );

    if (overdueTxns.isEmpty) {
      result.add(_empty(context));
    }

    for (TransactionData txn in overdueTxns) {
      result.add(
        _Tile(key: ValueKey(txn.dateTime), model: txn),
      );
    }

    final skippedTxns = plannedTransactions.where((e) => e.state == PlannedState.skipped).toList().reversed;

    result.add(
      TextHeader(
        'Skipped'.hardcoded,
        fontSize: 12,
      ),
    );

    if (skippedTxns.isEmpty) {
      result.add(_empty(context));
    }

    for (TransactionData txn in skippedTxns) {
      result.add(
        _Tile(key: ValueKey(txn.dateTime), model: txn),
      );
    }

    if (upcomingTxns.isEmpty && todayTxns.isEmpty && overdueTxns.isEmpty && skippedTxns.isEmpty) {
      return [
        Gap.h8,
        IconWithText(
          iconPath: AppIcons.recurrenceBulk,
          text: 'No planned transactions this month'.hardcoded,
        )
      ];
    } else {
      return result;
    }
  }
}

class _Tile extends ConsumerStatefulWidget {
  const _Tile({super.key, required this.model});

  final TransactionData model;

  @override
  ConsumerState<_Tile> createState() => _TileState();
}

class _TileState extends ConsumerState<_Tile> {
  bool _showButtons = false;
  bool _hide = true;

  @override
  void initState() {
    Future.delayed(
        k1msDuration,
        () => setState(() {
              _hide = !_hide;
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.model.category?.backgroundColor ?? AppColors.grey(context);
    final onColor = widget.model.category?.iconColor ?? context.appTheme.onBackground;

    return HideableContainer(
      hide: _hide,
      child: TapRegion(
        onTapOutside: (_) => setState(() {
          _showButtons = false;
        }),
        child: AnimatedSwipeTile(
          buttons: [
            RoundedIconButton(
              iconPath: AppIcons.deleteBulk,
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
                  setState(() {
                    _hide = !_hide;
                  });
                  Future.delayed(k350msDuration, () {
                    final repo = ref.read(recurrenceRepositoryRealmProvider);
                    repo.delete(widget.model.recurrence);
                  });
                },
              ),
            ),
            Gap.w12,
          ],
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
                        withoutIconColor: false,
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
                                widget.model.state != PlannedState.skipped
                                    ? Row(
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
                                                  _hide = !_hide;
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
                                                  _hide = !_hide;
                                                });
                                                Future.delayed(k350msDuration, () {
                                                  final recRepo = ref.read(recurrenceRepositoryRealmProvider);
                                                  recRepo.addSkipped(widget.model);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : IconWithTextButton(
                                        iconPath: AppIcons.turnTwoTone,
                                        backgroundColor: Colors.transparent,
                                        color: context.appTheme.onBackground,
                                        label: 'Un-skip'.hardcoded,
                                        border: Border.all(
                                          color: context.appTheme.onBackground,
                                        ),
                                        labelSize: 12,
                                        iconSize: 14,
                                        width: double.infinity,
                                        height: 30,
                                        onTap: () {
                                          setState(() {
                                            _hide = !_hide;
                                          });
                                          Future.delayed(k350msDuration, () {
                                            final recRepo = ref.read(recurrenceRepositoryRealmProvider);
                                            recRepo.removeSkipped(widget.model);
                                          });
                                        },
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
        ),
      ),
    );
  }
}
