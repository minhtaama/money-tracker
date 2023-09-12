import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'dart:math' as math;
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../domain/transaction.dart';

class TxnDot extends StatelessWidget {
  const TxnDot({Key? key, required this.transaction}) : super(key: key);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      width: 7,
      decoration: BoxDecoration(
        color: _color(context, transaction),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class TxnCreditIcon extends StatelessWidget {
  const TxnCreditIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.grey(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Credit',
        style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 9),
      ),
    );
  }
}

class TxnCategoryIcon extends StatelessWidget {
  const TxnCategoryIcon({Key? key, required this.transaction}) : super(key: key);

  final TransactionWithCategory transaction;

  String get _iconPath {
    if (transaction is Income && _isInitial(transaction)) {
      return AppIcons.add;
    }
    if (transaction.category != null) {
      return transaction.category!.iconPath;
    }
    return ''; //TODO: Implements blank icon and name if transaction has null category
  }

  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      _iconPath,
      size: 20,
      color: context.appTheme.backgroundNegative.withOpacity(_isInitial(transaction) ? 0.5 : 1),
    );
  }
}

class TxnCategoryName extends StatelessWidget {
  const TxnCategoryName({Key? key, required this.transaction}) : super(key: key);

  final TransactionWithCategory transaction;

  String get _name {
    if (transaction is Income && _isInitial(transaction)) {
      return 'Initial Balance';
    }
    if (transaction.category != null) {
      return transaction.category!.name;
    }
    return ''; //TODO: Implements blank icon and name if transaction has null category
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _name,
      style: kHeader3TextStyle.copyWith(
        fontSize: 12,
        color: context.appTheme.backgroundNegative.withOpacity(_isInitial(transaction) ? 0.5 : 1),
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnAccountIcon extends StatelessWidget {
  const TxnAccountIcon({Key? key, required this.transaction, this.useAccountIcon = false}) : super(key: key);

  final Transaction transaction;

  final bool useAccountIcon;

  String get _iconPath {
    if (transaction.account != null) {
      if (useAccountIcon) {
        return transaction.account!.iconPath;
      }
      return switch (transaction) {
        Transfer() => '',
        Income() => AppIcons.download,
        Expense() => AppIcons.upload,
        CreditPayment() => AppIcons.upload,
        CreditSpending() => AppIcons.upload
      };
    }
    return ''; //TODO: Implements blank icon and name if transaction has null account
  }

  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      _iconPath,
      size: 20,
      color: context.appTheme.backgroundNegative,
    );
  }
}

class TxnAccountName extends StatelessWidget {
  const TxnAccountName({Key? key, required this.transaction}) : super(key: key);

  final Transaction transaction;

  String get _name {
    if (transaction.account != null) {
      return transaction.account!.name;
    }
    return ''; //TODO: Implements blank icon and name if transaction has null account
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _name,
      style: kHeader3TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 12),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnToAccountIcon extends StatelessWidget {
  const TxnToAccountIcon({Key? key, required this.transaction}) : super(key: key);

  final Transfer transaction;

  String get _iconPath {
    if (transaction.toAccount != null) {
      return transaction.toAccount!.iconPath;
    }
    return ''; //TODO: Implements blank icon and name if transaction has null account
  }

  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      _iconPath,
      size: 20,
      color: context.appTheme.backgroundNegative,
    );
  }
}

class TxnToAccountName extends StatelessWidget {
  const TxnToAccountName({Key? key, required this.transaction}) : super(key: key);

  final Transfer transaction;

  String get _name {
    if (transaction.toAccount != null) {
      return transaction.toAccount!.name;
    }
    return ''; //TODO: Implements blank icon and name if transaction has null category and account
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _name,
      style: kHeader3TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 12),
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}

class TxnAmount extends StatelessWidget {
  const TxnAmount({Key? key, required this.currencyCode, required this.transaction}) : super(key: key);

  final String currencyCode;
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          CalService.formatCurrency(transaction.amount),
          softWrap: false,
          overflow: TextOverflow.fade,
          style: kHeader2TextStyle.copyWith(color: _color(context, transaction), fontSize: 15),
        ),
        Gap.w4,
        Text(
          currencyCode,
          style: kHeader4TextStyle.copyWith(color: _color(context, transaction), fontSize: 15),
        ),
      ],
    );
  }
}

class TxnNote extends StatelessWidget {
  const TxnNote({Key? key, required this.transaction}) : super(key: key);

  final Transaction transaction;

  String? get _categoryTag {
    final txn = transaction;
    switch (txn) {
      case TransactionWithCategory():
        return txn.categoryTag != null ? '# ${txn.categoryTag!.name}' : null;
      case Transfer() || CreditPayment():
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
      {Key? key, this.height = 27, this.width = 20, this.adjustY = 1, this.strokeWidth = 1, this.opacity = 1})
      : super(key: key);

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

///////////////////////////////////////////////////////////////////

Color _color(BuildContext context, Transaction transaction) {
  return switch (transaction) {
    Income() => context.appTheme.positive,
    Expense() => context.appTheme.negative,
    CreditSpending() => context.appTheme.backgroundNegative.withOpacity(0.5),
    CreditPayment() => context.appTheme.negative,
    Transfer() => context.appTheme.backgroundNegative.withOpacity(0.5),
  };
}

bool _isInitial(TransactionWithCategory transaction) {
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
