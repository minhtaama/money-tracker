import 'package:flutter/widgets.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

extension WhiteLerp on Color {
  Color addWhite(double t) => Color.lerp(this, const Color(0xFFFFFFFF), t)!;
  Color addDark(double t) => Color.lerp(this, const Color(0xFF000000), t)!;
  Color lerpWithBg(BuildContext context, double t) => context.appTheme.isDarkTheme ? addDark(t) : addWhite(t);
  Color lerpWithOnBg(BuildContext context, double t) => context.appTheme.isDarkTheme ? addWhite(t) : addDark(t);
}
