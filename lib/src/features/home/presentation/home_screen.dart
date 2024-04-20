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
import '../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_page/custom_page.dart';
import '../../../common_widgets/icon_with_text.dart';
import '../../../common_widgets/rounded_icon_button.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
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
      final transactionsInDay = transactionList.where((transaction) => transaction.dateTime.day == day).toList();

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: IconWithText(
            header: context.localize.noTransactionQuote(dayBeginOfMonth.monthToString(context)),
            headerSize: 14,
            iconPath: AppIcons.budgets,
            forceIconOnTop: true,
          ),
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
      controller: _pageController,
      smallTabBar: SmallTabBar(
        child: SmallHomeTab(
          secondaryTitle: _currentDisplayDate.toLongDate(context, noDay: true),
          showNumber: showTotalBalance,
          onEyeTap: () {
            setState(() => showTotalBalance = !showTotalBalance);
            persistentController.set(showAmount: showTotalBalance);
          },
        ),
      ),
      extendedTabBar: ExtendedTabBar(
        child: ExtendedHomeTabForScrollableSheet(
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
      toolBar: _DateSelector(
        displayDate: _currentDisplayDate,
        onTapLeft: _previousPage,
        onTapRight: _nextPage,
        onDateTap: () => _animatedToPage(_initialPageIndex),
      ),
      itemBuilder: (context, ref, pageIndex) {
        DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
        DateTime dayEndOfMonth = DateTime(Calendar.minDate.year, pageIndex + 1, 0, 23, 59, 59);

        List<BaseTransaction> transactionList = transactionRepository.getTransactions(dayBeginOfMonth, dayEndOfMonth);

        ref.listen(transactionsChangesStreamProvider, (_, __) {
          transactionList = transactionRepository.getTransactions(dayBeginOfMonth, dayEndOfMonth);
          setState(() {});
        });

        return _buildTransactionWidgetList(transactionList, dayBeginOfMonth, dayEndOfMonth);
      },
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    super.key,
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
    bool today = displayDate.onlyYearMonth.isAtSameMomentAs(DateTime.now().onlyYearMonth);

    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Gap.w24,
          Expanded(
            child: GestureDetector(
              onTap: onDateTap,
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
                child: Row(
                  key: ValueKey(displayDate.toLongDate(context, noDay: true)),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Text(
                            displayDate.year.toString(),
                            style: kHeader3TextStyle.copyWith(
                              color: context.appTheme.onBackground.withOpacity(0.9),
                              fontSize: 13,
                              letterSpacing: 0.5,
                              height: 0.99,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              displayDate.monthToString(context),
                              style: kHeader1TextStyle.copyWith(
                                color: context.appTheme.onBackground.withOpacity(0.9),
                                fontSize: 22,
                                letterSpacing: 0.6,
                                height: 1.2,
                              ),
                            ),
                            Gap.w8,
                            !today
                                ? Transform.translate(
                                    offset: const Offset(0, 2),
                                    child: RoundedIconButton(
                                      iconPath: AppIcons.turn,
                                      iconColor: context.appTheme.onBackground,
                                      backgroundColor: Colors.transparent,
                                      size: 20,
                                      iconPadding: 0,
                                    ),
                                  )
                                : Gap.noGap,
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          RoundedIconButton(
            iconPath: AppIcons.arrowLeft,
            iconColor: context.appTheme.onBackground,
            backgroundColor: Colors.transparent,
            onTap: onTapLeft,
            size: 30,
            iconPadding: 5,
          ),
          Gap.w24,
          RoundedIconButton(
            iconPath: AppIcons.arrowRight,
            iconColor: context.appTheme.onBackground,
            backgroundColor: Colors.transparent,
            onTap: onTapRight,
            size: 30,
            iconPadding: 5,
          ),
          Gap.w16,
        ],
      ),
    );
  }
}
