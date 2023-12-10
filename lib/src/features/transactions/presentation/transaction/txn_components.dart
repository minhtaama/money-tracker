import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/help_button.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'dart:math' as math;
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../domain/transaction_base.dart';

class TxnDot extends StatelessWidget {
  const TxnDot({super.key, required this.transaction, this.size});

  final BaseTransaction transaction;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size ?? 7,
      width: size ?? 7,
      decoration: BoxDecoration(
        color: _color(context, transaction),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class TxnInfo extends StatelessWidget {
  const TxnInfo(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.greyBgr(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 9),
      ),
    );
  }
}

class TxnCreditIcon extends StatelessWidget {
  const TxnCreditIcon({
    super.key,
    this.size = 18,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return HelpButton(
      text: 'Credit Account'.hardcoded,
      iconPath: AppIcons.credit,
      size: size,
      yOffset: 1,
    );
  }
}

class TxnInstallmentIcon extends StatelessWidget {
  const TxnInstallmentIcon({
    super.key,
    this.size = 18,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return HelpButton(
      title: 'Installment Payment'.hardcoded,
      text:
          'This transaction has been registered for installment payments, so you won\'t have to pay in this statement cycle; instead, you only need to settle the installment amount from next statement cycle.'
              .hardcoded,
      iconPath: AppIcons.installment,
      size: size,
    );
  }
}

class TxnAdjustmentIcon extends StatelessWidget {
  const TxnAdjustmentIcon({
    super.key,
    this.size = 18,
    required this.transaction,
  });

  final double size;
  final CreditPayment transaction;

  bool _showIcon(BuildContext context) {
    if (transaction.adjustment == null) {
      return false;
    }

    if (context.currentSettings.showDecimalDigits) {
      if (transaction.adjustment!.roundUsingAppSetting(context) == 0.00) {
        return false;
      }
    } else {
      if (transaction.adjustment!.roundUsingAppSetting(context) == 0) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _showIcon(context)
        ? HelpButton(
            title:
                'Adjust amount: ${transaction.adjustment! > 0 ? '+' : '-'} ${CalService.formatCurrency(context, transaction.adjustment!, isAbs: true)} ${context.currentSettings.currency.code}'
                    .hardcoded,
            text: 'This payment is adjusted to align with the actual credit balance'.hardcoded,
            iconPath: AppIcons.edit,
            size: size,
          )
        : Gap.noGap;
  }
}

class TxnCategoryIcon extends StatelessWidget {
  const TxnCategoryIcon({super.key, required this.transaction, this.color});

  final IBaseTransactionWithCategory transaction;
  final Color? color;

  String get _iconPath {
    if (transaction is Income && _isInitial(transaction)) {
      return AppIcons.add;
    }
    if (transaction.category != null) {
      return transaction.category!.iconPath;
    }
    return AppIcons.defaultIcon;
  }

  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      _iconPath,
      size: 20,
      color: color ?? context.appTheme.backgroundNegative.withOpacity(_isInitial(transaction) ? 0.5 : 1),
    );
  }
}

class TxnCategoryName extends StatelessWidget {
  const TxnCategoryName({super.key, required this.transaction, this.fontSize});

  final IBaseTransactionWithCategory transaction;
  final double? fontSize;

