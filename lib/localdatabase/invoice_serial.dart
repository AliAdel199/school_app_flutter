import 'package:isar/isar.dart';

part 'invoice_serial.g.dart';

@collection
class InvoiceCounter {
  Id id = 0; // ثابت دائمًا
  late int lastInvoiceNumber;
}
