import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/screen_details/regular/edit_modal.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../../../../common_widgets/modal_and_dialog.dart';
import '../../../../../../common_widgets/rounded_icon_button.dart';
import '../../../../../../utils/enums.dart';
import '../../../../../charts_and_carousel/application/custom_line_chart_services.dart';
import '../../../../../charts_and_carousel/presentation/custom_line_chart.dart';
import '../../../../../transactions/data/transaction_repo.dart';
import '../../../../domain/account_base.dart';

class ExtendedRegularAccountTab extends ConsumerWidget {
  const ExtendedRegularAccountTab({
    super.key,
    required this.account,
    required this.displayDate,
  });
  final RegularAccount account;
  final DateTime displayDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartServices = ref.watch(customLineChartServicesProvider);
    final range = displayDate.monthRange;

    CLCData data = chartServices.getCLCDataOfRegularAsset(account, range.start, range.end);

    ref.listen(transactionsChangesStreamProvider, (_, __) {
      data = chartServices.getCLCDataOfRegularAsset(account, range.start, range.end);
    });

    if (context.isBigScreen) {
      return Container(
        decoration: BoxDecoration(
          color: account.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.only(bottom: 4),
        margin: const EdgeInsets.only(left: 6, right: 6, top: 6),
        child: _content(data),
      );
    }

    return _content(data);
  }

  Widget _content(CLCData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(account: account),
        Gap.h16,
        Expanded(
          child: CustomLineChart(
            currentMonth: displayDate,
            color: account.iconColor,
            todayDotColor: account.backgroundColor,
            data: data,
            offsetLabelUp: 34,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.account});

  final RegularAccount account;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundedIconButton(
            onTap: () => context.pop(),
            backgroundColor: Colors.transparent,
            iconColor: account.iconColor,
            iconPath: AppIcons.backLight,
          ),
          Gap.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: kHeader1TextStyle.copyWith(
                    color: account.iconColor,
                    fontSize: 28,
                  ),
                ),
                Text(
                  context.loc.regularAccount,
                  style: kNormalTextStyle.copyWith(
                    color: account.iconColor,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          RoundedIconButton(
            onTap: () => showCustomModal(
              context: context,
              child: EditRegularAccountModalScreen(account),
            ),
            backgroundColor: Colors.transparent,
            iconColor: account.iconColor,
            iconPath: AppIcons.editLight,
          ),
        ],
      ),
    );
  }
}
