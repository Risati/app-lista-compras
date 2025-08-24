import 'package:hive/hive.dart';
import 'report_item.dart';

part 'report_snapshot.g.dart';

@HiveType(typeId: 11)
class ReportSnapshot {
  @HiveField(0)
  String id; // uuid ou timestamp string

  @HiveField(1)
  String listId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? marketName; // campo solicitado

  @HiveField(4)
  double total;

  @HiveField(5)
  double? budget;

  @HiveField(6)
  List<ReportItem> items;

  @HiveField(7)
  String? note; // opcional (foto path, comentário)

  ReportSnapshot({
    required this.id,
    required this.listId,
    required this.date,
    this.marketName,
    required this.total,
    this.budget,
    required this.items,
    this.note,
  });
}
