import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_page/expanded_page_view.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'custom_tab_bar.dart';

part 'custom_adaptive_page_view.dart';

////////////////////////////////////////////////////////////////////////

class CustomPage extends ConsumerStatefulWidget {
  const CustomPage({
    super.key,
    required this.smallTabBar,
    this.children = const [],
  });
  final SmallTabBar smallTabBar;
  final List<Widget> children;

  @override
  ConsumerState<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends ConsumerState<CustomPage> with TickerProviderStateMixin {
  late final double _triggerDividerAtListOffset = 30;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    _fadeController = AnimationController(vsync: this, duration: k250msDuration);
    _fadeAnimation = _fadeController.drive(CurveTween(curve: Curves.easeInOut));

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(systemIconBrightnessProvider.notifier).state = context.appTheme.systemIconBrightnessOnSmallTabBar;
    });
    super.initState();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  late bool _showDivider = false;

  void _onOffsetChange(double offset) {
    if (offset >= _triggerDividerAtListOffset && _showDivider == false) {
      _fadeController.forward(from: 0);
      _showDivider = true;
    }

    if (offset < _triggerDividerAtListOffset && _showDivider == true) {
      _fadeController.reverse(from: 1);
      _showDivider = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.background1,
      body: Stack(
        children: [
          _CustomListView(
            smallTabBar: widget.smallTabBar,
            onOffsetChange: (value) => _onOffsetChange(value),
            children: [
              ...widget.children,
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 32,
              )
            ],
          ),
          AnimatedBuilder(
              animation: _fadeAnimation,
              child: widget.smallTabBar,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: widget.smallTabBar.height == 0
                        ? null
                        : Border(
                            bottom: !context.appTheme.isDarkTheme
                                ? BorderSide(color: Colors.grey.shade300.withOpacity(_fadeAnimation.value), width: 1.5)
                                : BorderSide.none,
                          ),
                  ),
                  child: child,
                );
              }),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class _CustomListView extends ConsumerStatefulWidget {
  const _CustomListView({
    this.noPersistentSmallTabBar = false,
    this.controller,
    this.smallTabBar,
    this.extendedTabBar,
    this.children = const [],
    this.onOffsetChange,
  });

  final bool noPersistentSmallTabBar;
  final ScrollController? controller;
  final SmallTabBar? smallTabBar;
  final ExtendedTabBar? extendedTabBar;
  final List<Widget> children;
  final ValueChanged<double>? onOffsetChange;

  @override
  ConsumerState<_CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends ConsumerState<_CustomListView> {
  late final ScrollController _scrollController =
      widget.controller ?? ScrollController(); // ScrollController used for ListView

  double scrollPixelsOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollControllerListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollControllerListener);
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _scrollControllerListener() {
    ScrollPosition position = _scrollController.position;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollPixelsOffset = position.pixels;
      widget.onOffsetChange?.call(scrollPixelsOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.noPersistentSmallTabBar ? widget.children.length : widget.children.length + 2,
      padding: const EdgeInsets.only(top: 25),
      itemBuilder: (context, index) {
        if (!widget.noPersistentSmallTabBar) {
          if (index == 0) {
            return SizedBox(height: widget.smallTabBar?.height);
          }
          if (index == widget.children.length + 1) {
            return const SizedBox(height: 30);
          } else {
            return widget.children[index - 1];
          }
        }

        return widget.children[index];
      },
    );
  }
}

final systemIconBrightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);
