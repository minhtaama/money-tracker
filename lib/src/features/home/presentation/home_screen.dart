import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/small_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/transactions//presentation/homepage_card.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../common_widgets/card_item.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page_with_page_view.dart';
import '../../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _controller;

  late DateTime _currentDate;
  late int _currentIndex;

  late DateTime _displayDate;

  late bool _showCurrentDateButton;

  DateTime? _minDate;

  DateTime? _maxDate;

  @override
  void initState() {
    _currentDate = DateTime.now().onlyYearMonth;
    _currentIndex = _currentDate.getMonthsDifferent(Calendar.minDate);

    _controller = PageController(initialPage: _currentIndex);

    _displayDate = _currentDate;

    _showCurrentDateButton = false;

    super.initState();
  }

  void _onPageChange(int value) {
    _displayDate = DateTime(_currentDate.year, _currentDate.month + (value - _currentIndex));
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
    if (_displayDate.year == _currentDate.year && _displayDate.month == _currentDate.month) {
      _showCurrentDateButton = false;
    } else {
      _showCurrentDateButton = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTabPageWithPageView(
      controller: _controller,
      extendedTabBar: ExtendedTabBar(
        innerChild: const ExtendedHomeTab(),
        outerChild: DateSelector(
          dateDisplay: '${_displayDate.monthToString()}, ${_displayDate.year}',
          onTapLeft: _previousPage,
          onTapRight: _nextPage,
          onTapGoToCurrentDate: () {
            _animatedToPage(_currentIndex);
          },
          showGoToCurrentDateButton: _showCurrentDateButton,
        ),
      ),
      smallTabBar: const SmallTabBar(
        child: SmallHomeTab(),
      ),
      onPageChanged: _onPageChange,
      listItemCount: 2,
      itemBuilder: (context, pageIndex, listIndex) {
        if (listIndex == 0) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const [
                Expanded(child: IncomeExpenseCard(isIncome: true)),
                Expanded(child: IncomeExpenseCard(isIncome: false)),
              ],
            ),
          );
        } else {
          return Text(pageIndex.toString());
          // TODO: Show transactions in month depends on pageIndex
        }
      },
    );
  }
}

class IncomeExpenseCard extends StatelessWidget {
  const IncomeExpenseCard({
    super.key,
    required this.isIncome,
  });

  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CardItem(
        color: context.appTheme.isDarkTheme
            ? context.appTheme.background3
            : isIncome
                ? context.appTheme.primary
                : context.appTheme.accent,
        isGradient: true,
        width: double.infinity,
        height: 100,
        child: Text(
          isIncome ? 'Income' : 'Expense',
          style: kHeader2TextStyle.copyWith(
              color: context.appTheme.isDarkTheme
                  ? context.appTheme.backgroundNegative
                  : isIncome
                      ? context.appTheme.primaryNegative
                      : context.appTheme.accentNegative,
              fontSize: 20),
        ),
      ),
    );
  }
}
