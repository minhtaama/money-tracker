import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';

class CreateRecurrenceWidget extends ConsumerStatefulWidget {
  const CreateRecurrenceWidget({super.key, required this.onChanged});

  final void Function(RecurrenceForm recurrenceForm) onChanged;

  @override
  ConsumerState<CreateRecurrenceWidget> createState() => _CreateRecurrenceWidgetState();
}

class _CreateRecurrenceWidgetState extends ConsumerState<CreateRecurrenceWidget> {
  bool _editMode = false;

  RecurrenceForm? _recurrenceForm;

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        if (_editMode) {
          setState(() {
            _editMode = false;
          });
        }
      },
      child: CardItem(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        color: Colors.transparent,
        border: Border.all(color: context.appTheme.onBackground.withOpacity(0.4)),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HideableContainer(
              hide: _editMode,
              child: CustomInkWell(
                inkColor: context.appTheme.onBackground,
                onTap: !_editMode
                    ? () => setState(() {
                          _editMode = true;
                        })
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SvgIcon(
                        AppIcons.switchIcon,
                        color: context.appTheme.onBackground.withOpacity(0.4),
                        size: 22,
                      ),
                      Gap.w8,
                      Text(
                        'No repeat'.hardcoded,
                        style: kHeader3TextStyle.copyWith(
                            color: context.appTheme.onBackground.withOpacity(0.4), fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            HideableContainer(hide: !_editMode, child: Placeholder()),
          ],
        ),
      ),
    );
  }
}

class RecurrenceForm {
  final RepeatEvery? type;

  final int? interval;

  /// Only year, month, day
  final List<DateTime>? repeatOn;

  /// Only year, month, day
  final DateTime startOn;

  /// Only year, month, day
  final DateTime? endOn;

  final bool autoCreateTransaction;

  factory RecurrenceForm.initial() {
    return RecurrenceForm._(
      startOn: DateTime.now(),
      autoCreateTransaction: true,
    );
  }

  RecurrenceForm._({
    this.type,
    this.interval,
    this.repeatOn,
    required this.startOn,
    this.endOn,
    required this.autoCreateTransaction,
  });

  RecurrenceForm copyWith({
    RepeatEvery? Function()? type,
    int? Function()? interval,
    List<DateTime>? Function()? repeatOn,
    DateTime? Function()? endOn,
    bool? autoCreateTransaction,
  }) {
    return RecurrenceForm._(
      type: type != null ? type() : this.type,
      interval: interval != null ? interval() : this.interval,
      repeatOn: repeatOn != null ? repeatOn() : this.repeatOn,
      endOn: endOn != null ? endOn() : this.endOn,
      autoCreateTransaction: autoCreateTransaction ?? this.autoCreateTransaction,
      startOn: startOn,
    );
  }
}
