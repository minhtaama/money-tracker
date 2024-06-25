import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_line_chart.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/card_item.dart';
import '../../../common_widgets/custom_inkwell.dart';
import '../../../common_widgets/icon_with_text.dart';
import '../../../common_widgets/money_amount.dart';
import '../../../common_widgets/svg_icon.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../charts_and_carousel/application/custom_line_chart_services.dart';

class AccountsReportWidget extends StatelessWidget {
  const AccountsReportWidget({super.key, required this.dateTimes});

  final List<DateTime> dateTimes;

  @override
  Widget build(BuildContext context) {
    return ReportWrapperSwitcher(
      title: 'Assets'.hardcoded,
      firstChild: _TotalView(dateTimes),
      secondChild: _SeparateView(dateTimes),
    );
  }
}

class _TotalView extends ConsumerStatefulWidget {
  const _TotalView(this.dateTimes, {super.key});

  final List<DateTime> dateTimes;

  @override
  ConsumerState<_TotalView> createState() => _TotalViewState();
}

class _TotalViewState extends ConsumerState<_TotalView> {
  int _touchedIndex = -1;

  late final accountRepo = ref.read(accountRepositoryProvider);
  late final chartServices = ref.read(customLineChartServicesProvider);

  late List<RegularAccount> _accountList =
      accountRepo.getList([AccountType.regular]).whereType<RegularAccount>().toList();

  late CLCData2 _data = chartServices.getCLCDataForReportScreenOnRegularAccount(
    _accountList,
    widget.dateTimes.first,
    widget.dateTimes.last,
  );

  @override
  void didUpdateWidget(covariant _TotalView oldWidget) {
    setState(() {
      _accountList = accountRepo.getList([AccountType.regular]).whereType<RegularAccount>().toList();

      _data = chartServices.getCLCDataForReportScreenOnRegularAccount(
        _accountList,
        widget.dateTimes.first,
        widget.dateTimes.last,
      );
    });
    super.didUpdateWidget(oldWidget);
  }

  Widget _accountLabel(RegularAccount account) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: account.backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Gap.w4,
          Text(
            account.name,
            style: kHeader4TextStyle.copyWith(
              color: context.appTheme.onBackground,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _labels(CLCData2 data, int index, {required void Function(AccountInfo) onTap}) {
    final result = <Widget>[];

    if (index == -1) {
      return result;
    }

    result.addAll([
      Gap.h24,
      Padding(
        padding: const EdgeInsets.only(left: 14.0),
        child: Text(
          data.lines[0].spots[index].dateTime!.toLongDate(context),
          style: kHeader4TextStyle.copyWith(
            color: context.appTheme.onBackground.withOpacity(0.65),
            fontSize: 14,
          ),
        ),
      ),
      Gap.divider(context, indent: 10),
    ]);

    for (CLCData2Line line in data.lines) {
      final account = line.accountInfo;

      result.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: CustomInkWell(
            onTap: () => onTap(account),
            inkColor: context.appTheme.onBackground,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 27,
                    width: 27,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: account.backgroundColor,
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: SvgIcon(
                      account.iconPath,
                      color: account.iconColor,
                    ),
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      account.name,
                      style: kHeader4TextStyle.copyWith(
                        color: context.appTheme.onBackground,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  MoneyAmount(
                    amount: line.spots[index].amount,
                    style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_accountList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: IconWithText(
          header: 'No accounts',
          iconPath: AppIcons.accountsBulk,
          iconSize: 30,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 230,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.translate(
                offset: const Offset(0, 12),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 60),
                  child: Wrap(
                    runSpacing: 4,
                    spacing: 8,
                    children: _accountList.map((e) => _accountLabel(e)).toList(),
                  ),
                ),
              ),
              Expanded(
                child: CustomLineChart2(
                  data: _data,
                  handleBuiltInTouches: false,
                  onChartTap: (index) {
                    setState(() {
                      _touchedIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        ..._labels(_data, _touchedIndex, onTap: (_) {}),
      ],
    );
  }
}

class _SeparateView extends ConsumerStatefulWidget {
  const _SeparateView(this.dateTimes, {super.key});

  final List<DateTime> dateTimes;

  @override
  ConsumerState<_SeparateView> createState() => _SeparateViewState();
}

class _SeparateViewState extends ConsumerState<_SeparateView> {
  @override
  Widget build(BuildContext context) {
    final accountRepo = ref.watch(accountRepositoryProvider);
    final chartServices = ref.watch(customLineChartServicesProvider);

    final accountList = accountRepo.getList([AccountType.regular]).whereType<RegularAccount>().toList();

    if (accountList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: IconWithText(
          header: 'No accounts',
          iconPath: AppIcons.accountsBulk,
          iconSize: 30,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: accountList
          .map(
            (account) => SizedBox(
              height: 230,
              child: Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgIcon(
                          account.iconPath,
                          color: context.appTheme.onBackground,
                          size: 20,
                        ),
                        Gap.w4,
                        Flexible(
                          child: Text(
                            account.name,
                            style: kHeader3TextStyle.copyWith(
                              color: context.appTheme.onBackground,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Gap.w8,
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomLineChart2(
                      data: chartServices.getCLCDataForReportScreenOnRegularAccount(
                        [account],
                        widget.dateTimes.first,
                        widget.dateTimes.last,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
