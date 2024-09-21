import 'dart:math' as math;
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/scaffold_with_bottom_nav_bar_shell.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_page_tool_bar.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_tab_bar.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_page.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/screen_details/credit/components/extended_tab.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../../common_widgets/card_item.dart';
import '../../../../../common_widgets/custom_inkwell.dart';
import '../../../../../common_widgets/custom_navigation_bar/bottom_app_bar/custom_fab.dart';
import '../../../../../common_widgets/modal_and_dialog.dart';
import '../../../../../common_widgets/svg_icon.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../theme_and_ui/colors.dart';
import '../../../../../theme_and_ui/icons.dart';
import '../../../../../utils/constants.dart';
import '../../../../../utils/enums.dart';
import '../../../../calculator_input/application/calculator_service.dart';
import '../../../../home/presentation/tab_bars/small_home_tab.dart';
import '../../../../transactions/data/transaction_repo.dart';
import '../../../../transactions/domain/transaction_base.dart';
import '../../../../transactions/presentation/screens/add_model_screen/add_credit_checkpoint_modal_screen.dart';
import '../../../../transactions/presentation/components/base_transaction_components.dart';
import '../../../domain/account_base.dart';
import '../../../domain/statement/base_class/statement.dart';

part 'components/components.dart';
part 'components/transactions_list.dart';

class CreditScreenDetails extends ConsumerStatefulWidget {
  const CreditScreenDetails({super.key, required this.creditAccount});

  final CreditAccount creditAccount;

  @override
  ConsumerState<CreditScreenDetails> createState() => _CreditScreenDetailsState();
}

class _CreditScreenDetailsState extends ConsumerState<CreditScreenDetails> {
  late final _transactionRepository = ref.read(transactionRepositoryRealmProvider);
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

  final List<BaseCreditTransaction> _selectedTransactions = [];

  void _clearAllSelection() {
    _selectedTransactions.clear();
  }

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

  bool _canAddCheckpoint(Statement statement) {
    if (statement.checkpoint != null) {
      return false;
    }

    DateTime before = widget.creditAccount.latestClosedStatementDueDate;
    DateTime checkpoint = widget.creditAccount.latestCheckpointDateTime;
    DateTime after = widget.creditAccount.todayStatementDueDate;

    if (statement.date.statement.isAfter(before) &&
        statement.date.statement.isAfter(checkpoint) &&
        statement.date.statement.isBefore(after)) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomNavBar(
      floatingActionButton: CustomFloatingActionButton(
        color: widget.creditAccount.backgroundColor,
        iconColor: widget.creditAccount.iconColor,
        roundedButtonItems: [
          FABItem(
            icon: AppIcons.receiptDollarBulk,
            label: context.loc.creditSpending,
            color: context.appTheme.onNegative,
            backgroundColor: context.appTheme.negative,
            onTap: () => context.push(RoutePath.addCreditSpending),
          ),
          FABItem(
            icon: AppIcons.fykFaceBulk,
            label: 'Placeholder'.hardcoded,
            color: context.appTheme.onBackground,
            backgroundColor: AppColors.grey(context),
            onTap: () {},
          ),
          FABItem(
            icon: AppIcons.handCoinTwoTone,
            label: context.loc.creditPayment,
            color: context.appTheme.onPositive,
            backgroundColor: context.appTheme.positive,
            onTap: () => context.push(RoutePath.addCreditPayment),
          ),
        ],
      ),
      child: CustomAdaptivePageView(
        pageController: _controller,
        forceShowSmallTabBar: _selectedTransactions.isNotEmpty,
        smallTabBar: SmallTabBar(
          showSecondChild: _selectedTransactions.isNotEmpty,
          firstChild: PageHeading(
            title: widget.creditAccount.name,
            secondaryTitle: context.loc.creditAccount,
          ),
          secondChild: MultiSelectionTab(
            selectedTransactions: _selectedTransactions,
            backgroundColor: widget.creditAccount.backgroundColor,
            isTopNavigation: false,
            onClear: () => setState(() {
              _clearAllSelection();
            }),
            onConfirmDelete: () => setState(() {
              final removeList = _transactionRepository.deleteTransactions(_selectedTransactions);
              _clearAllSelection();
              if (removeList.isNotEmpty) {
                showCustomDialog(
                  context: context,
                  child: IconWithText(
                    iconPath: AppIcons.sadFaceBulk,
                    header: context.loc.deleteTransactionAlert1,
                    text: context.loc.deleteTransactionAlertQuote1,
                    textAlign: TextAlign.left,
                  ),
                );
              }
            }),
          ),
        ),
        extendedTabBar: ExtendedTabBar(
          backgroundColor: widget.creditAccount.backgroundColor.addDark(context.appTheme.isDarkTheme ? 0.3 : 0.0),
          overlayColor: widget.creditAccount.iconColor,
          child: ExtendedCreditAccountTab(account: widget.creditAccount, displayDate: _displayStatementDate),
        ),
        onDragLeft: _previousPage,
        onDragRight: _nextPage,
        onPageChanged: _onPageChange,
        toolBarHeight: 50,
        toolBarBuilder: (page) {
          final date = DateTime(_today.year, _initialStatementMonth + (page - _initialPageIndex), _statementDay);
          return CustomPageToolBar(
            isToday: page == _initialPageIndex,
            displayDate: date,
            onDateTap: () {
              _animatedToPage(_initialPageIndex);
            },
            topTitle: context.loc.statementDate,
            title: date.toShortDate(context),
          );
        },
        toolBar: CustomPageToolBar(
          isToday: _currentPageIndex == _initialPageIndex,
          displayDate: _displayStatementDate,
          onTapLeft: _previousPage,
          onTapRight: _nextPage,
          onDateTap: () {
            _animatedToPage(_initialPageIndex);
          },
          topTitle: context.loc.statementDate,
          title: _displayStatementDate.toShortDate(context),
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
                  _TransactionList(
                    account: widget.creditAccount,
                    statement: statement,
                    isInMultiSelectionMode: _selectedTransactions.isNotEmpty,
                    selectedTransactions: _selectedTransactions,
                    onTransactionTap: (transaction) =>
                        context.push(RoutePath.transaction, extra: transaction.databaseObject.id.hexString),
                    onTransactionLongPress: (transaction) => setState(() {
                      if (_selectedTransactions.contains(transaction)) {
                        setState(() {
                          _selectedTransactions.remove(transaction);
                        });
                      } else {
                        setState(() {
                          _selectedTransactions.add(transaction);
                        });
                      }
                    }),
                    onStatementDateTap: _canAddCheckpoint(statement)
                        ? () => showCustomModal(
                              context: context,
                              child: AddCreditCheckpointModalScreen(
                                statement: statement,
                                creditAccount: widget.creditAccount,
                              ),
                            )
                        : null,
                  ),
                  Gap.h48,
                ]
              : [
                  IconWithText(
                    iconPath: AppIcons.doneLight,
                    onTap: () => showCustomModal(
                      context: context,
                      child: AddCreditCheckpointModalScreen(
                        statement: statement,
                        statementDate: currentDateTime,
                        creditAccount: widget.creditAccount,
                      ),
                    ),
                    forceIconOnTop: true,
                    header: context.loc.noTransactionMadeBeforeThisDay,
                    text: context.loc.tapToAddBalanceCheckpoint,
                  ),
                ];
        },
      ),
    );
  }
}
