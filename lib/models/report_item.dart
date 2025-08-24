import 'package:hive/hive.dart';

part 'report_item.g.dart';

@HiveType(typeId: 10)
class ReportItem {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double unitPrice;

  @HiveField(3)
  double subtotal;

  @HiveField(4)
  String? category;

  ReportItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.category,
  });
}
