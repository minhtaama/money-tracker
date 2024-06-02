import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../../common_widgets/card_item.dart';
import '../../../charts_and_carousel/application/custom_line_chart_services.dart';
import '../../../charts_and_carousel/presentation/custom_line_chart.dart';
import '../../../charts_and_carousel/presentation/money_carousel.dart';
import '../../../transactions/data/transaction_repo.dart';

class ExtendedHomeTab extends StatelessWidget {
  const ExtendedHomeTab(
      {super.key,
      required this.carouselController,
      required this.initialPageIndex,
      required this.displayDate,
      required this.showNumber,
      required this.onEyeTap});

  final PageController carouselController;
  final int initialPageIndex;
  final DateTime displayDate;
  final bool showNumber;
  final VoidCallback onEyeTap;

  @override
  Widget build(BuildContext context) {
    if (context.isBigScreen) {
      return _ExtendedHomeTabForPageView(
          carouselController: carouselController,
          initialPageIndex: initialPageIndex,
          displayDate: displayDate,
          showNumber: showNumber,
          onEyeTap: onEyeTap);
    }

    return _ExtendedHomeTabForScrollableSheet(
        carouselController: carouselController,
        initialPageIndex: initialPageIndex,
        displayDate: displayDate,
        showNumber: showNumber,
        onEyeTap: onEyeTap);
  }
}

class _ExtendedHomeTabForScrollableSheet extends ConsumerStatefulWidget {
  const _ExtendedHomeTabForScrollableSheet({
    super.key,
    required this.carouselController,
    required this.initialPageIndex,
    required this.displayDate,
    required this.showNumber,
    required this.onEyeTap,
  });

  final PageController carouselController;
  final int initialPageIndex;
  final DateTime displayDate;
  final bool showNumber;
  final VoidCallback onEyeTap;

  @override
  ConsumerState<_ExtendedHomeTabForScrollableSheet> createState() => _ExtendedHomeTabForScrollableSheetState();
}

class _ExtendedHomeTabForScrollableSheetState extends ConsumerState<_ExtendedHomeTabForScrollableSheet> {
  LineChartDataType _type = LineChartDataType.totalAssets;

  String _titleBuilder(String month, int pageIndex) {
    final today = DateTime.now();
    final displayDate = DateTime(Calendar.minDate.year, pageIndex);

    return switch (_type) {
      LineChartDataType.cashflow => 'Cashflow in $month',
      LineChartDataType.expense => 'Expense in $month',
      LineChartDataType.income => 'Income in $month',
      LineChartDataType.totalAssets => displayDate.isSameMonthAs(today)
          ? 'Current assets'
          : displayDate.isInMonthBefore(today)
              ? 'Assets left in $month'
              : 'Expected assets in $month',
    };
  }

  double _amountBuilder(WidgetRef ref, DateTime dayBeginOfMonth, DateTime dayEndOfMonth) {
    final txnServices = ref.read(customLineChartServicesProvider);

    double amount = switch (_type) {
      LineChartDataType.cashflow => txnServices.getCashflow(dayBeginOfMonth, dayEndOfMonth),
      LineChartDataType.expense => txnServices.getExpenseAmount(dayBeginOfMonth, dayEndOfMonth),
      LineChartDataType.income => txnServices.getIncomeAmount(dayBeginOfMonth, dayEndOfMonth),
      LineChartDataType.totalAssets => txnServices.getTotalAssets(dayEndOfMonth),
    };

    ref.listen(transactionsChangesStreamProvider, (_, __) {
      amount = switch (_type) {
        LineChartDataType.cashflow => txnServices.getCashflow(dayBeginOfMonth, dayEndOfMonth),
        LineChartDataType.expense => txnServices.getExpenseAmount(dayBeginOfMonth, dayEndOfMonth),
        LineChartDataType.income => txnServices.getIncomeAmount(dayBeginOfMonth, dayEndOfMonth),
        LineChartDataType.totalAssets => txnServices.getTotalAssets(dayEndOfMonth),
      };
    });

    return amount;
  }

  PrefixSign get _showPrefixSign {
    return switch (_type) {
      LineChartDataType.cashflow => PrefixSign.showAll,
      LineChartDataType.totalAssets => PrefixSign.onlyMinusSign,
      _ => PrefixSign.hideAll,
    };
  }