  String get _name {
    if (transaction is Income && _isInitial(transaction)) {
      return 'Initial Balance';
    }
    if (transaction.category != null) {
      return transaction.category!.name;
    }
    return 'No Category';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _name,
      style: kHeader3TextStyle.copyWith(
        fontSize: fontSize ?? 12,
        color: context.appTheme.backgroundNegative.withOpacity(_isInitial(transaction) ? 0.5 : 1),
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnAccountIcon extends ConsumerWidget {
  const TxnAccountIcon({super.key, required this.transaction, this.useAccountIcon = false});

  final BaseTransaction transaction;
  final bool useAccountIcon;

  String _iconPath(WidgetRef ref) {
    if (transaction.account != null) {
      if (useAccountIcon) {
        return transaction.account!.iconPath;
      }
      return switch (transaction) {
        Transfer() => '',
        Income() => AppIcons.download,
        Expense() => AppIcons.upload,
        CreditPayment() => AppIcons.upload,
        CreditSpending() => AppIcons.upload,
        CreditCheckpoint() => AppIcons.transfer,
      };
    }
    return AppIcons.defaultIcon;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SvgIcon(
      _iconPath(ref),
      size: 20,
      color: context.appTheme.backgroundNegative,
    );
  }
}

class TxnAccountName extends ConsumerWidget {
  const TxnAccountName({super.key, required this.transaction, this.fontSize});

  final BaseTransaction transaction;
  final double? fontSize;

  // String _name(WidgetRef ref) {
  //   if (transaction.account != null) {
  //     return ref.read(accountRepositoryProvider).getAccount(transaction.account!)!.name;
  //   }
  //   return 'No account assigned';
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      transaction.account!.name,
      style: kHeader3TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: fontSize ?? 12),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnToAccountIcon extends ConsumerWidget {
  const TxnToAccountIcon({Key? key, required this.transaction}) : super(key: key);

  final Transfer transaction;

  String _iconPath(WidgetRef ref) {
    if (transaction.transferAccount != null) {
      return transaction.transferAccount!.iconPath;
    }
    return AppIcons.defaultIcon;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SvgIcon(
      _iconPath(ref),
      size: 20,
      color: context.appTheme.backgroundNegative,
    );
  }
}

class TxnTransferAccountName extends ConsumerWidget {
  const TxnTransferAccountName({Key? key, required this.transaction}) : super(key: key);

  final ITransferable transaction;

  String _name(WidgetRef ref) {
    if (transaction.transferAccount != null) {
      return transaction.transferAccount!.name;
    }
    return 'Empty';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      _name(ref),
      style: kHeader3TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 12),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnAmount extends StatelessWidget {
  const TxnAmount(
      {super.key,
      required this.currencyCode,
      required this.transaction,
      this.fontSize,
      this.color,
      this.showPaymentAmount = false})
      : assert(showPaymentAmount == true ? transaction is CreditSpending : true);

  final String currencyCode;
  final BaseTransaction transaction;
  final double? fontSize;
  final bool showPaymentAmount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          CalService.formatCurrency(
              context, showPaymentAmount ? (transaction as CreditSpending).paymentAmount! : transaction.amount),
          softWrap: false,
          overflow: TextOverflow.fade,
          style: kHeader2TextStyle.copyWith(color: color ?? _color(context, transaction), fontSize: fontSize ?? 15),
        ),
        Gap.w4,
        Text(
          currencyCode,
          style: kHeader4TextStyle.copyWith(color: color ?? _color(context, transaction), fontSize: fontSize ?? 15),
        ),
      ],
    );
  }
}

class TxnNote extends StatelessWidget {
  const TxnNote({super.key, required this.transaction});

  final BaseTransaction transaction;

  String? get _categoryTag {
    final txn = transaction;
    switch (txn) {
      case IBaseTransactionWithCategory():
        return (txn as IBaseTransactionWithCategory).categoryTag != null
            ? '# ${(txn as IBaseTransactionWithCategory).categoryTag!.name}'
            : null;
      case Transfer() || CreditPayment() || CreditCheckpoint():
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 2, top: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: context.appTheme.backgroundNegative.withOpacity(0.3), width: 1.5)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        constraints: const BoxConstraints(minHeight: 32),
        decoration: BoxDecoration(
          color: context.appTheme.backgroundNegative.withOpacity(0.05),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _categoryTag != null
                ? Text(
                    _categoryTag!,
                    style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.backgroundNegative.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  )
                : Gap.noGap,
            _categoryTag != null && transaction.note != null ? Gap.h4 : Gap.noGap,
            transaction.note != null
                ? Text(
                    transaction.note!,
                    style: kHeader4TextStyle.copyWith(
                      color: context.appTheme.backgroundNegative.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 3,
                  )
                : Gap.noGap,
          ],
        ),
      ),
    );
  }
}

class TxnTransferLine extends StatelessWidget {
  const TxnTransferLine(
      {super.key, this.height = 27, this.width = 20, this.adjustY = 1, this.strokeWidth = 1, this.opacity = 1});

