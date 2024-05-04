import 'package:flutter/material.dart';
import 'dart:math' as math;

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

  late int _currentPage;

  final Map<int, double> _heights = {};

  late final _sheetViewPort = Gap.screenHeight(context) - kCustomTabBarHeight - kCustomToolBarHeight;

  double get _currentHeight => _heights[_currentPage] != null
      ? math.max(_sheetViewPort, _heights[_currentPage]!)
      : _sheetViewPort;

  @override
  void initState() {
    super.initState();
    _pageController = widget.controller ?? PageController();
    _currentPage = _pageController?.initialPage ?? 0;
    _pageController?.addListener(_updatePage);
  }

  @override
  void didUpdateWidget(covariant ExpandablePageView oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageController?.removeListener(_updatePage);
    if (widget.controller == null) {
      _pageController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      tween: Tween<double>(begin: _sheetViewPort, end: _currentHeight),
      duration: k350msDuration,
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
          _heights[index] = size.height;
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
  void didUpdateWidget(covariant SizeReportingWidget oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    super.didUpdateWidget(oldWidget);
  }

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
