import 'package:flutter/widgets.dart';

extension WhiteLerp on Color {
  Color addWhite(double t) => Color.lerp(this, const Color(0xFFFFFFFF), t)!;
}