  final double height;
  final double adjustY;
  final double width;
  final double strokeWidth;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRect(
        child: CustomPaint(
          painter: _TransferLinePainter(context, strokeWidth, opacity, height: height, width: width, adjustY: adjustY),
        ),
      ),
    );
  }
}

class TxnSpendingPaidBar extends StatefulWidget {
  const TxnSpendingPaidBar({super.key, this.height = 20, required this.percentage})
      : assert(percentage >= 0 && percentage <= 1);

  final double height;
  final double percentage;

  @override
  State<TxnSpendingPaidBar> createState() => _TxnSpendingPaidBarState();
}

class _TxnSpendingPaidBarState extends State<TxnSpendingPaidBar> {
  final _key = GlobalKey();
  double _width = 0;

  @override
  void didUpdateWidget(covariant TxnSpendingPaidBar oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _width = _key.currentContext!.size!.width * widget.percentage;
      });
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      width: double.infinity,
      height: widget.height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.greyBgr(context),
        // gradient: LinearGradient(
        //   colors: [context.appTheme.primary, AppColors.greyBgr(context)],
        //   stops: [percentage, percentage],
        // ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: k250msDuration,
          color: context.appTheme.primary,
          height: widget.height,
          width: _width,
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////

Color _color(BuildContext context, BaseTransaction transaction) {
  return switch (transaction) {
    Income() => context.appTheme.positive,
    Expense() => context.appTheme.negative,
    CreditSpending() => AppColors.grey(context),
    CreditPayment() => context.appTheme.negative,
    Transfer() => AppColors.grey(context),
    CreditCheckpoint() => AppColors.grey(context),
  };
}

bool _isInitial(IBaseTransactionWithCategory transaction) {
  if (transaction is Income && transaction.isInitialTransaction) {
    return true;
  }
  return false;
}

class _TransferLinePainter extends CustomPainter {
  _TransferLinePainter(this.context, this.strokeWidth, this.opacity,
      {this.height = 30, required this.width, required this.adjustY});

  final BuildContext context;
  final double height;
  final double width;
  final double adjustY;
  final double strokeWidth;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    double arrowXOffset = 3;
    double arrowYOffset = 3;

    double cornerSize = 14;

    ///// DO NOT CHANGE ANYTHING UNDER THIS LINE /////

    double startX = 3;
    double startY = arrowYOffset + adjustY;
    double endX = width - 3;
    double endY = height - arrowYOffset - adjustY;

    Offset arrowHead = Offset(endX, endY);
    Offset upperTail = Offset(arrowHead.dx - arrowXOffset, arrowHead.dy - arrowYOffset);
    Offset lowerTail = Offset(arrowHead.dx - arrowXOffset, arrowHead.dy + arrowYOffset);

    Offset lineTopBegin = Offset(startX + cornerSize / 2, startY);
    Offset lineTopEnd = Offset(endX - 1, startY);
    Offset lineMiddleBegin = Offset(startX, startY + cornerSize / 2);
    Offset lineMiddleEnd = Offset(startX, endY - cornerSize / 2);
    Offset lineBottomBegin = Offset(startX + cornerSize / 2, endY);
    Offset lineBottomEnd = Offset(endX - 1, endY);

    final corner1 = Rect.fromLTWH(startX, startY, cornerSize, cornerSize);
    final corner2 = Rect.fromLTWH(startX, endY - cornerSize, cornerSize, cornerSize);
    const startAngle1 = math.pi;
    const startAngle2 = math.pi / 2;
    const sweepAngle = math.pi / 2;
    const useCenter = false;

    final paint = Paint()
      ..color = context.appTheme.backgroundNegative.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(corner1, startAngle1, sweepAngle, useCenter, paint);
    canvas.drawArc(corner2, startAngle2, sweepAngle, useCenter, paint);

    canvas.drawLine(lineTopBegin, lineTopEnd, paint);
    canvas.drawLine(lineMiddleBegin, lineMiddleEnd, paint);
    canvas.drawLine(lineBottomBegin, lineBottomEnd, paint);

    canvas.drawLine(arrowHead, upperTail, paint);
    canvas.drawLine(arrowHead, lowerTail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
