import 'package:flutter/widgets.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class MoneyAmount extends StatefulWidget {
  final double amount;
  final Curve curve;
  final Duration duration;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final String? semanticsLabel;
  final String? separator;
  final String prefix;
  final String suffix;
  final bool noAnimation;

  const MoneyAmount({
    super.key,
    required this.amount,
    this.curve = Curves.easeInOut,
    this.duration = k550msDuration,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
    this.separator,
    this.prefix = '',
    this.suffix = '',
    this.noAnimation = false,
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
    _begin = 0;
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
    return _MoneyAnimatedText(
      animation: _animation,
      style: widget.style,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      separator: widget.separator,
      prefix: widget.prefix,
      suffix: widget.suffix,
    );
  }
}

class _MoneyAnimatedText extends AnimatedWidget {
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  final Animation<double> animation;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final String? semanticsLabel;
  final String? separator;
  final String? prefix;
  final String? suffix;

  _MoneyAnimatedText({
    required this.animation,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
    this.separator,
    this.prefix,
    this.suffix,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$prefix${CalService.formatCurrency(context, animation.value)}$suffix',
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
    );
  }
}