  bool get _showCurrency {
    return switch (_type) {
      LineChartDataType.cashflow => false,
      _ => true,
    };
  }

  void _onTapSwitchType() {
    setState(() {
      _type = switch (_type) {
        LineChartDataType.totalAssets => LineChartDataType.cashflow,
        LineChartDataType.cashflow => LineChartDataType.expense,
        LineChartDataType.expense => LineChartDataType.income,
        LineChartDataType.income => LineChartDataType.totalAssets,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final chartServices = ref.watch(customLineChartServicesProvider);

    CLCData data = chartServices.getCLCDataForHomeScreen(_type, widget.displayDate);
    double avg = chartServices.getAverageAssets();

    ref.listen(transactionsChangesStreamProvider, (previous, next) {
      data = chartServices.getCLCDataForHomeScreen(_type, widget.displayDate);
      avg = chartServices.getAverageAssets();
    });

    final extraLineText = 'avg: ${context.appSettings.currency.symbol} ${CalService.formatCurrency(context, avg)}';

    final double extraLineY = data.maxAmount == 0 ? 0 : avg / data.maxAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _WelcomeText(),
        Gap.h8,
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
        Gap.h32,
        Expanded(
          child: CustomLineChart(
            currentMonth: widget.displayDate,
            data: data,
            offsetLabelUp: 34,
            // extraLineY: _type == LineChartDataType.totalAssets ? extraLineY : null,
            // extraLineText: extraLineText,
          ),
        ),
      ],
    );
  }
}

class _ExtendedHomeTabForPageView extends ConsumerStatefulWidget {
  const _ExtendedHomeTabForPageView({
    required this.carouselController,
    required this.initialPageIndex,
    required this.displayDate,
    required this.showNumber,
    required this.onEyeTap,
  });

  final PageController carouselController;
  final int initialPageIndex;
  final DateTime displayDate;
  final bool showNumber;
  final VoidCallback onEyeTap;

  @override
  ConsumerState<_ExtendedHomeTabForPageView> createState() => _ExtendedHomeTabForPageViewState();
}

class _ExtendedHomeTabForPageViewState extends ConsumerState<_ExtendedHomeTabForPageView> {
  String _titleBuilder() {
    final today = DateTime.now();
    final displayDate = widget.displayDate;
    final month = displayDate.monthToString(context);

    return displayDate.isSameMonthAs(today)
        ? 'Current assets'
        : displayDate.isInMonthBefore(today)
            ? 'Assets left in $month'
            : 'Expected assets in $month';
  }

  @override
  Widget build(BuildContext context) {
    final chartServices = ref.watch(customLineChartServicesProvider);
    final txnServices = ref.read(customLineChartServicesProvider);

    CLCData data = chartServices.getCLCDataForHomeScreen(LineChartDataType.totalAssets, widget.displayDate);
    double avg = chartServices.getAverageAssets();
    double amount = txnServices.getTotalAssets(widget.displayDate);

    ref.listen(transactionsChangesStreamProvider, (previous, next) {
      data = chartServices.getCLCDataForHomeScreen(LineChartDataType.totalAssets, widget.displayDate);
      avg = chartServices.getAverageAssets();
    });

    final extraLineText = 'avg: ${context.appSettings.currency.symbol} ${CalService.formatCurrency(context, avg)}';

    final double extraLineY = data.maxAmount == 0 ? 0 : avg / data.maxAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.h12,
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: MoneyAmount(
            amount: amount,
            style: kHeader1TextStyle.copyWith(
              color: context.appTheme.onBackground,
            ),
            symbolStyle: kHeader2TextStyle.copyWith(
              color: context.appTheme.onBackground,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            _titleBuilder(),
            style: kNormalTextStyle.copyWith(
              color: context.appTheme.onBackground.withOpacity(0.8),
            ),
          ),
        ),
        Gap.h16,
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.appTheme.background0,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.only(top: 30),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: CustomLineChart(
              currentMonth: widget.displayDate,
              data: data,
              offsetLabelUp: 34,
              // extraLineY: _type == LineChartDataType.totalAssets ? extraLineY : null,
              // extraLineText: extraLineText,
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'moneyMate',
      style: TextStyle(
        color: context.appTheme.accent1,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Lobster',
        //letterSpacing: 2,
      ),
    );
  }
}
