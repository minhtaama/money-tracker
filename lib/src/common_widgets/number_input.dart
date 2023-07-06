import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../theme_and_ui/colors.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class NumberInput extends StatefulWidget {
  const NumberInput(
      {Key? key, required this.onChanged, required this.focusColor, required this.hintText})
      : super(key: key);
  final ValueChanged<double> onChanged;
  final Color focusColor;
  final String hintText;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  double doubleValue = 0;

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: context.appTheme.backgroundNegative.withOpacity(0.1),
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.backgroundNegative,
      ),
      decoration: InputDecoration(
        focusColor: context.appTheme.primary,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: widget.focusColor, width: 2),
        ),
        hintText: widget.hintText,
        hintStyle: kHeader2TextStyle.copyWith(
          color: context.appTheme.backgroundNegative.withOpacity(0.5),
          fontSize: 18,
        ),
      ),
      onTap: () {
        showCustomModalBottomSheet(context: context, child: const Calculator());
      },
      readOnly: true,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onChanged: (value) {
        doubleValue = double.parse(value);
        widget.onChanged(doubleValue);
      },
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: GridView.count(
        shrinkWrap: true,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        crossAxisCount: 4,
        children: [
          NumberKey(text: '1', onTextInput: (value) {}),
          NumberKey(text: '2', onTextInput: (value) {}),
          NumberKey(text: '3', onTextInput: (value) {}),
          NumberKey(text: '+', onTextInput: (value) {}),
          NumberKey(text: '4', onTextInput: (value) {}),
          NumberKey(text: '5', onTextInput: (value) {}),
          NumberKey(text: '6', onTextInput: (value) {}),
          NumberKey(text: '-', onTextInput: (value) {}),
          NumberKey(text: '7', onTextInput: (value) {}),
          NumberKey(text: '8', onTextInput: (value) {}),
          NumberKey(text: '9', onTextInput: (value) {}),
          NumberKey(text: 'x', onTextInput: (value) {}),
          NumberKey(text: '0', onTextInput: (value) {}),
          NumberKey(text: '.', onTextInput: (value) {}),
        ],
      ),
    );
  }
}

//TODO: Implement CALCULATOR
class NumberKey extends StatelessWidget {
  const NumberKey({
    Key? key,
    required this.text,
    required this.onTextInput,
  }) : super(key: key);
  final String text;
  final ValueSetter<String> onTextInput;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      key: key,
      color: context.appTheme.background3,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: InkWell(
        onTap: () async {
          // wait for button animation
          await Future.delayed(const Duration(milliseconds: 100));
          onTextInput(text);
        },
        splashColor: context.appTheme.primaryNegative.withAlpha(105),
        highlightColor: context.appTheme.primaryNegative.withAlpha(105),
        borderRadius: BorderRadius.circular(1000),
        child: Center(
          child: Text(
            text,
            style: kHeader2TextStyle,
          ),
        ),
      ),
    );
  }
}
