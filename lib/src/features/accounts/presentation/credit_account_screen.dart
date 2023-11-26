import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_bar.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_page.dart';
import 'package:money_tracker_app/src/common_widgets/empty_info.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/statement_transactions_list.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../home/presentation/tab_bars/extended_home_tab.dart';
import '../domain/account_base.dart';
import '../domain/statement/statement.dart';

class CreditAccountScreen extends StatefulWidget {
  const CreditAccountScreen({super.key, required this.creditAccount});

  final CreditAccount creditAccount;

  @override
  State<CreditAccountScreen> createState() => _CreditAccountScreenState();
}

class _CreditAccountScreenState extends State<CreditAccountScreen> {
  late final _statementDay = widget.creditAccount.statementDay;

  late final PageController _controller = PageController(initialPage: _initialPageIndex);

  late final DateTime _today = DateTime.now().onlyYearMonthDay;

  late final int _initialPageIndex = _today.getMonthsDifferent(Calendar.minDate);

  late DateTime _displayStatementDate = _today.copyWith(day: _statementDay, month: _today.month + 1);

  bool _showCurrentDateButton = false;

  void _onPageChange(int value) {
    _displayStatementDate = DateTime(_today.year, _today.month + (value - _initialPageIndex) + 1);
    _isShowGoToCurrentDateButton();
    setState(() {});
  }

  void _previousPage() {
    _controller.previousPage(duration: k250msDuration, curve: Curves.easeOut);
  }

  void _nextPage() {
    _controller.nextPage(duration: k250msDuration, curve: Curves.easeOut);
  }

  void _animatedToPage(int page) {
    _controller.animateToPage(page, duration: k350msDuration, curve: Curves.easeOut);
  }

  void _isShowGoToCurrentDateButton() {
    if (_displayStatementDate.year == _today.year && _displayStatementDate.month - 1 == _today.month) {
      _showCurrentDateButton = false;
    } else {
      _showCurrentDateButton = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.background,
      body: CustomTabPageWithPageView(
        controller: _controller,
        smallTabBar: SmallTabBar(
            child: PageHeading(
          title: widget.creditAccount.name,
          hasBackButton: true,
        )),
        extendedTabBar: ExtendedTabBar(
          innerChild: Placeholder(),
          outerChild: DateSelector(
            dateDisplay: _displayStatementDate.getFormattedDate(type: DateTimeType.ddmmyyyy),
            onTapLeft: _previousPage,
            onTapRight: _nextPage,
            onTapGoToCurrentDate: () {
              _animatedToPage(_initialPageIndex);
            },
            showGoToCurrentDateButton: _showCurrentDateButton,
          ),
        ),
        onDragLeft: _previousPage,
        onDragRight: _nextPage,
        onPageChanged: _onPageChange,
        itemBuilder: (context, pageIndex) {
          DateTime today = DateTime(Calendar.minDate.year, pageIndex, _today.day);
          Statement? statement = widget.creditAccount.statementAt(today);

          return statement != null
              ? [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StatementTransactionsList(
                      statement: widget.creditAccount.statementAt(today),
                    ),
                  )
                ]
              : [
                  EmptyInfo(
                    iconPath: AppIcons.done,
                    infoText: 'No transactions has made before this day'.hardcoded,
                  ),
                ];
        },
      ),
    );
  }
}
