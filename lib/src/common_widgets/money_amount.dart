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
      return EasyRichText(
        '${symbolBefore ? symbol : ''} ---- ${!symbolBefore ? symbol : ''}',
        defaultStyle: widget.style?.copyWith(letterSpacing: 2),
        overflow: widget.overflow,
        maxLines: widget.maxLines,
        softWrap: false,
        patternList: [
          EasyRichTextPattern(
              targetString: symbolBefore ? symbol : '',
              hasSpecialCharacters: true,
              style: widget.symbolStyle,
              matchWordBoundaries: false),
          EasyRichTextPattern(
              targetString: !symbolBefore ? symbol : '',
              hasSpecialCharacters: true,
              style: widget.symbolStyle,
              matchWordBoundaries: false),
        ],
      );
    }

    return _MoneyAnimatedText(
      animation: _animation,
      style: widget.style,
      symbolStyle: widget.symbolStyle,
      prefix: symbolBefore ? symbol : '',
      suffix: !symbolBefore ? symbol : '',
      maxLines: widget.maxLines,
      overflow: widget.overflow,
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

  _MoneyAnimatedText({
    required this.animation,
    this.style,
    this.symbolStyle,
    this.prefix,
    this.suffix,
    this.overflow = TextOverflow.clip,
    this.maxLines,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return EasyRichText(
      '$prefix ${CalService.formatCurrency(context, animation.value)} $suffix',
      defaultStyle: style,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: false,
      patternList: [
        EasyRichTextPattern(
            targetString: prefix,
            hasSpecialCharacters: true,
            style: symbolStyle,
            matchWordBoundaries: false),
        EasyRichTextPattern(
            targetString: suffix,
            hasSpecialCharacters: true,
            style: symbolStyle,
            matchWordBoundaries: false),
      ],
    );
  }
}
