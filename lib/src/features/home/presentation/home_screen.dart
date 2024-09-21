import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_page_tool_bar.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/small_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/day_card.dart';
import 'package:money_tracker_app/src/features/recurrence/data/recurrence_repo.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/data/persistent_repo.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_page/custom_page.dart';
import '../../../common_widgets/illustration.dart';
import '../../../common_widgets/rounded_icon_button.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../recurrence/domain/recurrence.dart';
import '../../transactions/domain/transaction_base.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final _transactionRepository = ref.read(transactionRepositoryRealmProvider);
  late final _recurrenceRepository = ref.read(recurrenceRepositoryRealmProvider);
  late final _persistentController = ref.read(persistentControllerProvider.notifier);

  late final PageController _pageController = PageController(initialPage: _initialPageIndex);
  late final PageController _carouselController =
      PageController(initialPage: _initialPageIndex, viewportFraction: kMoneyCarouselViewFraction);

  late final DateTime _today = DateTime.now().onlyYearMonth;
  late final int _initialPageIndex = _today.getMonthsDifferent(Calendar.minDate);
  late DateTime _currentDisplayDate = _today;

  late final _forcePageView = context.appSettings.homescreenType == HomescreenType.pageView;

  final List<BaseTransaction> _selectedTransactions = [];

  void _clearAllSelection() {
    _selectedTransactions.clear();
  }

  void _onPageChange(int value) {
    if (!context.isBigScreen && !_forcePageView) {
      _carouselController.animateToPage(value, duration: k350msDuration, curve: Curves.easeOut);
    }

    setState(() {
      _currentDisplayDate = DateTime(_today.year, _today.month + (value - _initialPageIndex));
    });
  }

  void _previousPage() {
    _pageController.previousPage(duration: k250msDuration, curve: Curves.easeOut);

    if (!context.isBigScreen && !_forcePageView) {
      _carouselController.previousPage(duration: k250msDuration, curve: Curves.easeOut);
    }
  }

  void _nextPage() {
    _pageController.nextPage(duration: k250msDuration, curve: Curves.easeOut);

    if (!context.isBigScreen && !_forcePageView) {
      _carouselController.nextPage(duration: k250msDuration, curve: Curves.easeOut);
    }
  }

  void _animatedToPage(int page) {
    _pageController.animateToPage(page, duration: k350msDuration, curve: Curves.easeOut);

    if (!context.isBigScreen && !_forcePageView) {
      _carouselController.animateToPage(page, duration: k350msDuration, curve: Curves.easeOut);
    }
  }

  // TODO: filter
  // DateTime? _minDate;
  //
  // DateTime? _maxDate;

  @override
  void dispose() {
    _pageController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  List<Widget> _buildDayCards(
    List<BaseTransaction> transactionList,
    List<TransactionData> plannedTransactions,
    DateTime dayBeginOfMonth,
    DateTime dayEndOfMonth,
  ) {
    final List<DayCard> dayCards = [];

    for (int day = dayEndOfMonth.day; day >= dayBeginOfMonth.day; day--) {
      final transactionsInDay = transactionList.where((transaction) => transaction.dateTime.day == day).toList();
      final plannedTxnsInDay = plannedTransactions
          .where(
            (plannedTxn) =>
                (plannedTxn.state == PlannedState.today || plannedTxn.state == PlannedState.overdue) &&
                plannedTxn.dateTime!.day == day,
          )
          .toList();

      if (transactionsInDay.isNotEmpty || plannedTxnsInDay.isNotEmpty) {
        dayCards.add(
          DayCard(
            dateTime: dayBeginOfMonth.copyWith(day: day),
            transactions: transactionsInDay.reversed.toList(),
            plannedTransactions: plannedTxnsInDay.reversed.toList(),
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
    bool showTotalBalance = context.appPersistentValues.showAmount;

    return CustomAdaptivePageView(
      pageController: _pageController,
      forcePageView: _forcePageView,
      forceShowSmallTabBar: _selectedTransactions.isNotEmpty,
      smallTabBar: SmallTabBar(
        showSecondChild: _selectedTransactions.isNotEmpty,
        firstChild: SmallHomeTab(
          secondaryTitle: _currentDisplayDate.toLongDate(context, noDay: true),
          showNumber: showTotalBalance,
          onEyeTap: () {
            setState(() => showTotalBalance = !showTotalBalance);
            _persistentController.set(showAmount: showTotalBalance);
          },
        ),
        secondChild: MultiSelectionTab(
          selectedTransactions: _selectedTransactions,
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
        overlayColor: context.appTheme.isDarkTheme ? context.appTheme.accent1 : null,
        child: ExtendedHomeTab(
          carouselController: _carouselController,
          initialPageIndex: _initialPageIndex,
          displayDate: _currentDisplayDate,
          showNumber: showTotalBalance,
          onEyeTap: () {
            setState(() => showTotalBalance = !showTotalBalance);
            _persistentController.set(showAmount: showTotalBalance);
          },
        ),
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
        optionalButton: RoundedIconButton(
          iconPath: AppIcons.recurrenceBulk,
          iconColor: context.appTheme.onBackground,
          backgroundColor: Colors.transparent,
          onTap: () => context.push(RoutePath.plannedTransactions, extra: _currentDisplayDate),
          size: 33,
          iconPadding: 5,
        ),
      ),
      toolBarBuilder: (pageIndex) {
        DateTime date = DateTime(Calendar.minDate.year, pageIndex);
        return CustomPageToolBar(
          displayDate: date,
          onDateTap: () => _animatedToPage(_initialPageIndex),
          topTitle: date.year.toString(),
          title: date.monthToString(context),
          optionalButton: RoundedIconButton(
            iconPath: AppIcons.recurrenceBulk,
            iconColor: context.appTheme.onBackground,
            backgroundColor: Colors.transparent,
            onTap: () => context.push(RoutePath.plannedTransactions, extra: _currentDisplayDate),
            size: 33,
            iconPadding: 5,
          ),
        );
      },
      itemBuilder: (context, ref, pageIndex) {
        DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
        DateTime dayEndOfMonth = DateTime(Calendar.minDate.year, pageIndex + 1, 0, 23, 59, 59);

        List<BaseTransaction> transactionList = _transactionRepository.getTransactions(dayBeginOfMonth, dayEndOfMonth);
        List<TransactionData> plannedTransactions =
            _recurrenceRepository.getPlannedTransactionsInMonth(context, dayBeginOfMonth);

        ref.listen(transactionsChangesStreamProvider, (_, __) {
          setState(() {
            transactionList = _transactionRepository.getTransactions(dayBeginOfMonth, dayEndOfMonth);
          });
        });

        ref.listen(recurrenceChangesStreamProvider, (_, __) {
          setState(() {
            plannedTransactions = _recurrenceRepository.getPlannedTransactionsInMonth(context, dayBeginOfMonth);
          });
        });

        return _buildDayCards(transactionList, plannedTransactions, dayBeginOfMonth, dayEndOfMonth);
      },
    );
  }
}
