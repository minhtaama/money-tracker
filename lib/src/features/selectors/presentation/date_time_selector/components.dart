part of 'date_time_selector.dart';

class _CustomTimePickSpinner extends StatelessWidget {
  const _CustomTimePickSpinner({this.time, this.onTimeChange});
  final DateTime? time;
  final void Function(DateTime)? onTimeChange;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TimePickerSpinner(
          time: time,
          spacing: 0,
          itemHeight: 26,
          alignment: Alignment.center,
          normalTextStyle: kHeader3TextStyle.copyWith(
              height: 0, color: context.appTheme.onBackground.withOpacity(0.4), fontSize: 15),
          highlightedTextStyle: kHeader1TextStyle.copyWith(height: 0.9, color: context.appTheme.primary, fontSize: 25),
          isForce2Digits: true,
          onTimeChange: (value) {
            onTimeChange?.call(value.toLocal());
          },
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              ':',
              style: kHeader1TextStyle.copyWith(fontSize: 23, color: context.appTheme.primary),
            ),
          ),
        )
      ],
    );
  }
}

class _DateTimeWidget extends StatelessWidget {
  const _DateTimeWidget({this.dateTime});

  final DateTime? dateTime;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      height: 60,
      width: 75,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(6),
      color: Colors.transparent,
      elevation: 0,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: context.appTheme.primary,
              child: Center(
                child: Text(
                  dateTime != null ? dateTime!.toShortDate(context, noYear: true) : '- -   - - -',
                  style: kHeader1TextStyle.copyWith(color: context.appTheme.onPrimary, fontSize: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.greyBgr(context),
              child: Center(
                child: Text(
                  dateTime != null ? dateTime!.year.toString() : DateTime.now().year.toString(),
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateWidget extends StatelessWidget {
  const _DateWidget({this.dateTime, required this.labelBuilder});

  final DateTime? dateTime;
  final String Function(DateTime?) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
      color: context.appTheme.primary,
      elevation: 0,
      child: Center(
        child: Text(
          labelBuilder(dateTime),
          style: kHeader2TextStyle.copyWith(color: context.appTheme.onPrimary, fontSize: 14),
        ),
      ),
    );
  }
}

class _DisableOverlay extends StatelessWidget {
  const _DisableOverlay({required this.disable, required this.height, required this.width, this.text});
  final bool disable;
  final double height;
  final double width;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !disable,
      child: AnimatedOpacity(
        duration: k150msDuration,
        opacity: disable ? 1 : 0,
        child: Container(
          height: height,
          width: width,
          padding: const EdgeInsets.all(8),
          color: context.appTheme.background0.withOpacity(0.75),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Center(
                child: Text(
              text ?? '',
              textAlign: TextAlign.center,
              style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.85), fontSize: 12),
            )),
          ),
        ),
      ),
    );
  }
}
