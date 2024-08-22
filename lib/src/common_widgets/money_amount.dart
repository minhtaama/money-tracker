import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/widgets.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class MoneyAmount extends StatefulWidget {
  final double? amount;
  final Curve curve;
  final Duration duration;
  final TextStyle? style;
  final TextStyle? symbolStyle;
  final bool noAnimation;
  final TextOverflow overflow;
  final int? maxLines;
  final bool canHide;

  const MoneyAmount({
    super.key,
    required this.amount,
    this.curve = Curves.easeInOut,
    this.duration = k550msDuration,
    this.style,
    this.symbolStyle,
    this.noAnimation = false,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.canHide = false,
  });

  @override
  State<MoneyAmount> createState() => _MoneyAmountState();
}

class _MoneyAmountState extends State<MoneyAmount> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late final CurvedAnimation _curvedAnimation;

  double? _begin;
  double? _end;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _begin = widget.noAnimation ? widget.amount : 0;
    _end = widget.amount;
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _curvedAnimation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _animation = Tween<double>(begin: _begin, end: _end).animate(_curvedAnimation);

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant MoneyAmount oldWidget) {
    if (oldWidget.amount != widget.amount) {
      if (widget.amount != _end) {
        _controller.reset();
      }

      setState(() {
        _begin = oldWidget.amount;
        _end = widget.amount;
        _animation = Tween<double>(begin: _begin, end: _end).animate(_curvedAnimation);
      });
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final symbolBefore = context.appSettings.currencyType == CurrencyType.symbolBefore;
    final symbol = context.appSettings.currency.symbol;

    if (widget.amount == null) {
      final inlineSpan = <InlineSpan>[
        TextSpan(text: symbolBefore ? '$symbol ' : ''),
        TextSpan(
          text: '----',
          style: widget.style?.copyWith(letterSpacing: 2),
        ),
        TextSpan(text: !symbolBefore ? ' $symbol' : ''),
      ];

      return RichText(
        text: TextSpan(
          children: inlineSpan,
          style: widget.symbolStyle ?? widget.style?.copyWith(letterSpacing: 2),
        ),
        overflow: widget.overflow,
        maxLines: widget.maxLines,
        softWrap: false,
      );
    }

    return _MoneyAnimatedText(
      animation: _animation,
      style: widget.style,
      symbolStyle: widget.symbolStyle,
      prefix: symbolBefore ? symbol : null,
      suffix: !symbolBefore ? symbol : null,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      canHide: widget.canHide,
    );
  }
}

class _MoneyAnimatedText extends AnimatedWidget {
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  final Animation<double> animation;
  final TextStyle? style;
  final TextStyle? symbolStyle;
  final String? prefix;
  final String? suffix;
  final TextOverflow overflow;
  final int? maxLines;
  final bool canHide;

  _MoneyAnimatedText({
    required this.animation,
    this.style,
    this.symbolStyle,
    this.prefix,
    this.suffix,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.canHide = false,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final inlineSpan = <InlineSpan>[
      TextSpan(text: prefix != null ? '$prefix ' : null),
      TextSpan(
        text: CalService.formatCurrency(context, animation.value, canHide: canHide),
        style: style,
      ),
      TextSpan(text: suffix != null ? ' $suffix' : null),
    ];

    return RichText(
      text: TextSpan(
        children: inlineSpan,
        style: symbolStyle ?? style,
      ),
      overflow: overflow,
      maxLines: maxLines,
      softWrap: false,
    );
  }
}
