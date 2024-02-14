import 'dart:math' as math;
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_bar.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_page.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/screen_details/credit/components/extended_tab.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../../common_widgets/card_item.dart';
import '../../../../../common_widgets/custom_inkwell.dart';
import '../../../../../common_widgets/custom_navigation_bar/bottom_app_bar/custom_fab.dart';
import '../../../../../common_widgets/modal_and_dialog.dart';
import '../../../../../common_widgets/rounded_icon_button.dart';
import '../../../../../common_widgets/svg_icon.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../theme_and_ui/colors.dart';
import '../../../../../theme_and_ui/icons.dart';
import '../../../../../utils/constants.dart';
import '../../../../../utils/enums.dart';
import '../../../../calculator_input/application/calculator_service.dart';
import '../../../../transactions/domain/transaction_base.dart';
import '../../../../transactions/presentation/screens/add_model_screen/add_credit_checkpoint_modal_screen.dart';
import '../../../../transactions/presentation/components/txn_components.dart';
import '../../../domain/account_base.dart';
import '../../../domain/statement/base_class/statement.dart';

part 'components/components.dart';
part 'components/transactions_list.dart';

class CreditScreenDetails extends StatefulWidget {
  const CreditScreenDetails({super.key, required this.creditAccount});

  final CreditAccount creditAccount;

  @override
  State<CreditScreenDetails> createState() => _CreditScreenDetailsState();
}

class _CreditScreenDetailsState extends State<CreditScreenDetails> {
  late final PageController _controller = PageController(initialPage: _initialPageIndex);

  late final _statementDay = widget.creditAccount.statementDay;
  late final _dueDay = widget.creditAccount.paymentDueDay;

  late final _today = DateTime.now().onlyYearMonthDay;

  int get _initialStatementMonth {
    if (_statementDay > _dueDay) {
      return _today.day > _dueDay ? _today.month : _today.month - 1;
    } else {
      return _today.day > _dueDay ? _today.month + 1 : _today.month;
    }
  }

  late DateTime _displayStatementDate = _today.copyWith(day: _statementDay, month: _initialStatementMonth);

  late final int _initialPageIndex = _displayStatementDate.getMonthsDifferent(Calendar.minDate);
  late int _currentPageIndex = _initialPageIndex;

  void _onPageChange(int value) {
    _currentPageIndex = value;
    _displayStatementDate = DateTime(_today.year, _initialStatementMonth + (value - _initialPageIndex), _statementDay);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.background1,
      floatingActionButton: CustomFloatingActionButton(
        roundedButtonItems: [
          FABItem(
            icon: AppIcons.receiptDollar,
            label: 'Spending'.hardcoded,
            color: context.appTheme.onNegative,
            backgroundColor: context.appTheme.negative,
            onTap: () => context.push(RoutePath.addCreditSpending),
          ),
          FABItem(
            icon: AppIcons.statementCheckpoint,
            label: 'Checkpoint'.hardcoded,
            color: context.appTheme.onBackground,
            backgroundColor: AppColors.grey(context),
            onTap: () => showCustomModalBottomSheet(
                context: context, child: AddCreditCheckpointModalScreen(account: widget.creditAccount)),
          ),
          FABItem(
            icon: AppIcons.handCoin,
            label: 'Payment'.hardcoded,
            color: context.appTheme.onPositive,
            backgroundColor: context.appTheme.positive,
            onTap: () => context.push(RoutePath.addCreditPayment),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomTabPageWithPageView(
        controller: _controller,
        smallTabBar: SmallTabBar(
            child: PageHeading(
                title: widget.creditAccount.name, secondaryTitle: 'Credit account'.hardcoded, hasBackButton: true)),
        extendedTabBar: ExtendedTabBar(
          backgroundColor: widget.creditAccount.backgroundColor.addDark(context.appTheme.isDarkTheme ? 0.3 : 0.0),
          child: ExtendedCreditAccountTab(account: widget.creditAccount, displayDate: _displayStatementDate),
        ),
        onDragLeft: _previousPage,
        onDragRight: _nextPage,
        onPageChanged: _onPageChange,
        toolBarHeight: 50,
        toolBar: StatementSelector(
          isToday: _currentPageIndex == _initialPageIndex,
          dateDisplay: _displayStatementDate.getFormattedDate(format: DateTimeFormat.ddmmyyyy),
          onTapLeft: _previousPage,
          onTapRight: _nextPage,
          onTapGoToCurrentDate: () {
            _animatedToPage(_initialPageIndex);
          },
        ),
        itemBuilder: (context, ref, pageIndex) {
          final currentDateTime =
              DateTime(_today.year, _initialStatementMonth + (pageIndex - _initialPageIndex), _statementDay);
          final Statement? statement = widget.creditAccount.statementAt(currentDateTime, upperGapAtDueDate: true);
          return statement != null
              ? [
                  _SummaryCard(
                    statement: statement,
                    isClosedStatement: widget.creditAccount.closedStatementsList.contains(statement),
                  ),
                  Gap.h4,
                  Gap.divider(context, indent: 24),
                  _TransactionList(statement: statement),
                  Gap.h48,
                ]
              : [
                  IconWithText(
                    iconPath: AppIcons.done,
                    forceIconOnTop: true,
                    header: 'No transactions has made before this day'.hardcoded,
                  ),
                ];
        },
      ),
    );
  }
}

class StatementSelector extends StatelessWidget {
  const StatementSelector({
    super.key,
    required this.isToday,
    required this.dateDisplay,
    this.onTapLeft,
    this.onTapRight,
    this.onTapGoToCurrentDate,
  });

  final bool isToday;
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
        Gap.w24,
        GestureDetector(
          onTap: onTapGoToCurrentDate,
          child: SizedBox(
            width: 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                AnimatedSwitcher(
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
                  child: Row(
                    key: ValueKey(dateDisplay),
                    children: [
                      Text(
                        key: ValueKey(dateDisplay),
                        dateDisplay,
                        style: kHeader2TextStyle.copyWith(
                          color: context.appTheme.onBackground.withOpacity(0.9),
                          fontSize: 22,
                        ),
                      ),
                      Gap.w8,
                      !isToday
                          ? RoundedIconButton(
                              iconPath: AppIcons.turn,
                              iconColor: context.appTheme.onBackground,
                              size: 20,
                              iconPadding: 0,
                            )
                          : Gap.noGap,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        RoundedIconButton(
          iconPath: AppIcons.arrowLeft,
          iconColor: context.appTheme.onBackground,
          onTap: onTapLeft,
          size: 34,
          iconPadding: 5,
        ),
        Gap.w24,
        RoundedIconButton(
          iconPath: AppIcons.arrowRight,
          iconColor: context.appTheme.onBackground,
          onTap: onTapRight,
          size: 34,
          iconPadding: 5,
        ),
        Gap.w16,
      ],
    );
  }
}
