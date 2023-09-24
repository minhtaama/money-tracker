import 'package:isar/isar.dart';

@Collection()
class PaymentPeriodIsar {
  @Index()
  late DateTime statementDate;

  late DateTime paymentDueDate;
}
