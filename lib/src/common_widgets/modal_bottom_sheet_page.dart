import 'package:flutter/material.dart';

class ModalBottomSheetPage<T> extends Page<T> {
  /// This Page is used with [GoRoute] pageBuilder to build a
  /// ModalBottomSheetPage with a specific path. Remember to
  /// set `parentNavigatorKey` of the [GoRoute] to the root-key
  /// so that this Modal can display on top of the bottom navigation bar.
  ///
  /// > https://stackoverflow.com/questions/75690299/how-do-i-show-a-dialog-in-flutter-using-a-go-router-route
  ///
  /// Note: The ModalBottomSheet animation isn't working when testing on profile mode
  /// with Samsung device when having a accessibility application turned on
  ///
  /// > https://github.com/flutter/flutter/issues/119094
  const ModalBottomSheetPage({
    required this.child,
    this.shape,
    this.elevation,
    this.constraints,
    this.backgroundColor,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.isScrollControlled = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final ShapeBorder? shape;
  final double? elevation;
  final BoxConstraints? constraints;
  final Color? backgroundColor;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool isScrollControlled;
  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute(
        settings: this,
        shape: shape,
        elevation: elevation,
        constraints: constraints,
        backgroundColor: backgroundColor,
        modalBarrierColor: modalBarrierColor,
        isDismissible: isDismissible,
        isScrollControlled: isScrollControlled,
        enableDrag: true,
        useSafeArea: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      );
}
