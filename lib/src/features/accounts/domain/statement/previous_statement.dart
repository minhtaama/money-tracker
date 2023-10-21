part of 'statement.dart';

@immutable
class PreviousStatement {
  /// Assign to `carryingOver` of the next Statement object.
  ///
  /// This class is not meant to be created outside of this library
  const PreviousStatement._({
    required this.balance,
    required this.pendingForGracePeriod,
    required this.interest,
    required this.dueDate,
  });

  /// Can't be **negative**. This is the remaining amount of money that haven't been paid.
  ///
  /// Use to calculate interest and carry over amount to next statement
  final double balance;

  /// Use to calculate what left to pay or has paid in next statement
  /// if more than 0, then there is balance (spending amount) left for grace period in next statement to pay.
  final double pendingForGracePeriod;

  final double interest;

  final DateTime dueDate;

  /// **Can't be negative**
  double get carryOverWithInterest => balance <= 0 ? 0 : balance + interest;

  factory PreviousStatement.noData() {
    return PreviousStatement._(balance: 0, pendingForGracePeriod: 0, interest: 0, dueDate: Calendar.minDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviousStatement &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          pendingForGracePeriod == other.pendingForGracePeriod &&
          interest == other.interest &&
          dueDate == other.dueDate;

  @override
  int get hashCode => balance.hashCode ^ pendingForGracePeriod.hashCode ^ interest.hashCode ^ dueDate.hashCode;
}
