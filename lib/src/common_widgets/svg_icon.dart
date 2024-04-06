import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.name, {super.key, this.color, this.size = 25});
  final String name;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        child: SvgPicture.asset(
          name,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
