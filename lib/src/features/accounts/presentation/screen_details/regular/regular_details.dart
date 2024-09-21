import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/scaffold_with_bottom_nav_bar_shell.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_page_tool_bar.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/screen_details/regular/components/extended_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/day_card.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../../../../common_widgets/custom_navigation_bar/bottom_app_bar/custom_fab.dart';
import '../../../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../../../common_widgets/custom_page/custom_page.dart';
import '../../../../../common_widgets/icon_with_text.dart';
import '../../../../../common_widgets/illustration.dart';
import '../../../../../common_widgets/modal_and_dialog.dart';
import '../../../../../common_widgets/page_heading.dart';
import '../../../../../theme_and_ui/colors.dart';
import '../../../../../theme_and_ui/icons.dart';
import '../../../../../utils/constants.dart';
import '../../../../home/presentation/tab_bars/small_home_tab.dart';
import '../../../../transactions/domain/transaction_base.dart';

class RegularScreenDetails extends ConsumerStatefulWidget {
  const RegularScreenDetails({super.key, required this.regularAccount});

  final RegularAccount regularAccount;

  @override
  ConsumerState<RegularScreenDetails> createState() => _RegularScreenDetailsState();
}

class _RegularScreenDetailsState extends ConsumerState<RegularScreenDetails> {
  late final _transactionRepository = ref.read(transactionRepositoryRealmProvider);

  late final PageController _pageController = PageController(initialPage: _initialPageIndex);

  late final DateTime _today = DateTime.now().onlyYearMonth;
  late final int _initialPageIndex = _today.getMonthsDifferent(Calendar.minDate);

  late DateTime _currentDisplayDate = _today;

  final List<BaseTransaction> _selectedTransactions = [];

  void _clearAllSelection() {
    _selectedTransactions.clear();
  }

  void _onPageChange(int value) {
    setState(() {
      _currentDisplayDate = DateTime(_today.year, _today.month + (value - _initialPageIndex));
    });
  }

  void _previousPage() {
    _pageController.previousPage(duration: k250msDuration, curve: Curves.easeOut);
  }

  void _nextPage() {
    _pageController.nextPage(duration: k250msDuration, curve: Curves.easeOut);
  }

  void _animatedToPage(int page) {
    _pageController.animateToPage(page, duration: k350msDuration, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildTransactionWidgetList(
    List<BaseTransaction> transactionList,
    DateTime dayBeginOfMonth,
    DateTime dayEndOfMonth,
  ) {
    final List<DayCard> dayCards = [];

    for (int day = dayEndOfMonth.day; day >= dayBeginOfMonth.day; day--) {
      final transactionsInDay = transactionList.where((transaction) => transaction.dateTime.day == day).toList();

      if (transactionsInDay.isNotEmpty) {
        dayCards.add(
          DayCard(
            dateTime: dayBeginOfMonth.copyWith(day: day),
            transactions: transactionsInDay.reversed.toList(),
            plannedTransactions: const [],
            selectedTransactions: _selectedTransactions,
            isInMultiSelectionMode: _selectedTransactions.isNotEmpty,
            onTransactionTap: (transaction) =>
                context.push(RoutePath.transaction, extra: transaction.databaseObject.id.hexString),
            onLongPressTransaction: (transaction) {
              if (_selectedTransactions.contains(transaction)) {
                setState(() {
                  _selectedTransactions.remove(transaction);
                });
              } else {
                setState(() {
                  _selectedTransactions.add(transaction);
                });
              }
            },
          ),
        );
      }
    }

    if (dayCards.isEmpty) {
      return [
        Gap.h32,
        RandomIllustration(
          dayBeginOfMonth.month,
          text: context.loc.quoteHomepage(dayBeginOfMonth.monthToString(context)),
        ),
        Gap.h48,
      ];
    }

    return dayCards;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomNavBar(
      floatingActionButton: CustomFloatingActionButton(
        color: widget.regularAccount.backgroundColor,
        iconColor: widget.regularAccount.iconColor,
        roundedButtonItems: [
          FABItem(
            icon: AppIcons.incomeLight,
            label: context.loc.income,
            color: context.appTheme.onPositive,
            backgroundColor: context.appTheme.positive,
            onTap: () => context.push(RoutePath.addIncome),
          ),
          FABItem(
            icon: AppIcons.transferLight,
            label: context.loc.transfer,
            color: context.appTheme.onBackground,
            backgroundColor: AppColors.grey(context),
            onTap: () => context.push(RoutePath.addTransfer),
          ),
          FABItem(
            icon: AppIcons.expenseLight,
            label: context.loc.expense,
            color: context.appTheme.onNegative,
            backgroundColor: context.appTheme.negative,
            onTap: () => context.push(RoutePath.addExpense),
          ),
        ],
      ),
      child: CustomAdaptivePageView(
        pageController: _pageController,
        forceShowSmallTabBar: _selectedTransactions.isNotEmpty,
        smallTabBar: SmallTabBar(
          showSecondChild: _selectedTransactions.isNotEmpty,
          firstChild: PageHeading(
            title: widget.regularAccount.name,
            secondaryTitle: context.loc.regularAccount,
          ),
          secondChild: MultiSelectionTab(
            selectedTransactions: _selectedTransactions,
            backgroundColor: widget.regularAccount.backgroundColor,
            onClear: () => setState(() {
              _clearAllSelection();
            }),
            onConfirmDelete: () => setState(() {
              final removeList = _transactionRepository.deleteTransactions(_selectedTransactions);
              _clearAllSelection();
              if (removeList.isNotEmpty) {
                showCustomDialog(
                  context: context,
                  isTopNavigation: true,
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
          overlayColor: context.appTheme.isDarkTheme ? widget.regularAccount.iconColor : null,
          backgroundColor: widget.regularAccount.backgroundColor.addDark(context.appTheme.isDarkTheme ? 0.3 : 0.0),
          child: ExtendedRegularAccountTab(account: widget.regularAccount, displayDate: _currentDisplayDate),
        ),
        onDragLeft: _previousPage,
        onDragRight: _nextPage,
        onPageChanged: _onPageChange,
        toolBar: CustomPageToolBar(
          displayDate: _currentDisplayDate,
          onTapLeft: _previousPage,
          onTapRight: _nextPage,
          onDateTap: () => _animatedToPage(_initialPageIndex),
          topTitle: _currentDisplayDate.year.toString(),
          title: _currentDisplayDate.monthToString(context),
        ),
        toolBarBuilder: (pageIndex) {
          DateTime date = DateTime(Calendar.minDate.year, pageIndex);
          return CustomPageToolBar(
            displayDate: date,
            onDateTap: () => _animatedToPage(_initialPageIndex),
            topTitle: date.year.toString(),
            title: date.monthToString(context),
          );
        },
        itemBuilder: (context, ref, pageIndex) {
          DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
          DateTime dayEndOfMonth = DateTime(Calendar.minDate.year, pageIndex + 1, 0, 23, 59, 59);

          List<BaseTransaction> transactionList =
              _transactionRepository.getTransactionsOfAccount(widget.regularAccount, dayBeginOfMonth, dayEndOfMonth);

          ref.listen(transactionsChangesStreamProvider, (_, __) {
            transactionList =
                _transactionRepository.getTransactionsOfAccount(widget.regularAccount, dayBeginOfMonth, dayEndOfMonth);
            setState(() {});
          });

          return _buildTransactionWidgetList(transactionList, dayBeginOfMonth, dayEndOfMonth);
        },
      ),
    );
  }
}
