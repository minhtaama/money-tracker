import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../utils/enums.dart';
import '../../settings_and_persistent_values/data/persistent_repo.dart';

class DashboardEditModalScreen extends ConsumerStatefulWidget {
  const DashboardEditModalScreen({super.key});

  @override
  ConsumerState<DashboardEditModalScreen> createState() => _DashboardEditModalScreenState();
}

class _DashboardEditModalScreenState extends ConsumerState<DashboardEditModalScreen> {
  late final List<DashboardWidgetType> _order = List.from(context.appPersistentValues.dashboardOrder);
  late final List<DashboardWidgetType> _hiddenList =
      List.from(context.appPersistentValues.hiddenDashboardWidgets);

  void _updateDb() {
    ref
        .read(persistentControllerProvider.notifier)
        .set(dashboardOrder: _order, hiddenDashboardWidgets: _hiddenList);
  }

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Edit Dashboard'.hardcoded,
      subTitle: Text(
        'Choose which widget to display. Hold to re-order'.hardcoded,
        style: kHeader4TextStyle.copyWith(
          color: context.appTheme.onBackground,
          fontSize: 13,
        ),
      ),
      isWrapByCard: false,
      margin: EdgeInsets.zero,
      onReorder: (oldIndex, newIndex) {
        final item = _order.removeAt(oldIndex);
        _order.insert(newIndex, item);
        _updateDb();
      },
      sections: _order
          .map((e) => CardItem(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                border: context.appTheme.isDarkTheme
                    ? Border.all(color: context.appTheme.onBackground.withOpacity(0.15))
                    : null,
                child: Row(
                  children: [
                    SvgIcon(
                      e.iconPath,
                      color: context.appTheme.onBackground,
                    ),
                    Gap.w16,
                    Text(
                      e.name,
                      style: kHeader2TextStyle.copyWith(
                        color: context.appTheme.onBackground,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    e != DashboardWidgetType.menu
                        ? _AnimatedToggle(
                            initialValue: !_hiddenList.contains(e),
                            onTap: (value) {
                              if (!_hiddenList.contains(e)) {
                                _hiddenList.add(e);
                              } else {
                                _hiddenList.remove(e);
                              }
                              Future.delayed(k150msDuration, _updateDb);
                            },
                          )
                        : Gap.noGap,
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _AnimatedToggle extends StatefulWidget {
  const _AnimatedToggle({required this.initialValue, required this.onTap});

  final bool initialValue;

  final ValueSetter<bool> onTap;

  @override
  State<_AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<_AnimatedToggle> {
  late bool isOn = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final bgrColor = isOn ? context.appTheme.accent1 : context.appTheme.onBackground.withOpacity(0.35);
    final togglePosition = isOn ? 1 : 0;

    const double widthRatio = 1.7;
    const double size = 25;

    return GestureDetector(
      onTap: () {
        setState(() {
          isOn = !isOn;
        });
        widget.onTap(isOn);
      },
      child: SizedBox(
        height: size,
        width: size * widthRatio,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: k150msDuration,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: bgrColor,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedSlide(
                duration: k150msDuration,
                curve: Curves.easeOutBack,
                offset: Offset((widthRatio - 1) * togglePosition, 0),
                child: SizedBox(
                  height: size,
                  width: size,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                      //border: Border.all(color: bgrColor, width: 4),
                      color: context.appTheme.background1,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
