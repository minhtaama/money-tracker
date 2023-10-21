part of 'statement.dart';

@immutable
class PreviousStatement {
  /// Assign to `carryingOver` of the next Statement object.
  ///
  /// This class is not meant to be created outside of this library
  const PreviousStatement._({
    required this.balanceCarryToThisStatement,
    required this.balanceAfterEndDate,
    required this.interest,
    required this.dueDate,
  });

  /// Could be **negative** if payments after [endDate] is also
  /// paid for [CreditSpending] of next statement.
  ///
  /// In other words, all [CreditPayment] that happens before [PreviousStatement.dueDate]
  /// of current [Statement] will be counted in [PreviousStatement.balanceCarryToThisStatement].
  final double balanceCarryToThisStatement;

  final double balanceAfterEndDate;

  final double interest;

  final DateTime dueDate;

  /// **Can't be negative**
  double get totalCarryToThisStatement => balanceCarryToThisStatement <= 0 ? 0 : balanceCarryToThisStatement + interest;

  factory PreviousStatement.noData() {
    return PreviousStatement._(
        balanceCarryToThisStatement: 0, balanceAfterEndDate: 0, interest: 0, dueDate: Calendar.minDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviousStatement &&
          runtimeType == other.runtimeType &&
          balanceCarryToThisStatement == other.balanceCarryToThisStatement &&
          interest == other.interest &&
          dueDate == other.dueDate;

  @override
  int get hashCode => balanceCarryToThisStatement.hashCode ^ interest.hashCode ^ dueDate.hashCode;
}
