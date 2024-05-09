import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/recurrence/data/recurrence_repo.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../recurrence/domain/recurrence.dart';
import '../../recurrence/presentation/transaction_data_tile.dart';

class PlannedTransactionsModalScreen extends ConsumerWidget {
  const PlannedTransactionsModalScreen(this.controller, this.isScrollable, {super.key, required this.dateTime});

  final ScrollController controller;
  final bool isScrollable;
  final DateTime dateTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    final plannedTxns = recRepo.getPlannedTransactionsInMonth(context, dateTime);

    return ModalContent(
      header: ModalHeader(
        title: 'Planned transactions'.hardcoded,
        secondaryTitle: dateTime.toLongDate(context),
      ),
      body: _buildDays(context, plannedTxns),
      footer: Gap.noGap,
    );
  }

  List<Widget> _buildDays(BuildContext context, List<TransactionData> plannedTransactions) {
    final result = <Widget>[];

    final upcomingTxns = plannedTransactions.where((e) => e.state == PlannedState.upcoming).toList().reversed;

    result.add(
      TextHeader(
        'Upcoming transactions'.hardcoded,
        fontSize: 12,
      ),
    );

    for (TransactionData txn in upcomingTxns) {
      result.add(_Tile(model: txn));
    }

    final todayTxns = plannedTransactions.where((e) => e.state == PlannedState.today).toList().reversed;

    result.add(
      TextHeader(
        context.loc.today,
        fontSize: 12,
      ),
    );

    for (TransactionData txn in todayTxns) {
      result.add(_Tile(model: txn));
    }

    final overdueTxns = plannedTransactions.where((e) => e.state == PlannedState.overdue).toList().reversed;

    result.add(
      TextHeader(
        'Overdue'.hardcoded,
        fontSize: 12,
      ),
    );

    for (TransactionData txn in overdueTxns) {
      result.add(_Tile(model: txn));
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
    final color = widget.model.type == TransactionType.income
        ? context.appTheme.positive
        : widget.model.type == TransactionType.expense
            ? context.appTheme.negative
            : context.appTheme.onBackground;

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
          color: color.withOpacity(0.1),
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
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: IconWithTextButton(
                                iconPath: AppIcons.add,
                                backgroundColor: color,
                                color: context.appTheme.onNegative,
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
                                color: color,
                                label: 'Skip'.hardcoded,
                                border: Border.all(
                                  color: color,
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
