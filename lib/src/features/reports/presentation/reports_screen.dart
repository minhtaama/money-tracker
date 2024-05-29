import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_page.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_tab_bar.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/illustration.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/carousel.dart';
import 'package:money_tracker_app/src/features/reports/presentation/daily_report_widget.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../routing/app_router.dart';
import '../../../utils/constants.dart';
import '../../home/presentation/day_card.dart';
import '../../transactions/domain/transaction_base.dart';
import 'categories_report_widget.dart';

part 'components.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _monthCarouselKey = GlobalKey<_MonthCarouselState>();
  final _todayMonth = DateTime.now().onlyYearMonthDay.monthRange;

  late List<DateTime> _selectedDateTimes = [_todayMonth.start, _todayMonth.end];
  _ReportType _type = _ReportType.month;

  bool _hideDateSelector = true;

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      smallTabBar: SmallTabBar(
        optional: HideableContainer(
          hide: _hideDateSelector,
          child: _dateSelector(),
        ),
        child: PageHeading(
          title: 'Reports'.hardcoded,
          isTopLevelOfNavigationRail: true,
          trailing: RotatedBox(
            quarterTurns: _hideDateSelector ? 1 : -1,
            child: RoundedIconButton(
              iconPath: AppIcons.arrowRight,
              onTap: () => setState(() {
                _hideDateSelector = !_hideDateSelector;
              }),
            ),
          ),
          secondaryTitle: _date(),
        ),
      ),
      children: [
        Gap.h24,
        CategoryReport(
          key: const ValueKey('CategoryReport'),
          dateTimes: _selectedDateTimes,
        ),
        Gap.h24,
        DailyReportWidget(
          key: const ValueKey('DailyReport'),
          dateTimes: _selectedDateTimes,
        ),
      ],
    );
  }

  Widget _dateSelector() => CustomBox(
        key: const ValueKey('_dateSelector'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: context.appTheme.background1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  HideableContainer(
                    hide: _type != _ReportType.month || _selectedDateTimes.first.isSameMonthAs(_todayMonth.start),
                    axis: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: RoundedIconButton(
                        iconPath: AppIcons.turn,
                        iconColor: context.appTheme.onPrimary,
                        backgroundColor: context.appTheme.primary.withOpacity(0.95),
                        size: 31,
                        iconPadding: 6,
                        onTap: () {
                          _monthCarouselKey.currentState!._animateToToday();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomSliderToggle<_ReportType>(
                      values: const [_ReportType.month, _ReportType.range],
                      height: 35,
                      initialValueIndex: [_ReportType.month, _ReportType.range].indexOf(_type),
                      fontSize: 14,
                      labels: ['Monthly'.hardcoded, 'Custom range'.hardcoded],
                      onTap: (type) => setState(() {
                        _type = type;
                      }),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: k350msDuration,
              sizeCurve: Curves.easeOut,
              crossFadeState: _type == _ReportType.month ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: _MonthCarousel(
                key: _monthCarouselKey,
                onMonthChange: (dateTimeList) => setState(() {
                  _selectedDateTimes = dateTimeList;
                }),
              ),
              secondChild: CustomCalendar(
                onValueChanged: (list) => setState(() {
                  _selectedDateTimes = list.whereType<DateTime>().toSet().toList();
                }),
                displayedMonthDate: _selectedDateTimes.last,
                value: _selectedDateTimes,
                calendarType: CalendarDatePicker2Type.range,
              ),
            ),
          ],
        ),
      );

  String _date() =>
      '${_selectedDateTimes.first.toLongDate(context)}${_selectedDateTimes.length > 1 ? ' - ${_selectedDateTimes.last.toLongDate(context)}' : ''}';
}

class _MonthCarousel extends StatefulWidget {
  const _MonthCarousel({
    super.key,
    required this.onMonthChange,
  });

  final void Function(List<DateTime> dateTime) onMonthChange;

  @override
  State<_MonthCarousel> createState() => _MonthCarouselState();
}

class _MonthCarouselState extends State<_MonthCarousel> {
  late final DateTime _today = DateTime.now().onlyYearMonthDay;

  late final int _initialPageIndex = _today.getMonthsDifferent(Calendar.minDate);

  late final PageController _carouselController =
      PageController(initialPage: _initialPageIndex, viewportFraction: kMoneyCarouselViewFraction - 0.2);

  late DateTime _currentDisplayDate = _today;

  void _onPageChange(int value) {
    _currentDisplayDate = DateTime(_today.year, _today.month + (value - _initialPageIndex));
    final range = _currentDisplayDate.monthRange;
    widget.onMonthChange([range.start, range.end]);
  }

  void _animateToToday() {
    _carouselController.animateToPage(_initialPageIndex, duration: k250msDuration, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return TextCarousel(
      controller: _carouselController,
      initialPageIndex: _initialPageIndex,
      onPageChanged: _onPageChange,
      textBuilder: (pageIndex) {
        DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
        return dayBeginOfMonth.monthToString(context);
      },
      subTextBuilder: (pageIndex) {
        DateTime dayBeginOfMonth = DateTime(Calendar.minDate.year, pageIndex);
        return dayBeginOfMonth.year.toString();
      },
    );
  }
}

enum _ReportType {
  month,
  range,
}
