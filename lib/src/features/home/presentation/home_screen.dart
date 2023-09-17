import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/small_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/day_card.dart';
import 'package:money_tracker_app/src/features/home/summary_card.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../../persistent/isar_data_store.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../transactions/domain/transaction.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final isar = ref.read(isarProvider);
  late final transactionRepository = ref.read(transactionRepositoryProvider);

  late final PageController _controller;

  final DateTime _today = DateTime.now().onlyYearMonth;
  late final int _indexToday = _today.getMonthsDifferent(Calendar.minDate);

  late DateTime _displayDate;

  late bool _showCurrentDateButton;

  // TODO: Save this to settings repo
  late bool _hideTotalBalance = false;

  // DateTime? _minDate;
  //
  // DateTime? _maxDate;

  @override
  void initState() {
    _controller = PageController(initialPage: _indexToday);
    _displayDate = _today;
    _showCurrentDateButton = false;

    super.initState();
  }

  void _onPageChange(int value) {
    _displayDate = DateTime(_today.year, _today.month + (value - _indexToday));
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
    if (_displayDate.year == _today.year && _displayDate.month == _today.month) {
      _showCurrentDateButton = false;
    } else {
      _showCurrentDateButton = true;
    }
  }

  List<DayCard> _buildTransactionWidgetList(
    List<Transaction> transactionList,
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
            onTransactionTap: (transaction) => context.push(RoutePath.transaction, extra: transaction),
          ),
        );
      }
    }
    return dayCards;
  }

  @override
  Widget build(BuildContext context) {
    return CustomTabPageWithPageView(
      controller: _controller,
      smallTabBar: SmallTabBar(
        child: SmallHomeTab(
          secondaryTitle: _displayDate.getFormattedDate(type: DateTimeType.ddmmmmyyyy, hasDay: false),
          hideNumber: _hideTotalBalance,
          onEyeTap: () => setState(() => _hideTotalBalance = !_hideTotalBalance),
        ),
      ),
      extendedTabBar: ExtendedTabBar(
        innerChild: ExtendedHomeTab(
          hideNumber: _hideTotalBalance,
          onEyeTap: () => setState(() => _hideTotalBalance = !_hideTotalBalance),
        ),
        outerChild: DateSelector(
          dateDisplay: _displayDate.getFormattedDate(type: DateTimeType.ddmmmmyyyy, hasDay: false),
          onTapLeft: _previousPage,
          onTapRight: _nextPage,
          onTapGoToCurrentDate: () {
            _animatedToPage(_indexToday);
          },
          showGoToCurrentDateButton: _showCurrentDateButton,
        ),
      ),
      onDragLeft: _previousPage,
      onDragRight: _nextPage,
      onPageChanged: _onPageChange,
      itemBuilder: (context, pageIndex) {
        DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
        DateTime dayEndOfMonth = DateTime(Calendar.minDate.year, pageIndex + 1, 0, 23, 59, 59);

        List<Transaction> transactionList = transactionRepository.getAll(dayBeginOfMonth, dayEndOfMonth);

        ref.listenManual(databaseChangesProvider, (_, __) {
          transactionList = transactionRepository.getAll(dayBeginOfMonth, dayEndOfMonth);
          setState(() {});
        });

        return [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: SummaryCard(isIncome: true)),
                Expanded(child: SummaryCard(isIncome: false)),
              ],
            ),
          ),
          ..._buildTransactionWidgetList(transactionList, dayBeginOfMonth, dayEndOfMonth),
        ];
      },
    );
  }
}
