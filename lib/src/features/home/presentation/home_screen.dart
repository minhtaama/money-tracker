import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/small_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/day_card.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/data/persistent_repo.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../common_widgets/icon_with_text.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../transactions/domain/transaction_base.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final transactionRepository = ref.read(transactionRepositoryRealmProvider);
  late final persistentController = ref.read(persistentControllerProvider.notifier);

  late final PageController _pageController = PageController(initialPage: _initialPageIndex);
  late final PageController _carouselController =
      PageController(initialPage: _initialPageIndex, viewportFraction: kMoneyCarouselViewFraction);

  late final DateTime _today = DateTime.now().onlyYearMonth;
  late final int _initialPageIndex = _today.getMonthsDifferent(Calendar.minDate);

  //late int _currentPageIndex = _initialPageIndex;
  late DateTime _currentDisplayDate = _today;

  // TODO: filter
  // DateTime? _minDate;
  //
  // DateTime? _maxDate;

  void _onPageChange(int value) {
    _carouselController.animateToPage(value, duration: k350msDuration, curve: Curves.easeOut);
    setState(() {
      _currentDisplayDate = DateTime(_today.year, _today.month + (value - _initialPageIndex));
    });
  }

  void _previousPage() {
    _pageController.previousPage(duration: k250msDuration, curve: Curves.easeOut);
    _carouselController.previousPage(duration: k250msDuration, curve: Curves.easeOut);
  }

  void _nextPage() {
    _pageController.nextPage(duration: k250msDuration, curve: Curves.easeOut);
    _carouselController.nextPage(duration: k250msDuration, curve: Curves.easeOut);
  }

  void _animatedToPage(int page) {
    _pageController.animateToPage(page, duration: k350msDuration, curve: Curves.easeOut);
    _carouselController.animateToPage(page, duration: k350msDuration, curve: Curves.easeOut);
  }

  List<Widget> _buildTransactionWidgetList(
    List<BaseTransaction> transactionList,
    DateTime dayBeginOfMonth,
    DateTime dayEndOfMonth,
  ) {
    final List<DayCard> dayCards = [];

    for (int day = dayEndOfMonth.day; day >= dayBeginOfMonth.day; day--) {
      final transactionsInDay =
          transactionList.where((transaction) => transaction.dateTime.day == day).toList();

      if (transactionsInDay.isNotEmpty) {
        dayCards.add(
          DayCard(
            dateTime: transactionsInDay[0].dateTime,
            transactions: transactionsInDay.reversed.toList(),
            onTransactionTap: (transaction) =>
                context.push(RoutePath.transaction, extra: transaction.databaseObject.id.hexString),
          ),
        );
      }
    }

    if (dayCards.isEmpty) {
      return [
        Gap.h16,
        IconWithText(
          header:
              'You don\'t have any transactions in ${dayBeginOfMonth.getFormattedDate(format: DateTimeFormat.ddmmmmyyyy, hasDay: false, hasYear: false)}.\nCreate a new one by tapping \'+\' button'
                  .hardcoded,
          headerSize: 14,
          iconPath: AppIcons.budgets,
          forceIconOnTop: true,
        ),
        Gap.h48,
      ];
    }

    return dayCards;
  }

  @override
  Widget build(BuildContext context) {
    bool showTotalBalance = context.appPersistentValues.showAmount;

    return CustomTabPageWithPageView(
      controller: _pageController,
      smallTabBar: SmallTabBar(
        child: SmallHomeTab(
          secondaryTitle:
              _currentDisplayDate.getFormattedDate(format: DateTimeFormat.ddmmmmyyyy, hasDay: false),
          showNumber: showTotalBalance,
          onEyeTap: () {
            setState(() => showTotalBalance = !showTotalBalance);
            persistentController.set(showAmount: showTotalBalance);
          },
        ),
      ),
      extendedTabBar: ExtendedTabBar(
        toolBar: DateSelector(
          displayDate: _currentDisplayDate,
          onTapLeft: _previousPage,
          onTapRight: _nextPage,
          onDateTap: () => _animatedToPage(_initialPageIndex),
        ),
        child: ExtendedHomeTab(
          carouselController: _carouselController,
          initialPageIndex: _initialPageIndex,
          displayDate: _currentDisplayDate,
          showNumber: showTotalBalance,
          onEyeTap: () {
            setState(() => showTotalBalance = !showTotalBalance);
            persistentController.set(showAmount: showTotalBalance);
          },
        ),
      ),
      onDragLeft: _previousPage,
      onDragRight: _nextPage,
      onPageChanged: _onPageChange,
      itemBuilder: (context, ref, pageIndex) {
        DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
        DateTime dayEndOfMonth = DateTime(Calendar.minDate.year, pageIndex + 1, 0, 23, 59, 59);

        List<BaseTransaction> transactionList =
            transactionRepository.getTransactions(dayBeginOfMonth, dayEndOfMonth);

        ref.listen(transactionsChangesStreamProvider, (_, __) {
          transactionList = transactionRepository.getTransactions(dayBeginOfMonth, dayEndOfMonth);
          setState(() {});
        });

        return _buildTransactionWidgetList(transactionList, dayBeginOfMonth, dayEndOfMonth);
      },
    );
  }
}
