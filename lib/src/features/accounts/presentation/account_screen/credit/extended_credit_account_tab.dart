import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../../../common_widgets/rounded_icon_button.dart';
import '../../../../charts_and_carousel/application/custom_line_chart_services.dart';
import '../../../../charts_and_carousel/presentation/custom_line_chart.dart';
import '../../../../transactions/data/transaction_repo.dart';
import '../../../domain/account_base.dart';

class ExtendedCreditAccountTab extends ConsumerStatefulWidget {
  const ExtendedCreditAccountTab({
    super.key,
    required this.account,
    required this.displayDate,
  });
  final Account account;
  final DateTime displayDate;

  @override
  ConsumerState<ExtendedCreditAccountTab> createState() => _ExtendedCreditAccountTabState();
}

class _ExtendedCreditAccountTabState extends ConsumerState<ExtendedCreditAccountTab> {
  late final _chartServicesRead = ref.read(customLineChartServicesProvider);

  @override
  Widget build(BuildContext context) {
    final chartServices = ref.watch(customLineChartServicesProvider);

    CLCData data = chartServices.getCreditCLCData(widget.account as CreditAccount, widget.displayDate);

    ref.listen(transactionsChangesStreamProvider, (_, __) {
      data = chartServices.getCreditCLCData(widget.account as CreditAccount, widget.displayDate);
    });

    final extraLineY = (data as CLCDataForCredit).extraLineY;
    final extraLineText =
        'Payment required: ${CalService.formatCurrency(context, (data as CLCDataForCredit).balanceRemaining)} ${context.appSettings.currency.code}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textBaseline: TextBaseline.alphabetic,
          children: [
            RoundedIconButton(
              onTap: () => context.pop(),
              backgroundColor: Colors.transparent,
              iconColor: context.appTheme.onBackground,
              iconPath: AppIcons.back,
            ),
            Text(
              widget.account.name,
              style: kHeader2TextStyle.copyWith(
                color: widget.account.iconColor,
                fontSize: 18,
              ),
            ),
            Gap.w8,
          ],
        ),
        Expanded(
          child: CustomLineChart(
            currentMonth: widget.displayDate,
            data: data,
            offsetY: 35,
            isForCredit: true,
            extraLineY: extraLineY,
            extraLineText: extraLineText,
          ),
        ),
      ],
    );
  }
}

class StatementSelector extends StatelessWidget {
  const StatementSelector({
    super.key,
    required this.dateDisplay,
    this.onTapLeft,
    this.onTapRight,
    this.onTapGoToCurrentDate,
  });

  final String dateDisplay;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapGoToCurrentDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: const Offset(0, 1),
          child: RoundedIconButton(
            iconPath: AppIcons.arrowLeft,
            iconColor: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
            //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
            onTap: onTapLeft,
            size: 35,
            iconPadding: 6,
          ),
        ),
        GestureDetector(
          onTap: onTapGoToCurrentDate,
          child: Column(
            children: [
              Text(
                'Statement date',
                style: kHeader3TextStyle.copyWith(
                  color: context.appTheme.isDarkTheme
                      ? context.appTheme.onBackground.withOpacity(0.7)
                      : context.appTheme.onSecondary.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              SizedBox(
                width: 125,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedSwitcher(
                    duration: k150msDuration,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: Tween<double>(
                          begin: 0,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: Text(
                      key: ValueKey(dateDisplay),
                      dateDisplay,
                      style: kHeader2TextStyle.copyWith(
                        color:
                            context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 1),
          child: RoundedIconButton(
            iconPath: AppIcons.arrowRight,
            iconColor: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,

            //backgroundColor: context.appTheme.secondaryNegative.withOpacity(0.25),
            onTap: onTapRight,
            size: 35,
            iconPadding: 6,
          ),
        ),
      ],
    );
  }
}
