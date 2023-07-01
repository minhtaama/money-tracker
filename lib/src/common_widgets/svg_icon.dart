import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.name, {Key? key, this.color}) : super(key: key);
  final String name;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      name,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
