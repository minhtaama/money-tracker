import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.name, {super.key, this.color, this.size = 25, this.height});
  final String name;
  final Color? color;
  final double size;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: height ?? size,
      child: FittedBox(
        child: SvgPicture.asset(
          name,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcATop) : null,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
