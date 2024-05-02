import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/animated_swipe_tile.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/recurrence/domain/recurrence.dart';
import 'package:money_tracker_app/src/features/recurrence/presentation/transaction_data_tile.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_page/custom_page.dart';
import '../../../common_widgets/modal_and_dialog.dart';
import '../../../common_widgets/rounded_icon_button.dart';
import '../../../theme_and_ui/icons.dart';
import '../data/recurrence_repo.dart';

class RecurrenceScreen extends ConsumerWidget {
  const RecurrenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recRepo = ref.watch(recurrenceRepositoryRealmProvider);
    List<Recurrence> list = recRepo.getRecurrences();

    ref.watch(recurrenceChangesStreamProvider).whenData((_) {
      list = recRepo.getRecurrences();
    });

    return CustomPage(
      smallTabBar: SmallTabBar(
        child: PageHeading(
          isTopLevelOfNavigationRail: true,
          title: context.loc.recurrence,
        ),
      ),
      children: list.map((e) => _RecurrenceScreenTile(re: e)).toList(),
    );
  }
}

class _RecurrenceScreenTile extends ConsumerStatefulWidget {
  const _RecurrenceScreenTile({super.key, required this.re});

  final Recurrence re;

  @override
  ConsumerState<_RecurrenceScreenTile> createState() => _RecurrenceScreenTileState();
}

class _RecurrenceScreenTileState extends ConsumerState<_RecurrenceScreenTile> {
  bool _showExpression = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap.h12,
        AnimatedSwipeTile(
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
                label: 'Delete this recurrence transaction?'.hardcoded,
                onConfirm: () {
                  final repo = ref.read(recurrenceRepositoryRealmProvider);
                  repo.delete(widget.re);
                },
              ),
            ),
            Gap.w12,
          ],
          child: CardItem(
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            child: CustomInkWell(
              inkColor: context.appTheme.onBackground,
              onTap: () => setState(() {
                _showExpression = !_showExpression;
              }),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TransactionDataTile(model: widget.re.transactionData),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: HideableContainer(
            hide: !_showExpression,
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                recurrenceExpression(context, widget.re),
                style: kHeader4TextStyle.copyWith(
                  color: context.appTheme.onBackground,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
