import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/transactions/application/transaction_services.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../../common_widgets/custom_line_chart.dart';
import '../../../../common_widgets/money_carousel.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../transactions/data/transaction_repo.dart';

class ExtendedHomeTab extends StatefulWidget {
  const ExtendedHomeTab({
    super.key,
    required this.carouselController,
    required this.initialPageIndex,
    required this.displayDate,
    required this.showNumber,
    required this.onEyeTap,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onDateTap,
  });

  final PageController carouselController;
  final int initialPageIndex;
  final DateTime displayDate;
  final bool showNumber;
  final VoidCallback onEyeTap;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final VoidCallback onDateTap;

  @override
  State<ExtendedHomeTab> createState() => _ExtendedHomeTabState();
}

class _ExtendedHomeTabState extends State<ExtendedHomeTab> {
  ChartDataType _type = ChartDataType.totalAssets;

  String _titleBuilder(String month, int pageIndex) {
    final today = DateTime.now();
    final displayDate = DateTime(Calendar.minDate.year, pageIndex);

    return switch (_type) {
      ChartDataType.cashflow => 'Cashflow in $month',
      ChartDataType.expense => 'Expense in $month',
      ChartDataType.income => 'Income in $month',
      ChartDataType.totalAssets => displayDate.isSameMonthAs(today)
          ? 'Current assets'
          : displayDate.isInMonthBefore(today)
              ? 'Assets left in $month'
              : 'Expected assets in $month',
    };
  }

  double _amountBuilder(WidgetRef ref, DateTime dayBeginOfMonth, DateTime dayEndOfMonth) {
    final txnServices = ref.read(transactionServicesProvider);

    double amount = switch (_type) {
      ChartDataType.cashflow => txnServices.getCashflow(dayBeginOfMonth, dayEndOfMonth),
      ChartDataType.expense => txnServices.getExpenseAmount(dayBeginOfMonth, dayEndOfMonth),
      ChartDataType.income => txnServices.getIncomeAmount(dayBeginOfMonth, dayEndOfMonth),
      ChartDataType.totalAssets => txnServices.getTotalAssets(dayEndOfMonth),
    };

    ref.listen(transactionChangesRealmProvider(DateTimeRange(start: Calendar.minDate, end: Calendar.maxDate)), (_, __) {
      amount = switch (_type) {
        ChartDataType.cashflow => txnServices.getCashflow(dayBeginOfMonth, dayEndOfMonth),
        ChartDataType.expense => txnServices.getExpenseAmount(dayBeginOfMonth, dayEndOfMonth),
        ChartDataType.income => txnServices.getIncomeAmount(dayBeginOfMonth, dayEndOfMonth),
        ChartDataType.totalAssets => txnServices.getTotalAssets(dayEndOfMonth),
      };
    });

    return amount;
  }

  String _extraLineTextBuilder(WidgetRef ref) {
    final txnServices = ref.read(transactionServicesProvider);

    final amount = CalService.formatCurrency(context, txnServices.getMinMaxAssetsEver()[1]);
    final symbol = context.appSettings.currency.symbol;

    return 'Highest ever: $symbol $amount';
  }

  List<CLCSpot> _valuesBuilder(WidgetRef ref) {
    final txnRepo = ref.read(transactionServicesProvider);

    return txnRepo.getLineChartSpots(_type, widget.displayDate);
  }

  bool get _showPrefixSign {
    return switch (_type) {
      ChartDataType.cashflow => true,
      _ => false,
    };
  }

  CustomLineType get _customLineType {
    final today = DateTime.now();
    if (widget.displayDate.isSameMonthAs(today)) {
      return CustomLineType.thickThenThin;
    }
    if (widget.displayDate.isInMonthAfter(today)) {
      return CustomLineType.thin;
    }
    if (widget.displayDate.isInMonthBefore(today)) {
      return CustomLineType.thick;
    }

    throw ErrorDescription('Whoop whoop');
  }

  bool get _showCurrency {
    return switch (_type) {
      ChartDataType.cashflow => false,
      _ => true,
    };
  }

  void _onTapSwitchType() {
    setState(() {
      _type = switch (_type) {
        ChartDataType.totalAssets => ChartDataType.cashflow,
        ChartDataType.cashflow => ChartDataType.expense,
        ChartDataType.expense => ChartDataType.income,
        ChartDataType.income => ChartDataType.totalAssets,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _WelcomeText(),
        Gap.h16,
        MoneyCarousel(
          controller: widget.carouselController,
          initialPageIndex: widget.initialPageIndex,
          leftIconPath: AppIcons.switchIcon,
          rightIconPath: widget.showNumber ? AppIcons.eyeSlash : AppIcons.eye,
          onTapRightIcon: widget.onEyeTap,
          onTapLeftIcon: _onTapSwitchType,
          showPrefixSign: _showPrefixSign,
          showCurrency: _showCurrency,
          titleBuilder: _titleBuilder,
          amountBuilder: _amountBuilder,
        ),
        Expanded(
          child: CustomLineChart(
            currentMonth: widget.displayDate,
            valuesBuilder: _valuesBuilder,
            chartOffsetY: 35,
            extraLineY: 1,
            primaryLineType: _customLineType,
            chartDataType: _type,
            showExtraLine: _type == ChartDataType.totalAssets,
            extraLineText: _extraLineTextBuilder,
          ),
        ),
        _DateSelector(
          displayDate: widget.displayDate,
          onDateTap: widget.onDateTap,
          onTapLeft: widget.onTapLeft,
          onTapRight: widget.onTapRight,
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.displayDate,
    this.onTapLeft,
    this.onTapRight,
    this.onDateTap,
  });

  final DateTime displayDate;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onDateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Gap.screenWidth(context),
      height: 64,
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      decoration: BoxDecoration(
        color: context.appTheme.background0,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundedIconButton(
            iconPath: AppIcons.arrowLeft,
            iconColor: context.appTheme.onBackground,
            onTap: onTapLeft,
            size: 25,
            iconPadding: 2,
          ),
          Gap.w8,
          GestureDetector(
            onTap: onDateTap,
            child: SizedBox(
              width: 155,
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
                  child: Padding(
                    key: ValueKey(displayDate.getFormattedDate(hasDay: false, format: DateTimeFormat.ddmmmmyyyy)),
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Row(
                      children: [
                        RoundedIconButton(
                          iconPath: displayDate.onlyYearMonth.isAtSameMomentAs(DateTime.now().onlyYearMonth)
                              ? AppIcons.today
                              : AppIcons.turn,
                          iconColor: context.appTheme.onBackground,
                          size: 16,
                          iconPadding: 0,
                        ),
                        Gap.w8,
                        Text(
                          displayDate.getFormattedDate(hasDay: false, format: DateTimeFormat.ddmmmmyyyy),
                          style: kHeader3TextStyle.copyWith(
                            color: context.appTheme.onBackground,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Gap.w8,
          RoundedIconButton(
            iconPath: AppIcons.arrowRight,
            iconColor: context.appTheme.onBackground,
            onTap: onTapRight,
            size: 25,
            iconPadding: 2,
          ),
        ],
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Money Tracker'.hardcoded,
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.isDarkTheme ? context.appTheme.onBackground : context.appTheme.onSecondary,
        fontSize: 15,
      ),
    );
  }
}
