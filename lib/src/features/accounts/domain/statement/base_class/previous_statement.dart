part of 'statement.dart';

/// Assign to `previousStatement` of the next Statement object.
/// This class is not meant to be created outside of this library
/// All the calculation of this class property is in [Statement.carryToNextStatement]
@immutable
class PreviousStatement {
  /// Can't be **negative**. Use to get the remaining amount needed to pay carry to current statement.
  /// This previous statement only carry interest if this value is more than 0.
  ///
  /// The math might less than 0, if so, return 0. We don't need to care about the surplus paid amount
  /// because this value is calculated from **previousStatement._balanceToPayAtEndDate**, so no transaction
  /// is counted twice.
  ///
  /// Why balance but not spent amount? Because the "previous statement" will
  /// carry the interest of the "pre-previous statement" to the "previous statement".
  final double balanceToPayAtEndDateWithPrvGracePayment;

  /// Can't be **negative**, no interest included. Use as the balance to pay at the start date
  /// of current statement.
  ///
  /// The math should not be less than 0. However if so, return 0.
  ///
  /// Why balance but not spent amount? Because the "previous statement" will
  /// carry the interest of the "pre-previous statement" to the "previous statement".
  final double balanceToPayAtEndDate;

  /// Can't be **negative**. Use to calculate the interest of this previous statement.
  ///
  /// The math might less than 0, if so, return 0. We don't need to care about the surplus paid amount
  /// because this value is calculated from **previousStatement._balanceAtEndDate**, so no transaction
  /// is counted twice.
  ///
  /// Why balance but not spent amount? Because the "previous statement" will
  /// carry the interest of the "pre-previous statement" to the "previous statement".
  final double balanceAtEndDateWithPrvGracePayment;

  /// Can't be **negative**, no interest included. Use as the credit balance at the start date
  /// of current statement.
  ///
  /// The math should not be less than 0. However if so, return 0.
  ///
  /// Why balance but not spent amount? Because the "previous statement" will
  /// carry the interest of the "pre-previous statement" to the "previous statement".
  final double balanceAtEndDate;

  /// Only charge/carry interest if `balanceToPay` is more than 0.
  /// This is the interest that THIS PREVIOUS STATEMENT carry to "CURRENT STATEMENT"
  final double interestToThisStatement;

  /// Use for checking if can add payments
  final DateTime dueDate;

  factory PreviousStatement.noData({required DateTime dueDate}) {
    return PreviousStatement._(0, 0,
        balanceToPayAtEndDateWithPrvGracePayment: 0,
        balanceAtEndDateWithPrvGracePayment: 0,
        interestToThisStatement: 0,
        dueDate: dueDate);
  }

  /// Assign to `previousStatement` of the next Statement object.
  /// This class is not meant to be created outside of this library
  const PreviousStatement._(
    this.balanceToPayAtEndDate,
    this.balanceAtEndDate, {
    required this.balanceToPayAtEndDateWithPrvGracePayment,
    required this.balanceAtEndDateWithPrvGracePayment,
    required this.interestToThisStatement,
    required this.dueDate,
  });

  PreviousStatement copyWith({
    double? balanceToPayAtEndDateWithPrvGracePayment,
    double? balanceToPayAtEndDate,
    double? balanceAtEndDateWithPrvGracePayment,
    double? balanceAtEndDate,
    double? interestToThisStatement,
  }) {
    return PreviousStatement._(
      balanceToPayAtEndDate ?? this.balanceToPayAtEndDate,
      balanceAtEndDate ?? this.balanceAtEndDate,
      balanceToPayAtEndDateWithPrvGracePayment:
          balanceToPayAtEndDateWithPrvGracePayment ?? this.balanceToPayAtEndDateWithPrvGracePayment,
      balanceAtEndDateWithPrvGracePayment:
          balanceAtEndDateWithPrvGracePayment ?? this.balanceAtEndDateWithPrvGracePayment,
      interestToThisStatement: interestToThisStatement ?? this.interestToThisStatement,
      dueDate: dueDate,
    );
  }

  @override
  String toString() {
    return 'PreviousStatement{balanceToPay: $balanceToPayAtEndDateWithPrvGracePayment, _balanceToPayAtEndDate: $balanceToPayAtEndDate, balance: $balanceAtEndDateWithPrvGracePayment, _balanceAtEndDate: $balanceAtEndDate, interest: $interestToThisStatement, dueDate: $dueDate}';
  }
}
