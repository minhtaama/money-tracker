import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_page.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/custom_tab_bar.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/carousel.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../utils/constants.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _monthCarouselKey = GlobalKey<_MonthCarouselState>();
  final _today = DateTime.now().onlyYearMonthDay;

  late List<DateTime> _selectedDateTimes = [_today];
  _ReportType _type = _ReportType.month;

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      smallTabBar: SmallTabBar(
        child: PageHeading(
          title: 'Reports'.hardcoded,
          isTopLevelOfNavigationRail: true,
        ),
      ),
      children: [
        _dateSelector(),
      ],
    );
  }

  Widget _dateSelector() => CustomBox(
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    hide: _type != _ReportType.month || _selectedDateTimes.first.isSameMonthAs(_today),
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
                      fontSize: 14,
                      labels: ['Monthly'.hardcoded, 'Custom range'.hardcoded],
                      onTap: (type) => setState(() {
                        _type = type;
                        _selectedDateTimes = [_selectedDateTimes.first];
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
                onMonthChange: (dateTime) => setState(() {
                  _selectedDateTimes = [dateTime];
                }),
              ),
              secondChild: Column(
                children: [
                  CustomCalendar(
                    onValueChanged: (list) => setState(() {
                      _selectedDateTimes = list.whereType<DateTime>().toSet().toList();
                    }),
                    displayedMonthDate: _selectedDateTimes.last,
                    value: _selectedDateTimes,
                    calendarType: CalendarDatePicker2Type.range,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedDateTimes.first.toLongDate(context),
                        style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
                      ),
                      _selectedDateTimes.length > 1
                          ? Text(
                              ' - ${_selectedDateTimes.last.toLongDate(context)}',
                              style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
                            )
                          : Gap.noGap,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

////////////////

class _MonthCarousel extends StatefulWidget {
  const _MonthCarousel({
    super.key,
    required this.onMonthChange,
  });

  final void Function(DateTime dateTime) onMonthChange;

  @override
  State<_MonthCarousel> createState() => _MonthCarouselState();
}

class _MonthCarouselState extends State<_MonthCarousel> {
  late final DateTime _today = DateTime.now().onlyYearMonthDay;

  late final int _initialPageIndex = _today.getMonthsDifferent(Calendar.minDate);

  late final PageController _carouselController =
      PageController(initialPage: _initialPageIndex, viewportFraction: kMoneyCarouselViewFraction - 0.2);

  late DateTime _currentDisplayDate = _today;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onMonthChange(_currentDisplayDate);
    });

    super.initState();
  }

  void _onPageChange(int value) {
    _currentDisplayDate = DateTime(_today.year, _today.month + (value - _initialPageIndex));
    widget.onMonthChange(_currentDisplayDate);
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

////////////////////

enum _ReportType {
  month,
  range,
}
