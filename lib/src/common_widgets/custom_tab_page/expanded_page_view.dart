import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../utils/constants.dart';

class ExpandablePageView extends StatefulWidget {
  final int? itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final bool reverse;

  const ExpandablePageView({
    this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.onPageChanged,
    this.reverse = false,
    super.key,
  });

  @override
  State<ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  PageController? _pageController;
  //List<double> _heights = [];
  late int _currentPage;
  final Map<int, double> _heights = {};

  double get _currentHeight => _heights[_currentPage] != null
      ? math.max(Gap.screenHeight(context) - kExtendedCustomTabBarHeight, _heights[_currentPage]!)
      : Gap.screenHeight(context);

  @override
  void initState() {
    super.initState();
    _pageController = widget.controller ?? PageController();
    _currentPage = _pageController?.initialPage ?? 0;
    _pageController?.addListener(_updatePage);
  }

  @override
  void dispose() {
    _pageController?.removeListener(_updatePage);
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      tween: Tween<double>(begin: 0, end: _currentHeight),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.itemCount,
        itemBuilder: _itemBuilder,
        onPageChanged: widget.onPageChanged,
        reverse: widget.reverse,
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final item = widget.itemBuilder(context, index);
    return OverflowBox(
      minHeight: 0,
      maxHeight: double.infinity,
      alignment: Alignment.topCenter,
      child: SizeReportingWidget(
        onSizeChange: (size) {
          setState(() => _heights[index] = size.height);
        },
        child: item,
      ),
    );
  }

  void _updatePage() {
    final newPage = _pageController?.page?.round();
    if (_currentPage != newPage) {
      setState(() {
        _currentPage = newPage ?? _currentPage;
      });
    }
  }
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    required this.child,
    required this.onSizeChange,
    super.key,
  });

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (mounted) {
      final size = context.size;
      if (_oldSize != size) {
        _oldSize = size;
        if (size != null) widget.onSizeChange(size);
      }
    }
  }
}
